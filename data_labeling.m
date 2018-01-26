function varargout = data_labeling(varargin)
% DATA_LABELING MATLAB code for data_labeling.fig
%      DATA_LABELING, by itself, creates a new DATA_LABELING or raises the existing
%      singleton*.
%
%      H = DATA_LABELING returns the handle to a new DATA_LABELING or the handle to
%      the existing singleton*.
%
%      DATA_LABELING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATA_LABELING.M with the given input arguments.
%
%      DATA_LABELING('Property','Value',...) creates a new DATA_LABELING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before data_labeling_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to data_labeling_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help data_labeling

% Last Modified by GUIDE v2.5 06-Oct-2017 10:39:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @data_labeling_OpeningFcn, ...
                   'gui_OutputFcn',  @data_labeling_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before data_labeling is made visible.
function data_labeling_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to data_labeling (see VARARGIN)
loadState(handles);
% set(hObject, 'DeleteFcn', @doBeforeClosing);
handles.sample_rate_sensors = 100; %Hz
handles.accel_tick_size = 1000/handles.sample_rate_sensors; %ms
%% Load default accelerometer data
% % accel_file_name= 'n99_1_accel.mat';
% % accel_file_name= '98_20161109T102238.mat';
% % accel_file_path='C:\Dropbox\Metingen Ede\Sensor data\';
% % accel_file_path='C:\Dropbox\Metingen Ede\Sensor data\9-11-2016\Parsed data\';
% 
% [ accel_file_name,accel_file_path ] = uigetfile({'*.mat'},'Pick an accelerometer file');      %;*.png;*.yuv;*.bmp;*.tif'},'Pick a file');
% if(accel_file_path == 0)
%     set(handles.select_video_button,'Enable','on');
%     set(handles.select_accel_button,'Enable','on');
%     return;
% end
% input_accel_file = [accel_file_path,accel_file_name];
% load(input_accel_file);
% accelFileLength = length(timestamp); %200Hz samples -> 5ms per timestamp
% accelFileLength = accelFileLength / handles.sample_rate_sensors / 60 /60 /24;
% accelStopTime = datenum(refTime)+accelFileLength;
% handles.accelRefTime = datenum(refTime);
handles.accelRefTime = 0;
% % handles.accelRefTime = datenum(now);
% handles.accelStopTime = accelStopTime;
% 
% handles.vector = sqrt(sum([ax ay az].^2,2));
% 
% %accel_times = 0:handles.accel_tick_size:(length(timestamp)/.1)-handles.accel_tick_size; % time in seconds/seconds 
% accel_times = 0:handles.accel_tick_size:(length(timestamp)/(handles.sample_rate_sensors/1000))-handles.accel_tick_size;
% handles.accel_times = handles.accelRefTime + accel_times/(86400*1e3);
% 
% % datestr(datenum(refTime),'dd-mm-yyyy HH:MM:SS')
% % datestr(accelStopTime,'dd-mm-yyyy HH:MM:SS')
% % datestr(handles.videostarttime,'dd-mm-yyyy HH:MM:SS')
% % datestr(handles.videostoptime,'dd-mm-yyyy HH:MM:SS')
% 
% 
% set(handles.accel_file_text,'String',strcat('Current accel. file:',{' '},accel_file_name));
% 
% %% Load default video
% % [ handles.video_file_name,video_file_path ] = uigetfile({'*.*'},'Pick a video file');      %;*.png;*.yuv;*.bmp;*.tif'},'Pick a file');
% % if(video_file_path == 0)
% %     return;
% % end
% 
% % video_file_path = 'D:\data_ede\9-11-2016\';
% % handles.video_file_name = 'MVI_2204.mov';
% [ handles.video_file_name,video_file_path ] = uigetfile({'*.*'},'Pick a video file');      %;*.png;*.yuv;*.bmp;*.tif'},'Pick a file');
% if(video_file_path == 0)
%     set(handles.select_video_button,'Enable','on');
%     return;
% end
% input_video_file = [video_file_path,handles.video_file_name];
% %set(handles.edit1,'String',input_video_file);
% % Acquiring video
% videoObject = VideoReader(input_video_file);
% % Display first frame
% frame_1 = read(videoObject,1);
% axes(handles.video_axes);
% imshow(frame_1);
% drawnow;
% %axis(handles.axes1,'off');
% handles.video = videoObject;
% 
% % set(handles.start_pause_button,'Enable','off');
% % set(handles.begin_button,'Enable','off');
% % set(handles.end_button,'Enable','off');
% % set(handles.select_video_button,'Enable','on');
% set(handles.start_pause_button,'Enable','on');
% set(handles.begin_button,'Enable','on');
% set(handles.end_button,'Enable','on');
% set(handles.select_video_button,'Enable','on');
% 
% %% Load video info
% handles = loadVideoInfo(handles.video_file_name, handles);
% set(handles.jump_time_edit,'String',datestr(handles.videostarttime,'HH:MM:SS'));


