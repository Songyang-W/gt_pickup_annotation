
%% ATK 170703

startSectionID = 436;
endSectionID = 440;
write = 0;


%% Set paths and load mask and image
% master path
masterPath = 'C:\Users\akuan\Dropbox (HMS)\htem_team\projects\PPC_project\stainingImages';

queue_output = [masterPath '\queues\' '170706_temcaGTjob_436_440.json'];


% saved mask templates for slot and section, respectively, in txt
slot_mask_file = [masterPath '\masks\' 'slot_mask_sect0010_170705.txt'];
section_mask_file = [masterPath '\masks\' 'section_mask_sec0010_170705.txt'];
setappdata(hfig,'slot_mask_file',slot_mask_file);
setappdata(hfig,'section_mask_file',section_mask_file);

% output of annotation, in txt
outputPath = [masterPath '\annotations']; % saves annotated relative positions to txt, for each individual section
if exist(outputPath,'dir')~=7
    mkdir(outputPath);
end
setappdata(hfig,'outputPath',outputPath);

% image folder
imPath = [masterPath '\ppc0_links']; % contains images of individual sections
%ParseImageDir(hfig,imPath);

% start writing json file (will continue in for loop over sections)
fileID = fopen(queue_output,'wt');
fprintf(fileID,'{');
%% Parse annotation text files

for secID = startSectionID:endSectionID
%secID = 431;

[S(secID),tf(secID)] = ScanText_GTA(secID,outputPath,slot_mask_file,section_mask_file);
f = fullfile(outputPath,[num2str(secID),'.txt']);

fid = fopen(f, 'rt');
s = textscan(fid, '%s', 'delimiter', '\n');

idx1 = find(strcmp(s{1}, 'SLOT'), 1, 'first');
idx2 = find(strcmp(s{1}, 'TOLS'), 1, 'first');
slot = dlmread(f,'',[idx1 0 idx2-2 1]);

idx3 = find(strcmp(s{1}, 'SECTION'), 1, 'first');
idx4 = find(strcmp(s{1}, 'NOITCES'), 1, 'first');
section = dlmread(f,'',[idx3 0 idx4-2 1]);


%% Determine scale and center of slot
% assume convention of 8 sided mask, starting from bottom left
% 170703_slot_mask

% find edges of slot in units of pixels
xL = (slot(1,1)+slot(2,1))/2;
xR = (slot(5,1)+slot(6,1))/2;
yT = (slot(3,2)+slot(4,2))/2;
yB = (slot(7,2)+slot(8,2))/2;

slot_center = [(xR+xL)/2 (yB+yT)/2];
slot_size = [(xR-xL) (yB-yT)];
pxl_size = 5.3; %um, point grey camera
pxl_scale = 1000/pxl_size;
%pxl_scale = [slot_size(1)/2 slot_size(2)/1.5]; % pixels per mm


%% Locate top-right corner for ROI (TEM reference)
% assume convention of this being the first point
% 170703_section_mask

disp(['Sect ' num2str(secID) ': ']);

roi_TR_pxl = section(1,:)-slot_center;
roi_TR_mm = roi_TR_pxl/pxl_scale;
roi_TR_mm = -roi_TR_mm; % rotate 180 deg to match TEMCA-GT orientation

% add constant offset to account for slot-finding routine offset
% fudge_factor = [ mean([.8921-.8515 .9581-.9422]) mean([-.4332+.5335 -.4062+.4968])];
% This is from manual checking of sec 431 and 432
fudge_factor = [0.0282    0.0955];
roi_TR_mm = roi_TR_mm + fudge_factor;

% check if corner is too close to slot (only checks bottom left (top right) for now)
slot_padding = 0; % closest we allow the corner to be to slot
% for now, treat the slot as 2x1.5, padding comes for free

% check x 
if roi_TR_mm(1) > 1-slot_padding
    roi_TR_mm(1) = 1-slot_padding;
    disp('Corner off slot right, adjusting ROI');
end

% check y
if roi_TR_mm(2) < -.75+slot_padding;
    roi_TR_mm(2) = -.75+slot_padding;
    disp('Corner off slot up, adjusting ROI');
end

% check rounded corner
curve_center = [.5 -.25];
offsetTR = [roi_TR_mm(1)-curve_center(1) roi_TR_mm(2)-curve_center(2)];

if offsetTR(1) > 0 && offsetTR(2) < 0 && norm(offsetTR) > 0.5 - slot_padding
    roi_TR_mm = curve_center + (0.5-slot_padding)/norm(offsetTR)*offsetTR;
    disp('Corner off slot top right, adjusting ROI');
end
   
    

disp(['Top Right Corner: ' num2str(roi_TR_mm)]);

%% Write json
if write == 1
    % units are nm
    offset = 40000;
    width = 1500000+2*offset;
    height = 750000+2*offset;
    fprintf(fileID,['"' num2str(secID) '": {"rois": [{"width": ' num2str(width) ', "right": ' ...
        sprintf('%0.0f',1e6*roi_TR_mm(1)+offset) ', "top": ' sprintf('%0.0f',1e6*roi_TR_mm(2)-offset)...
        ', "height": ' num2str(height) '}]}']);
    if secID == endSectionID
        fprintf(fileID,'}');
    else
        fprintf(fileID,', ');
    end
    
    
    %{
fprintf(fileID,['"' num2str(secID) '": {"rois": [{"width": 100000, "center": [' ...
    sprintf('%0.0f',1e6*roi_TR_mm(1)) ', ' sprintf('%0.0f',1e6*roi_TR_mm(2)) '], "height": 100000}]}']);
if secID == endSectionID
    fprintf(fileID,'}');
else
    fprintf(fileID,', ');
end
    %}
    
end
fclose(fileID);
end
