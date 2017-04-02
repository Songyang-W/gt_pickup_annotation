function hfig = GridTapeAlign
%% Make figure
scrn = get(0,'Screensize');
hfig = figure('Position',[scrn(3)*0.2 scrn(4)*0.05 scrn(3)*0.6 scrn(4)*0.86],...% [50 100 1700 900]
    'Name','GridTapeAlign','DeleteFcn',@closefigure_Callback,...
    'KeyPressFcn',@KeyPressCallback,...
    'WindowButtonDownFcn',@WindowButtonDownCallback,...
    'ToolBar', 'none'); % 'MenuBar', 'none'
hold off; axis off

% init GUI drawing axes
ax_pos = [0.1, 0.1, 0.8, 0.7];
setappdata(hfig,'ax_pos',ax_pos);

%% Init
isShowMasks = [1,1];
setappdata(hfig,'isShowMasks',isShowMasks);

%% Load??
% loas previously saved mask templates for slot and sample
load('initMasks.mat','pos_slot_init','pos_sample_init');
setappdata(hfig,'pos_slot_init',pos_slot_init);
setappdata(hfig,'pos_sample_init',pos_sample_init);

% Init?
setappdata(hfig,'pos_slot',pos_slot_init);
setappdata(hfig,'pos_sample',pos_sample_init);

%% Set path
imPath = 'testImgs';
setappdata(hfig,'imPath',imPath);

%% screen for valid images in given dir [parse imList]
imList = dir(fullfile(imPath, '*png'));
numFiles0 = length(imList);

fileIDs = zeros(numFiles0,1);
validIX = 1:numFiles0;