%% Init variables
global frameskip;
global clicked_time_idx;
global multiplier;
handles.startFrame = 1;
global frame;
frame = handles.startFrame;
frameskip = 0;
clicked_time_idx =0;
multiplier= 1;
handles.jump_time = str2double(get(handles.jump_edit,'String'));
% handles.labels = {' \rightarrow    lying';' \rightarrow    standing';' \rightarrow    grazing';...
%     ' \rightarrow    walking';' \rightarrow    running';' \rightarrow    running-lure';
%     ' \rightarrow    running-chase';' \rightarrow    fighting'};
% handles.labels = {'lying';'standing';'grazing';...
%     'walking';'running';'running-lure';
%     'running-chase';'fighting';'unknown';'trotting';'shaking';'scratch-biting';...
%     'walking-lure';'trotting-lure';'walking-chase';'trotting-chase';'climbing-up';'climbing-down'};
handles.labels = {'lying';'standing';'walking';'trotting';'running';'grazing';'eating';'fighting'; ...
     'shaking';'scratch-biting';'climbing-up';'climbing-down';'brest-feeding';'rubbing';'standing-up';'unknown';'food-fight'};

%% Jump to frame
% if(datenum(refTime)>handles.videostarttime)
%     % if accel starts later than video, then go to that frame
%     handles.startFrame = round(abs(handles.accel_offset * 24*60*60 * handles.video.framerate))+1;
%     frame = handles.startFrame;
% end

%% Load existing labels
% handles = loadExistingLabels(accel_file_name,handles);

%% Change mouse icon to cross when over axes
hFigure = gcf;
% Create and activate a pointer manager for the figure:
iptPointerManager(hFigure, 'enable');
% Have the pointer change to a cross when the mouse enters an axes object:
iptSetPointerBehavior(handles.data_axes, @(hFigure, currentPoint)set(hFigure, 'Pointer', 'crosshair'));

% Choose default command line output for data_labeling
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


function rethandles = loadExistingLabels(accel_file_name, handles)
% formatSpec = '%{dd-MM-yyyy HH:mm:ss}D%d%[^\r\n]';
%formatSpec = '%q%d%[^\r\n]';
formatSpec = '%.7f%d%[^\r\n]';
idx = strfind(accel_file_name,'.mat');
label_file_name = accel_file_name(1:idx-1);
handles.label_folder = get(handles.label_folder_edit,'String');
if isempty(handles.label_folder)
    warndlg('No label folder selected. Please select label folder.');
    handles.label_folder = uigetdir();
    set(handles.label_folder_edit,'String',handles.label_folder);
 else
  
 end
handles.labels_filename = [handles.label_folder,'\labels_',label_file_name ,'.csv'];
fileID = fopen(handles.labels_filename,'r');
delimiter = ',';
global labellist;
try
    labellist = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
    fclose(fileID);
    %set(handles.last_label_text,'String',['Last label: ',datestr(max(labellist{1}),'HH:MM:SS')]);
    set(handles.last_label_text,'String',['Last label: ',datestr(max(labellist{1}),'HH:MM:SS'), ...
            '  "', handles.labels{labellist{2}(labellist{1}==max(labellist{1}))},'"']);
    %set(handles.recent_label_text,'String',['Most recent label: ',datestr(labellist{1}(end),'HH:MM:SS')]);
    set(handles.recent_label_text,'String',['Most recent label: ',datestr(labellist{1}(end),'HH:MM:SS'),'  "', ...
            handles.labels{labellist{2}(end)},'"']);
catch
    labellist = {[],[],[]};
    set(handles.last_label_text,'String','Last label: No labels found');
    set(handles.recent_label_text,'String','Last label: No labels found');
end

rethandles = handles;


function rethandles = loadVideoInfo(video_file_name,handles)
global frame;
frame=1;
video_info_formatSpec = '%q%.7f%.7f%[^\n\r]';
handles.label_folder = get(handles.label_folder_edit,'String');
if isempty(handles.label_folder)
    warndlg('No label folder selected. Please select label folder.');
    uiwait();
    handles.label_folder = uigetdir();
    set(handles.label_folder_edit,'String',handles.label_folder);
