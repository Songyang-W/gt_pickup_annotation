
%% ATK 170703

startSectionID = 428;
endSectionID = 432;

%% Set paths and load mask and image
% master path
masterPath = 'C:\Users\akuan\Dropbox (HMS)\htem_team\projects\PPC_project\stainingImages';

queue_output = [masterPath '\queues\' 'temcaGTjob_center.json'];


% saved mask templates for slot and section, respectively, in txt
slot_mask_file = [masterPath '\masks\' '170703_slot_mask.txt'];
section_mask_file = [masterPath '\masks\' '170703_section_mask.txt'];
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

for sectionIdx = startSectionID:endSectionID
%sectionIdx = 431;
f = fullfile(outputPath,[num2str(sectionIdx),'.txt']);

fid = fopen(f, 'rt');
s = textscan(fid, '%s', 'delimiter', '\n');

idx1 = find(strcmp(s{1}, 'SLOT'), 1, 'first');
idx2 = find(strcmp(s{1}, 'TLOS'), 1, 'first');
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
pxl_scale = [slot_size(1)/2 slot_size(2)/1.5]; % pixels per mm


%% Locate top-right corner for ROI (TEM reference)
% assume convention of this being the first point
% 170703_section_mask

roi_TR_pxl = section(1,:)-slot_center;
roi_TR_mm = roi_TR_pxl./pxl_scale;
roi_TR_mm = -roi_TR_mm; % rotate 180 deg to match TEMCA-GT orientation



%% Write json

%{
fprintf(fileID,['"' num2str(sectionIdx) '": {"rois": [{"width": 100000, "right": ' ...
    sprintf('%0.0f',1e6*roi_TR_mm(1)) ', "top": ' sprintf('%0.0f',1e6*roi_TR_mm(2)) ', "height": 100000}]}']);
if sectionIdx == endSectionID   
    fprintf(fileID,'}');
else
    fprintf(fileID,', ');
end
%}


fprintf(fileID,['"' num2str(sectionIdx) '": {"rois": [{"width": 100000, "center": [' ...
    sprintf('%0.0f',1e6*roi_TR_mm(1)) ', ' sprintf('%0.0f',1e6*roi_TR_mm(2)) '], "height": 100000}]}']);
if sectionIdx == endSectionID   
    fprintf(fileID,'}');
else
    fprintf(fileID,', ');
end


end
fclose(fileID);