for i = 1:numFiles0
    a = imList(i).name;
    if length(a)>12 && strcmp(a(end-11:end),'_section.png')
        str = a(end-15:end-12);
        if str(1)=='_'
            str(1) = [];
        end
        C = textscan(str,'%d');
        fileIDs(i) = C{1};
    else
        validIX(i) = 0;
        disp(['file ''',a,''' does not match expected file name format']);
    end
end

numFiles = length(find(validIX));

List = [];
List.fileID = fileIDs(validIX);
List.filename = {imList(validIX).name}';
List.numFiles = numFiles;

% init params
relpos_slot_list = zeros(numFiles,2);
relpos_sample_list = zeros(numFiles,2);
List.relpos_slot = relpos_slot_list;
List.relpos_sample = relpos_sample_list;

setappdata(hfig,'List',List);
setappdata(hfig,'numFiles',numFiles);
setappdata(hfig,'relpos_slot_list',relpos_slot_list);
setappdata(hfig,'relpos_sample_list',relpos_sample_list);

S = [];
S(numFiles).fileID = []; % pre-allocating
for i = 1:numFiles
    X1 = fileIDs(validIX);
    X2 = List.filename;
    
    S(i).fileID = X1(i);    
    S(i).filename = X2{i};
    S(i).slot.relpos = [0,0];
    S(i).slot.relangle = 0;
    S(i).sample.relpos = [0,0];
    S(i).sample.relangle = 0;
end
setappdata(hfig,'S',S);

%% Create UI controls
set(gcf,'DefaultUicontrolUnits','normalized');
set(gcf,'defaultUicontrolBackgroundColor',[1 1 1]);

% tab group setup
tgroup = uitabgroup('Parent', hfig, 'Position', [0.05,0.88,0.91,0.12]);
numtabs = 2;
tab = cell(1,numtabs);
M_names = {'General','Init'};%,'Regression','Clustering etc.','Saved Clusters','Atlas'};
for i = 1:numtabs,
    tab{i} = uitab('Parent', tgroup, 'BackgroundColor', [1,1,1], 'Title', M_names{i});
end

% grid setup, to help align display elements
rheight = 0.2;
yrow = 0.7:-0.33:0;%0.97:-0.03:0.88;
dTextHt = 0.05; % dTextHt = manual adjustment for 'text' controls:
% (vertical alignment is top instead of center like for all other controls)
bwidth = 0.03;
grid = 0:bwidth+0.001:1;

%% handles
global h_i_im

%% UI ----- tab one ----- (General)
i_tab = 1;

%% UI row 1: file navigation
i_row = 1;
i = 1;n = 0;


i=i+n;
n=2; % saves both to workspace and to 'VAR_current.mat' and to arc folder
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Save to file',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_savePosToFile_Callback);

i=i+n;
n=2; % saves both to workspace and to 'VAR_current.mat' and to arc folder
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Save a Copy',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_savePosToFileCopy_Callback);

i=i+n;
n=2;
uicontrol('Parent',tab{i_tab},'Style','text','String','Current section#:',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','right');

i=i+n;
n=2;
h_i_im = uicontrol('Parent',tab{i_tab},'Style','edit',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@edit_imageCount_Callback);

i=i+n+1;
n=3; % saves both to workspace and to 'VAR_current.mat' and to arc folder
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Previous(''Shift+rClick'')',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_loadPreviousImage_Callback);

i=i+n;
n=3; % saves both to workspace and to 'VAR_current.mat' and to arc folder
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Next(''Right Click'')',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_loadNextImage_Callback);

%% UI row 2: slot mask
i_row = 2;
i = 1;n = 0;

i=i+n;
n=4; % saves both to workspace and to 'VAR_current.mat' and to arc folder
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Load slot mask',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_loadSlotMask_Callback);

i=i+n;
n=4; % saves both to workspace and to 'VAR_current.mat' and to arc folder
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Upate slot mask',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_updateSlotMask_Callback);

i=i+n;
n=2; % popupplot option: whether to plot behavior bar
uicontrol('Parent',tab{i_tab},'Style','checkbox','String','Plot behavior','Value',1,...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@checkbox_isShowSlotMask_Callback);

%% UI row 3: sample mask
i_row = 3;
i = 1;n = 0;

i=i+n;
n=4; % saves both to workspace and to 'VAR_current.mat' and to arc folder
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Load sample mask',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_loadSampleMask_Callback);

i=i+n;
n=4; % saves both to workspace and to 'VAR_current.mat' and to arc folder
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Update sample mask',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_updateSampleMask_Callback);

i=i+n;
n=2; % popupplot option: whether to plot behavior bar
uicontrol('Parent',tab{i_tab},'Style','checkbox','String','Plot behavior','Value',1,...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@checkbox_isShowSampleMask_Callback);

%% Init load
i_im = 1;
setappdata(hfig,'i_im',i_im);
LoadImage(hfig,i_im);
h_i_im.String = num2str(i_im);

end

%% Callback functions for UI elements:

%% ----- tab one ----- (General)

%% row 1: File navigation

function pushbutton_savePosToFile_Callback(hObject,~)
hfig = getParentFigure(hObject);
i_im = getappdata(hfig,'i_im');
SaveCurrentMasks(hfig,i_im);

List = getappdata(hfig,'List');
List.relpos_slot = getappdata(hfig,'relpos_slot_list');
List.relpos_sample = getappdata(hfig,'relpos_sample_list');
save('OUTPUT.mat','List');
end

function pushbutton_savePosToFileCopy_Callback(hObject,~)
hfig = getParentFigure(hObject);
i_im = getappdata(hfig,'i_im');
SaveCurrentMasks(hfig,i_im);

List = getappdata(hfig,'List');
List.relpos_slot = getappdata(hfig,'relpos_slot_list');
List.relpos_sample = getappdata(hfig,'relpos_sample_list');

timestamp  = datestr(now,'mmddyy_HHMM');
matname = ['OUTPUT_',timestamp,'.mat'];
save(matname,'List');
end

function edit_imageCount_Callback(hObject,~)
hfig = getParentFigure(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str),
    C = textscan(str,'%d');
    i_im = C{1}; % C{:};
    
    LoadImage(hfig,i_im);
end
end

function pushbutton_loadPreviousImage_Callback(hObject,~)
hfig = getParentFigure(hObject);
LoadPreviousImage(hfig);
end

function pushbutton_loadNextImage_Callback(hObject,~)
hfig = getParentFigure(hObject);
LoadNextImage(hfig);
end

%% row 2: slot masks
function pushbutton_loadSlotMask_Callback(hObject,~)
hfig = getParentFigure(hObject);
masktypeID = 1;
LoadMask(hfig,masktypeID);
end

function pushbutton_updateSlotMask_Callback(hObject,~)
hfig = getParentFigure(hObject);

% update mask position manually
hpoly_slot = getappdata(hfig,'hpoly_slot');
if isempty(hpoly_slot)
    % just load slot mask
    h_ax = getappdata(hfig,'h_ax');
    axes(h_ax);
    
    pos_slot_init = getappdata(hfig,'pos_slot_init');
    hpoly_slot = impoly(h_ax, pos_slot_init);
    
    setappdata(hfig,'hpoly_slot',hpoly_slot);
end
setColor(hpoly_slot,[1 0 0]);
wait(hpoly_slot); % double click to finalize position!
% update finalized polygon in bright color
setColor(hpoly_slot,[0 1 1]);
pos = getPosition(hpoly_slot);

% get relative position vector
pos_slot_init = getappdata(hfig,'pos_slot_init');
relposSlot = pos(1,:)-pos_slot_init(1,:);
% save
i_im = getappdata(hfig,'i_im');
relpos_slot_list = getappdata(hfig,'relpos_slot_list');
relpos_slot_list(i_im,:) = relposSlot;
setappdata(hfig,'relpos_slot_list',relpos_slot_list);
end

function checkbox_isShowSlotMask_Callback(hObject,~)
hfig = getParentFigure(hObject);
isShowMasks = getappdata(hfig,'isShowMasks');
isShowMasks(1) = get(hObject,'Value');
ShowMasks(hfig,isShowMasks);
setappdata(hfig,'isShowMasks');
end

function ShowMasks(hfig,isShowMasks)
i_im = getappdata(hfig,'i_im');
LoadImage(hfig,i_im);
if isShowMasks(1)
    masktypeID = 1;
    LoadMask(hfig,masktypeID);
end
if isShowMasks(2)
    masktypeID = 1;
    LoadMask(hfig,masktypeID);
end
end

%% row 3: sample mask
function pushbutton_loadSampleMask_Callback(hObject,~)
hfig = getParentFigure(hObject);
masktypeID = 2;
LoadMask(hfig,masktypeID);
end

function pushbutton_updateSampleMask_Callback(hObject,~)
hfig = getParentFigure(hObject);

% update mask position manually
hpoly_sample = getappdata(hfig,'hpoly_sample');
if isempty(hpoly_sample)
    % just load slot mask
    h_ax = getappdata(hfig,'h_ax');
    axes(h_ax);
    
    pos_sample_init = getappdata(hfig,'pos_sample_init');
    hpoly_sample = impoly(h_ax, pos_sample_init);
    
    setappdata(hfig,'hpoly_sample',hpoly_sample);
end
setColor(hpoly_sample,[1 0 0]);
wait(hpoly_sample); % double click to finalize position!
% resume(h)
% update finalized polygon in bright color
setColor(hpoly_sample,[0 1 1]);
pos = getPosition(hpoly_sample);

% get relative position vector
pos_sample_init = getappdata(hfig,'pos_sample_init');
relposSample = pos(1,:)-pos_sample_init(1,:);
% save
i_im = getappdata(hfig,'i_im');
relpos_sample_list = getappdata(hfig,'relpos_sample_list');
relpos_sample_list(i_im,:) = relposSample;
setappdata(hfig,'relpos_sample_list',relpos_sample_list);
end

%% UI-level functions

function KeyPressCallback(hfig, event)
masktypeID = getappdata(hfig,'masktypeID');
if strcmp(event.Key,' ')
    % switch between mask types (slot vs sample)
    
    masktypeID = getappdata(hfig,'masktypeID');
    if masktypeID==1
        setappdata(hfig,'masktypeID',2);
    else
        setappdata(hfig,'masktypeID',1);
    end
    ShowSelectedMask(hfig,masktypeID);

    % Translations

elseif strcmp(event.Key,'a') % translation: left
    translationArray = [-1,0];
    TranslateMask(hfig,translationArray,masktypeID);
    
elseif strcmp(event.Key,'d') % translation: right
    translationArray = [1,0];
    TranslateMask(hfig,translationArray,masktypeID);
    
elseif strcmp(event.Key,'w') % translation: up
    translationArray = [0,-1];
    TranslateMask(hfig,translationArray,masktypeID);
    
elseif strcmp(event.Key,'s') % translation: down
    translationArray = [0,1];
    TranslateMask(hfig,translationArray,masktypeID);
    
    % Rotations
    
elseif strcmp(event.Key,'q') % rotation: counter-clockwise
    rotationAngle = 0.005;
    RotateMask(hfig,rotationAngle,masktypeID);
    
elseif strcmp(event.Key,'e') % translation: clockwise
    rotationAngle = -0.005;
    RotateMask(hfig,rotationAngle,masktypeID);
    
end
end

function WindowButtonDownCallback(hfig, event)
seltype = get(gcf,'SelectionType');
switch seltype
    case 'extend' % Shift-click
        LoadPreviousImage(hfig);
    case 'alt' % RightClick/Control-click
        LoadNextImage(hfig);
        %     case 'open' % double left click
        %         disp(['double'])
        %     case 'normal' % normal single left click
        %         disp(['normal'])
end
end

function closefigure_Callback(hfig,~)
relpos_slot_list = getappdata(hfig,'relpos_slot_list');
relpos_sample_list = getappdata(hfig,'relpos_sample_list');

List = getappdata(hfig,'List');
List.relpos_slot = relpos_slot_list;
List.relpos_sample = relpos_sample_list;
setappdata(hfig,'List',List);

global EXPORT_autorecover;
EXPORT_autorecover = getappdata(hfig);
% h_impoly = getappdata(hfig,'h_impoly');
clear h_impoly
end

%% Helper functions

function ShowSelectedMask(hfig,masktypeID)

end

function SaveCurrentMasks(hfig,i_im_this)

% slot
pos = getappdata(hfig,'pos_slot');
pos_init = getappdata(hfig,'pos_slot_init');
relpos_slot_list = getappdata(hfig,'relpos_slot_list');
relpos = pos(1,:)-pos_init(1,:);
temp = relpos_slot_list(i_im_this,:);
if ~isequal(temp,relpos)
    relpos_slot_list(i_im_this,:) = relpos;
    setappdata(hfig,'relpos_slot_list',relpos_slot_list);
end

% sample
pos = getappdata(hfig,'pos_sample');
pos_init = getappdata(hfig,'pos_sample_init');
relpos_sample_list = getappdata(hfig,'relpos_sample_list');
relpos = pos(1,:)-pos_init(1,:);
relpos_sample_list(i_im_this,:) = relpos;
setappdata(hfig,'relpos_slot_list',relpos_sample_list);


% angle = getappdata(hfig,'angle');
end

function LoadImage(hfig,i_im)
%% save mask positions for previous image
i_im_this = getappdata(hfig,'i_im');
SaveCurrentMasks(hfig,i_im_this);

%% load new image
setappdata(hfig,'i_im',i_im); % set new image index
imPath = getappdata(hfig,'imPath');
List = getappdata(hfig,'List');
im_raw = imread(fullfile(imPath,List.filename{i_im}));

%% draw image
% clean-up canvas
allAxesInFigure = findall(hfig,'type','axes');
if ~isempty(allAxesInFigure)
    delete(allAxesInFigure);
end
ax_pos = getappdata(hfig,'ax_pos');
figure(hfig);
h_ax = axes('Position',ax_pos);
imagesc(im_raw);
axis equal; axis off
setappdata(hfig,'im_raw',im_raw);
setappdata(hfig,'h_ax',h_ax);

%% draw masks??

end

function LoadPreviousImage(hfig)
global h_i_im;
i_im = getappdata(hfig,'i_im');
if i_im > 1
    LoadImage(hfig,i_im-1);
    setappdata(hfig,'i_im',i_im-1);
    
    % update GUI
    h_i_im.String = num2str(i_im-1);
else
    disp('reached 1st image');
end
end

function LoadNextImage(hfig)
global h_i_im;
i_im = getappdata(hfig,'i_im');
numFiles = getappdata(hfig,'numFiles');
if i_im < numFiles
    LoadImage(hfig,i_im+1);
    setappdata(hfig,'i_im',i_im+1);
    
    % update GUI
    h_i_im.String = num2str(i_im+1);
else
    disp('reached last image');
end
end

function LoadMask(hfig,masktypeID)
setappdata(hfig,'masktypeID',masktypeID);

% get plotting axes
h_ax = getappdata(hfig,'h_ax');
axes(h_ax);

% make mask
if masktypeID==1
    pos_init = getappdata(hfig,'pos_slot_init');
elseif masktypeID==2
    pos_init = getappdata(hfig,'pos_sample_init');
end
hpoly = impoly(h_ax, pos_init);

% save
if masktypeID==1
    setappdata(hfig,'hpoly_slot',hpoly);
elseif masktypeID==2
    setappdata(hfig,'hpoly_sample',hpoly);
end
end

function RotateMask(hfig,rotationAngle,masktypeID)
if masktypeID == 1
    % record rotation angle
    angle_slot = getappdata(hfig,'angle_slot');
    setappdata(hfig,'angle_slot',angle_slot+rotationAngle);
    
    hpoly = getappdata(hfig,'hpoly_slot');
elseif masktypeID == 2
    % record rotation angle
    angle_sample = getappdata(hfig,'angle_sample');
    setappdata(hfig,'angle_sample',angle_sample+rotationAngle);

    hpoly = getappdata(hfig,'hpoly_sample');
end

pos = getPosition(hpoly);
center = GetCenterPos(pos);
poscenter = repmat(center,size(pos,1),1);
rotationArray = [cos(rotationAngle), -sin(rotationAngle); sin(rotationAngle), cos(rotationAngle)];
pos2 = (pos-poscenter) * rotationArray + poscenter;
%     hpoly_sample = impoly(h_ax, pos2);
setConstrainedPosition(hpoly,pos2)
if masktypeID == 1
    setappdata(hfig,'pos_slot',pos2);
elseif masktypeID == 2
    setappdata(hfig,'pos_sample',pos2);
end
end

function TranslateMask(hfig,translationArray,masktypeID)
if masktypeID == 1
    hpoly = getappdata(hfig,'hpoly_slot');
elseif masktypeID == 2
    hpoly = getappdata(hfig,'hpoly_sample');
end

pos = getPosition(hpoly);
pos2 = pos;
pos2(:,1) = pos2(:,1)+translationArray(1);
pos2(:,2) = pos2(:,2)+translationArray(2);

setConstrainedPosition(hpoly,pos2)
if masktypeID == 1
    setappdata(hfig,'pos_slot',pos2);
elseif masktypeID == 2
    setappdata(hfig,'pos_sample',pos2);
end
end

function center = GetCenterPos(pos)
center = zeros(1,2);
center(1) = (max(pos(:,1))-min(pos(:,1)))/2+min(pos(:,1));
center(2) = (max(pos(:,2))-min(pos(:,2)))/2+min(pos(:,2));
end

function fig = getParentFigure(fig)
% if the object is a figure or figure descendent, return the figure. Otherwise return [].
while ~isempty(fig) && ~strcmp('figure', get(fig,'type'))
    fig = get(fig,'parent');
end
end