end
handles.video_info_filename = [handles.label_folder,'\video_time_sync_info.csv'];
try
%     formatSpec = '%q%D%D%[^\n\r]';
    fileID = fopen(handles.video_info_filename,'r');
    delimiter = ',';
    handles.video_info = textscan(fileID, video_info_formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', false);
    fclose(fileID);
catch
    %% do something
    warndlg('No video time information specified. Please add video_time_sync_info.csv to label folder.');
    return;
end
        
% video_info.Properties.VariableNames{'Var1'} = 'name';
% video_info.Properties.VariableNames{'Var2'} = 'start_time';
% video_info.Properties.VariableNames{'Var3'} = 'stop_time';
% Find the correct video
idx = strfind(video_file_name,'.');
handles.videoindex = find(strcmp(video_file_name(1:idx-1), handles.video_info{1,1}));
if(isempty(handles.videoindex))
    warndlg('Video not found in video_time_sync_info.csv. Please enter video data');
    uiwait;
    prompt = {'Video Start Time: dd-mmm-yyyy HH:MM:SS','Video duration: HH:MM:SS'};
    dlg_title = 'Please enter video information';
    num_lines = 1;
    defaultans = {datestr(now,'dd-mmm-yyyy HH:MM:SS'),datestr(now,'HH:MM:SS')};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    if(isempty(answer))
       rethandles = handles;
       return 
    end
    start = datenum(answer{1});
    duration = datenum(strcat('00-000-0000',{' '},answer{2}));
    fid=fopen(handles.video_info_filename,'a');
    fprintf(fid,'%s, %.7f, %.7f\r\n',video_file_name(1:idx-1),start,start+duration);
    fclose(fid);
    fileID = fopen(handles.video_info_filename,'r');
    delimiter = ',';
    handles.video_info = textscan(fileID, video_info_formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', false);
    fclose(fileID);
    handles.videoindex = find(strcmp(video_file_name(1:idx-1), handles.video_info{1,1}));
end
% handles.videostarttime = datenum(handles.video_info{1,2}(handles.videoindex));
% handles.videostoptime = datenum(handles.video_info{1,3}(handles.videoindex));
handles.videostarttime = handles.video_info{1,2}(handles.videoindex);
handles.videostoptime = handles.video_info{1,3}(handles.videoindex);
set(handles.vid_start_text,'String',['Start: ',datestr(handles.videostarttime,'HH:MM:SS')]);
set(handles.vid_stop_text,'String',['Stop: ',datestr(handles.videostoptime,'HH:MM:SS')]);
set(handles.video_file_text,'String',['Current video file: ',video_file_name(1:idx-1)]);
handles.video_length =  handles.videostoptime-handles.videostarttime;

%set(handles.video_offset_edit,'String',datestr(handles.video_offset,'HH:MM:SS'));
try
    handles.accel_offset = handles.videostarttime - handles.accelRefTime; % offset in fraction of days
    % convert fraction of days to ticks
    handles.accel_ticks_offset = round(handles.accel_offset * 24 * 60 * 60 * handles.sample_rate_sensors); %ms
catch e
    handles.accel_offset = 0;
    handles.accel_ticks_offset = 0;
end
rethandles = handles;


% --- Outputs from this function are returned to the command line.
function varargout = data_labeling_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

%% Executes on button press in start_pause_button.
function start_pause_button_Callback(hObject, eventdata, handles)
% hObject    handle to start_pause_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of start_pause_button

global frame;
global frameskip ;
global clicked_time_idx;
% global multiplier;
global labellist;

if(get(hObject,'Value'))
    set(handles.start_pause_button,'String','||')
    set(handles.select_video_button,'Enable','off');
    set(handles.select_accel_button,'Enable','off');
    numberOfFrames = handles.video.NumberOfFrames;
    framerate = handles.video.Framerate;
    axes(handles.video_axes);
    videoticks = 0:1/framerate:numberOfFrames/framerate;
    times = handles.videostarttime + videoticks/(86400);
    window_size = 20; % seconds
%     frame = handles.currentframe;
    axes(handles.data_axes);
    nr_accel_ticks =length(handles.accel_times);
    
    while  frame <= numberOfFrames
            if(~get(hObject,'Value')) 
%                 handles.currentframe = frame;
                set(handles.select_video_button,'Enable','on');
                set(handles.select_accel_button,'Enable','on');
                break; 
            end
            % frameskip is set by pressing a key on keyboard or by clicking
            % in data_axes with left mouse button
            frame = frame + frameskip;
            if frame<1;
                frame =1;
            elseif frame > numberOfFrames
               frame = 1; 
            end
            if frameskip ~= 0
                frameskip = 0;
            end
            reset(handles.data_axes);
            set(handles.video_text, 'String', datestr(times(frame)));
            
            thisFrame = read(handles.video, frame);
%             axes(handles.video_axes);
            image(thisFrame,'Parent',handles.video_axes);
            set(handles.video_axes,'Visible','off');
         
            line_tick = round((frame-1)*(1000/(framerate*handles.accel_tick_size)))+ 1 + handles.accel_ticks_offset;
            if(line_tick<=0)
                line_tick=1;
            end
            if(line_tick>nr_accel_ticks)
                line_tick = nr_accel_ticks;
            end
            if(clicked_time_idx ~= 0)
               frameskip =  round(( clicked_time_idx - handles.accel_times(line_tick) ) * 24*60*60 *framerate);
               clicked_time_idx =0;
            end
            x=[handles.accel_times(line_tick),handles.accel_times(line_tick)];
            y=[0,60];
           
            p1= plot(handles.data_axes,x,y,'r');
            
            hold(handles.data_axes, 'on');
            % accel ticks are NOT ALWAYS 5ms -> change to adaptive samplerate
            start_tick = round((frame-1)*(1000/(framerate*handles.accel_tick_size)))+ 1 + handles.accel_ticks_offset - window_size/2 * handles.sample_rate_sensors;
            if(start_tick<=0)
                start_tick =1;
            elseif(start_tick>nr_accel_ticks)
                start_tick=nr_accel_ticks;
            end
            end_tick = start_tick + window_size * handles.sample_rate_sensors;
            if(end_tick>nr_accel_ticks)
                end_tick=nr_accel_ticks;
            end
            p2= plot(handles.data_axes,  handles.accel_times(start_tick:end_tick),handles.vector(start_tick:end_tick),'b');
            if(~isempty(labellist{1}))
                x1 = datenum(labellist{1});
                x = x1(and(x1>=handles.accel_times(start_tick),x1<=handles.accel_times(end_tick)));
                y = [repmat([0],length(x),1) repmat([70],length(x),1)];
                p3 = plot(handles.data_axes,[x, x]',y','c');
                text(x+0.000005,y(:,2)-30,handles.labels(labellist{2}(and(x1>=handles.accel_times(start_tick),x1<handles.accel_times(end_tick)))),'Parent',handles.data_axes);
            end
            set(handles.data_axes, 'ButtonDownFcn', {@data_axes_ButtonDownFcn,handles}); 
            %axis(handles.data_axes,[handles.accel_times(start_tick) handles.accel_times(end_tick) 0 max(handles.vector(start_tick:end_tick))]);
            datetick(handles.data_axes,'x','HH:MM:SS');
            axis(handles.data_axes,'tight');
            grid(handles.data_axes,'minor');
             drawnow;
            frame = frame+1;
    % set(gcf,'position',[150 150 vidObj.Width vidObj.Height]);
    % set(gca,'units','pixels');
    % set(gca,'position',[0 0 vidObj.Width vidObj.Height]);
    end
    %handles.currentframe = handles.startFrame;
    %frame = numberOfFrames-150;
    set(handles.start_pause_button,'String','|>') 
    set(handles.select_video_button,'Enable','on');
    set(handles.select_accel_button,'Enable','on');
    set(handles.start_pause_button,'Value',0) 
else
   set(handles.start_pause_button,'String','|>') 
   
end
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in select_video_button.
function select_video_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_video_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.select_video_button,'Enable','off');
set(handles.select_accel_button,'Enable','off');
set(handles.start_pause_button,'Enable','off');
set(handles.begin_button,'Enable','off');
set(handles.end_button,'Enable','off');
currentfilepath = cd;
%cd 'D:\data_ede\';
handles.video_folder = get(handles.video_folder_edit,'String');
if isempty(handles.video_folder)
    warndlg('No video folder selected. Please select video folder.');
    uiwait();
    handles.video_folder = uigetdir();
    set(handles.video_folder_edit,'String',handles.video_folder);
 end
[ handles.video_file_name,video_file_path ] = uigetfile({'*.*'},'Pick a video file',handles.video_folder);      %;*.png;*.yuv;*.bmp;*.tif'},'Pick a file');
if(video_file_path == 0)
    set(handles.select_video_button,'Enable','on');
    set(handles.select_accel_button,'Enable','on');
    set(handles.start_pause_button,'Enable','off');
    set(handles.begin_button,'Enable','off');
    set(handles.end_button,'Enable','off');
    return;
end
set(gcf,'Pointer','watch');
drawnow;	% Cursor won't change right away unless you do this.
input_video_file = [video_file_path,handles.video_file_name];
%set(handles.edit1,'String',input_video_file);
% Acquiring video
videoObject = VideoReader(input_video_file);
% Display first frame
frame_1 = read(videoObject,1);
axes(handles.video_axes);
image(frame_1);
drawnow;
 set(handles.video_axes,'Visible','off');

%% Load video info
handles = loadVideoInfo(handles.video_file_name,handles);
if(isempty(handles.videoindex))
    set(handles.select_video_button,'Enable','on');
    set(handles.select_accel_button,'Enable','on');
    set(handles.start_pause_button,'Enable','off');
    set(handles.begin_button,'Enable','off');
    set(handles.end_button,'Enable','off');
   return; 
end
set(handles.jump_time_edit,'String',datestr(handles.videostarttime,'HH:MM:SS'));
set(handles.start_pause_button,'Enable','on');
set(handles.begin_button,'Enable','on');
set(handles.end_button,'Enable','on');
cd(currentfilepath);
%Update handles
handles.video = videoObject;
% datestr(handles.accelRefTime,'dd-mm-yyyy HH:MM:SS')
% datestr(handles.accelStopTime,'dd-mm-yyyy HH:MM:SS')
% datestr(handles.videostarttime,'dd-mm-yyyy HH:MM:SS')
% datestr(handles.videostoptime,'dd-mm-yyyy HH:MM:SS')
set(handles.select_video_button,'Enable','on');
set(handles.select_accel_button,'Enable','on');
set(handles.start_pause_button,'Enable','on');
set(handles.begin_button,'Enable','on');
set(handles.end_button,'Enable','on');
% if(handles.accelRefTime==0)% first time opening video
%     return;
% end
set(gcf,'Pointer','arrow');
drawnow;	% Cursor won't change right away unless you do this.
if(handles.accelRefTime~=0 &&(handles.accelRefTime>=handles.videostoptime || handles.accelStopTime<=handles.videostarttime))
    warndlg('Video and accelerometer data not in same time scope. Please select an accelerometer file in the timescope of this video.','Warning');
    uiwait();
    select_accel_button_Callback(hObject, eventdata, handles);
    return;
end
guidata(hObject,handles);


% --- Executes on key press with focus on data_labeling and none of its controls.
function data_labeling_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to data_labeling (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global frameskip;
global multiplier;

switch eventdata.Key
    case 'leftbracket'
        frameskip = round(-handles.jump_time * handles.video.Framerate);
    case 'rightbracket'
        frameskip =  round(handles.jump_time * handles.video.Framerate);
    case 'space' %pause
        frameskip =0;
        j = java(findjobj(handles.start_pause_button)); 
        j.doClick;  
    case 'equal'
%         multiplier = multiplier + 1;
%         set(handles.multiplier_text, 'String', sprintf('%ix',multiplier));
        frameskip = round(handles.jump_time * handles.video.Framerate)*2;
    case 'hyphen'
%         multiplier = multiplier - 1;
%         set(handles.multiplier_text, 'String', sprintf('%ix',multiplier));
        frameskip = round(-handles.jump_time * handles.video.Framerate)*2;
    otherwise
end
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Executes on mouse press over axes background.
function data_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to data_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global clicked_time_idx;
global labellist;
click_type = get(gcbf, 'SelectionType'); %left or right mouse button
point = get(hObject,'currentpoint');

if (strcmp(click_type ,'alt'))
    %time_clicked = datestr(point(1),'HH:MM:SS');
    %time_clicked = datestr(point(1),'DD-mm-yyyy HH:MM:ss');
    time_clicked = point(1);

    [selection,ok] = listdlg('PromptString','Select a file:',...
                    'SelectionMode','single',...
                    'ListString',handles.labels,'ListSize',[160 250],'PromptString','Select an activity');
    if(ok)
        fid=fopen(handles.labels_filename,'a');
        fprintf(fid,'%.7f, %d\r\n',time_clicked, selection);
        fclose(fid);
        labellist{1} = [labellist{1}; time_clicked];
        labellist{2} = [labellist{2}; selection];
        
        set(handles.last_label_text,'String',['Last label: ',datestr(max(labellist{1}),'HH:MM:SS'), ...
            '  "', handles.labels{labellist{2}(labellist{1}==max(labellist{1}))},'"']);
        set(handles.recent_label_text,'String',['Most recent label: ',datestr(time_clicked,'HH:MM:SS'),'  "', ...
            handles.labels{selection},'"']);
            
        
    end
elseif (strcmp(click_type ,'normal')) % jump to moment
    clicked_time_idx = point(1);
     %set(handles.start_pause_button,'String','Pause');
     % set(handles.start_pause_button,'Value',1);
     if(~get(handles.start_pause_button,'Value'))
        j = java(findjobj(handles.start_pause_button));  % fetches the java obj for the component
        j.doClick;               % simulates button press (in case of pushbuttons)
     end
end
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);



function jump_edit_Callback(hObject, eventdata, handles)
% hObject    handle to jump_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jump_edit as text
%        str2double(get(hObject,'String')) returns contents of jump_edit as a double
handles.jump_time = str2double(get(hObject,'String'));
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function jump_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jump_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in remove_label_button.
function remove_label_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_label_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Construct a questdlg with three options
choice = questdlg('Most recent label will be removed. Are you sure?', ...
	'Remove most recent label', ...
	'No');
if(~strcmp(choice,'Yes'))
    return;
end

global labellist;
labellist{1} = labellist{1}(1:end-1);
labellist{2} = labellist{2}(1:end-1);
fid=fopen(handles.labels_filename,'w');

for row = 1:length(labellist{1})
    fprintf(fid,'%.7f, %d\r\n',labellist{1}(row), labellist{2}(row));
end
fclose(fid);
 set(handles.recent_label_text,'String',['Most recent label: ',datestr(labellist{1}(end),'HH:MM:SS'), ...
        '  "', handles.labels{labellist{2}(end)},'"']);
 set(handles.last_label_text,'String',['Last label: ',datestr(max(labellist{1}),'HH:MM:SS'), ...
        '  "', handles.labels{labellist{2}(labellist{1}==max(labellist{1}))},'"']);
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

function video_offset_edit_Callback(hObject, eventdata, handles)
% hObject    handle to video_offset_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of video_offset_edit as text
%        str2double(get(hObject,'String')) returns contents of video_offset_edit as a double

handles.videostarttime = handles.videostarttime + str2double(get(hObject,'String'))/24/60/60;
handles.videostoptime = handles.videostarttime+handles.video_length;
handles.accel_offset = handles.videostarttime - handles.accelRefTime;
handles.accel_ticks_offset = round(handles.accel_offset * 24 * 60 * 60 * handles.sample_rate_sensors); %ms
handles.video_info{1,2}(handles.videoindex) = handles.videostarttime;
handles.video_info{1,3}(handles.videoindex) = handles.videostoptime;
fid=fopen(handles.video_info_filename,'w');

% fprintf(fid,'%s, %s, %s\r\n','filename','used start time','used end time');
fprintf(fid,'%s, %s, %s\r\n','filename','used start time','used end time');
for row = 1:length(handles.video_info{1,1})
%     fprintf(fid,'%s, %s, %s\r\n',handles.video_info{1}{row}(:),datestr(handles.video_info{2}(row)),datestr(handles.video_info{3}(row)));
    fprintf(fid,'%s, %.7f, %.7f\r\n',handles.video_info{1}{row}(:),handles.video_info{2}(row),handles.video_info{3}(row));
end
fclose(fid);

set(hObject,'String','0');

% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function video_offset_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to video_offset_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object deletion, before destroying properties.
function data_labeling_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to data_labeling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Store new video start and end time according to video_offset 
% save(handles.video_info_filename, '-struct','handles','video_info');
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


function jump_time_edit_Callback(hObject, eventdata, handles)
% hObject    handle to jump_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jump_time_edit as text
%        str2double(get(hObject,'String')) returns contents of jump_time_edit as a double
global clicked_time_idx;
clicked_time_idx = datenum(strcat(datestr(handles.videostarttime,'dd-mmm-yyyy'),{' '},get(hObject,'String')));
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function jump_time_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jump_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in select_accel_button.
function select_accel_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_accel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global frame;
set(handles.select_video_button,'Enable','off');
set(handles.select_accel_button,'Enable','off');
set(handles.start_pause_button,'Enable','off');
set(handles.begin_button,'Enable','off');
set(handles.end_button,'Enable','off');
%cd 'C:\Dropbox\Rhino Project\Motion Analysis\Metingen Ede\Sensor data';
handles.sensor_folder = get(handles.sensor_folder_edit,'String');
if isempty(handles.sensor_folder)
    warndlg('No sensor data folder selected. Please select sensor data folder.');
    uiwait();
    handles.sensor_folder = uigetdir();
    set(handles.sensor_folder_edit,'String',handles.sensor_folder);
 end

[ accel_file_name,accel_file_path ] = uigetfile({'*.mat'},'Pick an accelerometer file',handles.sensor_folder);      %;*.png;*.yuv;*.bmp;*.tif'},'Pick a file');
if(accel_file_path == 0)
    set(handles.select_video_button,'Enable','on');
    set(handles.select_accel_button,'Enable','on');
    return;
end
handles.input_accel_file = [accel_file_path,accel_file_name];

%load 'C:\Dropbox\Rhino Project\Motion Analysis\Metingen Ede\Sensor data\n99_1_accel.mat';
load(handles.input_accel_file);
accelFileLength = length(timestamp); %200Hz samples -> 5ms per timestamp  100Hz samples -> 10ms per timestamp
% Convert to length in fraction of days
accelFileLength = accelFileLength / handles.sample_rate_sensors / 60 /60 /24;
accelStopTime = datenum(refTime)+accelFileLength;
try
    if(datenum(refTime)>=handles.videostoptime || accelStopTime<=handles.videostarttime)
        errordlg(sprintf(['Video and accelerometer data not in same time scope. \n\n Please select a different video or accelerometer file or change the start time of the video.', ...
            '\n\nThe accelerometer start and stop times are: ',datestr(refTime),' and: ',datestr(accelStopTime)]),'Warning');
         set(handles.select_video_button,'Enable','on');
         set(handles.select_accel_button,'Enable','on');
        return;
    end
catch
    errordlg('Select a video first','No video time information');
    set(handles.select_video_button,'Enable','on');
%    set(handles.select_accel_button,'Enable','on');
%     set(handles.start_pause_button,'Enable','on');
%     set(handles.begin_button,'Enable','on');
%     set(handles.end_button,'Enable','on');
    return;
end

handles.accelRefTime = datenum(refTime);
handles.accelStopTime = accelStopTime;

handles.vector = sqrt(sum([ax ay az].^2,2));

%handles.accelRefTime = datenum('07-Mar-2016 10:19:36');
%accel_times = round((timestamp-timestamp(1)));
%accel_times = 0:handles.accel_tick_size:(length(timestamp)/.2)-handles.accel_tick_size; % time in seconds/seconds
accel_times = 0:handles.accel_tick_size:(length(timestamp)/(handles.sample_rate_sensors/1000))-handles.accel_tick_size;

handles.accel_times = handles.accelRefTime + accel_times/(86400*1e3);
handles.accel_offset = handles.videostarttime - handles.accelRefTime; % offset in fraction of days
% convert fraction of days to ticks
handles.accel_ticks_offset = round(handles.accel_offset * 24 * 60 * 60 * handles.sample_rate_sensors); %ms
% datestr(datenum(refTime),'dd-mm-yyyy HH:MM:SS')
% datestr(accelStopTime,'dd-mm-yyyy HH:MM:SS')
% datestr(handles.videostarttime,'dd-mm-yyyy HH:MM:SS')
% datestr(handles.videostoptime,'dd-mm-yyyy HH:MM:SS')
if(datenum(refTime)>handles.videostarttime)
    % if accel starts later than video, then go to that frame
    handles.startFrame = round(abs(handles.accel_offset * 24*60*60 * handles.video.framerate))+1;
  %  frame = handles.startFrame;
end

handles = loadExistingLabels(accel_file_name,handles);
% if(or(handles.accel_times(1)>handles.videostarttime,handles.accel_times(end)<handles.videostoptime))
%     warndlg('Accelerometer data not available for entire video length','Warning');
% end

set(handles.accel_file_text,'String',strcat('accel:',{' '},accel_file_name(1:end-4)));
set(handles.select_video_button,'Enable','on');
set(handles.select_accel_button,'Enable','on');
set(handles.start_pause_button,'Enable','on');
set(handles.begin_button,'Enable','on');
set(handles.end_button,'Enable','on');
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in begin_button.
function begin_button_Callback(hObject, eventdata, handles)
% hObject    handle to begin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of begin_button
global frame;
frame = handles.startFrame;

% --- Executes on button press in end_button.
function end_button_Callback(hObject, eventdata, handles)
% hObject    handle to end_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of end_button
global frame;
frame = handles.video.NumberOfFrames-150;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function doBeforeClosing(hObject, eventdata, handles) % When close button is pressed
    saveState(handles);




function label_folder_edit_Callback(hObject, eventdata, handles)
% hObject    handle to label_folder_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of label_folder_edit as text
%        str2double(get(hObject,'String')) returns contents of label_folder_edit as a double


% --- Executes during object creation, after setting all properties.
function label_folder_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to label_folder_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function video_folder_edit_Callback(hObject, eventdata, handles)
% hObject    handle to video_folder_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of video_folder_edit as text
%        str2double(get(hObject,'String')) returns contents of video_folder_edit as a double


% --- Executes during object creation, after setting all properties.
function video_folder_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to video_folder_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function saveState(handles)

% state.input_accel_file = handles.input_accel_file;
 state.sensor_folder =  get(handles.sensor_folder_edit, 'string');
 state.label_folder =   get(handles.label_folder_edit,  'string');
 state.video_folder =   get(handles.video_folder_edit,  'string');
 save('state.mat','state');

 
 function loadState(handles)
 filename = 'state.mat';
 if exist(filename,'file')
    load(filename);
    set(handles.sensor_folder_edit, 'string',  state.sensor_folder);
    set(handles.label_folder_edit, 'string',  state.label_folder);
    set(handles.video_folder_edit, 'string',  state.video_folder);
    delete(filename);
 end
 



function sensor_folder_edit_Callback(hObject, eventdata, handles)
% hObject    handle to sensor_folder_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sensor_folder_edit as text
%        str2double(get(hObject,'String')) returns contents of sensor_folder_edit as a double


% --- Executes during object creation, after setting all properties.
function sensor_folder_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensor_folder_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close data_labeling.
function data_labeling_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to data_labeling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveState(handles);
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in label_folder_push.
function label_folder_push_Callback(hObject, eventdata, handles)
% hObject    handle to label_folder_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.label_folder = uigetdir(get(handles.label_folder_edit,'String'));
 set(handles.label_folder_edit, 'string',  handles.label_folder);

% --- Executes on button press in video_folder_push.
function video_folder_push_Callback(hObject, eventdata, handles)
% hObject    handle to video_folder_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = uigetdir(get(handles.video_folder_edit,'String'));
if answer == 0 
    return
end
handles.video_folder = answer;
 set(handles.video_folder_edit, 'string',  handles.video_folder);

% --- Executes on button press in sensor_folder_push.
function sensor_folder_push_Callback(hObject, eventdata, handles)
% hObject    handle to sensor_folder_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.sensor_folder = uigetdir(get(handles.sensor_folder_edit,'String'));
 set(handles.sensor_folder_edit, 'string',  handles.sensor_folder);


% --- Executes on button press in modify_video_time.
function modify_video_time_Callback(hObject, eventdata, handles)
% hObject    handle to modify_video_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
video_info_formatSpec = '%q%.7f%.7f%[^\n\r]';
handles.label_folder = get(handles.label_folder_edit,'String');
if isempty(handles.label_folder)
    warndlg('No label folder selected. Please select label folder.');
    uiwait();
    handles.label_folder = uigetdir();
    set(handles.label_folder_edit,'String',handles.label_folder);
end
handles.video_info_filename = [handles.label_folder,'\video_time_sync_info.csv'];
try
%     formatSpec = '%q%D%D%[^\n\r]';
    fileID = fopen(handles.video_info_filename,'r');
    delimiter = ',';
    handles.video_info = textscan(fileID, video_info_formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', false);
    fclose(fileID);
catch
    %% do something
    warndlg('No video time information specified. Please add video_time_sync_info.csv to label folder.');
    return;
end
        
% video_info.Properties.VariableNames{'Var1'} = 'name';
% video_info.Properties.VariableNames{'Var2'} = 'start_time';
% video_info.Properties.VariableNames{'Var3'} = 'stop_time';
% Find the correct video
idx = strfind(handles.video_file_name,'.');
handles.videoindex = find(strcmp(handles.video_file_name(1:idx-1), handles.video_info{1,1}));
if(isempty(handles.videoindex))
    warndlg('Video not found in video_time_sync_info.csv. Add video first.');
    % Choose default command line output for data_labeling
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    return; 
end
% handles.videostarttime = datenum(handles.video_info{1,2}(handles.videoindex));
% handles.videostoptime = datenum(handles.video_info{1,3}(handles.videoindex));
handles.videostarttime = handles.video_info{1,2}(handles.videoindex);
handles.videostoptime = handles.video_info{1,3}(handles.videoindex);

% start = datenum(answer{1});
%     duration = datenum(strcat('00-000-0000',{' '},answer{2}));
%     fid=fopen(handles.video_info_filename,'a');
%     fprintf(fid,'%s, %.7f, %.7f\r\n',video_file_name(1:idx-1),start,start+duration);


duration = handles.videostoptime-handles.videostarttime;
 prompt = {'Video Start Time: dd-mmm-yyyy HH:MM:SS','Video duration: HH:MM:SS'};
    dlg_title = 'Please enter video information';
    num_lines = 1;
    defaultans = {datestr(handles.videostarttime,'dd-mmm-yyyy HH:MM:SS'),datestr(duration,'HH:MM:SS')};%datestr(now,'HH:MM:SS')
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    start = datenum(answer{1});
    handles.video_info{1,2}(handles.videoindex) = round(start,7);
    handles.videostarttime =start;
    duration = datenum(strcat('00-000-0000',{' '},answer{2}));
    handles.video_info{1,3}(handles.videoindex) = round(start+duration,7); %stop time
    handles.videostoptime = start+duration;
    vinfo = table(handles.video_info{1,1}(:),handles.video_info{1,2}(:),handles.video_info{1,3}(:));
    writetable(vinfo,handles.video_info_filename);
%     fid=fopen(handles.video_info_filename,'w+');
% %     fprintf(fid,'%s, %.7f, %.7f\r\n',handles.video_file_name(1:idx-1),start,start+duration);
%     [nrows,ncols] = size(handles.video_info);
%     for row = 1:nrows
%         fprintf(fid,'%s, %.7f, %.7f\r\n',handles.video_info{row,:});
%     end
%     fclose(fid);
set(handles.vid_start_text,'String',['Start: ',datestr(handles.videostarttime,'HH:MM:SS')]);
set(handles.vid_stop_text,'String',['Stop: ',datestr(handles.videostoptime,'HH:MM:SS')]);
set(handles.video_file_text,'String',['Current video file: ',handles.video_file_name(1:idx-1)]);
handles.video_length =  handles.videostoptime-handles.videostarttime;

%set(handles.video_offset_edit,'String',datestr(handles.video_offset,'HH:MM:SS'));
try
    handles.accel_offset = handles.videostarttime - handles.accelRefTime; % offset in fraction of days
    % convert fraction of days to ticks
    handles.accel_ticks_offset = round(handles.accel_offset * 24 * 60 * 60 * handles.sample_rate_sensors); %ms
catch e
    handles.accel_offset = 0;
    handles.accel_ticks_offset = 0;
end
% Choose default command line output for data_labeling
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
