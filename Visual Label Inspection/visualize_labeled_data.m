clear all;
close all;
mfilepath = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(mfilepath,'../matlab_scripts')));

addpath(genpath(fullfile(mfilepath))); % add current folder to Matlab Search Path
addpath(genpath(fullfile(mfilepath,'..\other functions')));
addpath(genpath(fullfile(mfilepath,'..\Export labeled data')));

%% Setup
label_filepath='C:\Dropbox\Measurements Horstlinde\Labels';
sensordata_filepath = uigetdir('F:\Measurements Horstlinde\15-05-2018\Sensordata');
% sensordata_filepath = 'C:\Measurements Horstlinde\25-04-2018\Sensordata\12. Noortje';
if  sensordata_filepath == 0
    return
end

srs=100;
max_lenght_segments=1e10;
filter=false;
always_resegment=true;
labellist = getLabellist(label_filepath);
%% Collect segments per activity
if exist([sensordata_filepath,'\segmentsPerLabel.mat'], 'file') == 2 && ~always_resegment
    warning(['Using exisiting sensor data, is this up to date? ',sensordata_filepath]);
    load([sensordata_filepath,'\segmentsPerLabel.mat']);
else
    segments = collectSegmentsPerLabel(labellist,sensordata_filepath,srs,max_lenght_segments,filter);
    if ~always_resegment
        save([sensordata_filepath,'\segmentsPerLabel.mat'],'segments');
    end
end
pos_ids = {'A','B','C','D','E','F'};
srs =100; % Hz
window_width = 60; % Seconds
window_width=window_width*srs;
fn = fields(segments);
nrf=size(fn,1);
nr_graphs=1;
pv=cell(nr_graphs,nrf);
ticks=num2cell(ones(nr_graphs,nrf));
for p=1:nr_graphs
    for j=1:nrf %field=fieldnames'    
     % labellist = sortrows(labellist,1);
         if ~isfield(segments.(fn{j}),'times')
             continue;
         else
            nr_segs = size(segments.(fn{j}).times,2);
         end
        for i=1:nr_segs
            try
               pv{p,j} = [pv{p,j} ; segments.(fn{j}).data{i}.vector];
               ticks{p,j}=[ticks{p,j}; size(pv{p,j},1)];
            catch e
                stop=1;
            end
        end
    end
end

  Pix_SS = get(0,'screensize');
  
for a=1:nrf
    if ~isfield(segments.(fn{a}),'times')
        continue;
    end
    f1=figure('pos',Pix_SS+[50 150 -200 -300]);
    bkclr = get(f1,'Color');
    h = tight_subplot(nr_graphs,1,[.005 .1],[.06 .03],[.015 .015]);
    for i=1:nr_graphs
        if isempty(pv{i,a})
            warning(['No data for: ',segments.hID,' Activity: ',fn{a}]);
            continue;
        end
%         h{i}=subplot(nr_graphs,1,i);
%         axes(ha(i));
        subplot(h(i));
        plot(1:length(pv{i,a}),pv{i,a});
        lengths(i)=length(pv{i,a});
        hold on;
        x = [ticks{i,a}(:,1), ticks{i,a}(:,1)];
        y = repmat([0 60],size(ticks{i,a},1),1);
        plot(x',y');
        text(ticks{i,a}(1:end-1,1),repmat(50,size(ticks{i,a},1)-1,1),segments.(fn{a}).times);
        ylim([0,80]);
        xlim([0,window_width]);
        %title([' Position: ',pos_ids{i},],'VerticalAlignment','top');
        grid('minor');
    end
    set(h,'XTickLabel','');
    bkax = tight_subplot(1,1,[.005 .1],[.06 .03],[.015 .015]); % this creates a figure-filling new axes
    set(bkax,'Xcolor',bkclr,'Ycolor',bkclr,'box','off','Color','none') % make it 'disappear'
    title(sprintf('Horse: %s \t \t Activity: %s',segments.hID ,strrep(fn{a},'_','-')));
%     uistack(bkax,'bottom'); % this moves it to the background.

    % create the slider    
    xmin=0;
    xmax=max(lengths);
    hpos=[0,0,Pix_SS(3)*0.5,30]; %[left bottom width height]
    sl=uicontrol('style','slider','position',hpos, ... % 
    'units','normalized', ...
    'callback',{@onSlider,h},'min',xmin,'max',xmax,'value',0);
    % X label
    hpos=[Pix_SS(3)-500,20,100,30];
    txt = uicontrol('Style','text',...
        'Position',hpos,...
        'String','X limit (sec)');
    % Y label
    hpos=[Pix_SS(3)-600,20,100,30];
    txt = uicontrol('Style','text',...
        'Position',hpos,...
        'String','Y limit m/s^2');
    % create edit button for ylimit
    hpos=[Pix_SS(3)-600,5,100,30];
    uicontrol('style','edit','position',hpos,...
        'callback',{@onEdity,h});
    % create edit button for xlimit
    hpos=[Pix_SS(3)-500,5,100,30];
    uicontrol('style','edit','position',hpos,...
        'callback',{@onEditx,h});
    c=0;
    while c==0
        disp('Press `n` for next activity, `q` to quit');
%         uicontrol(sl); % Put focus on slider
        pause;
        currkey = get(gcf,'CurrentKey');
        c = strcmp(currkey,'n');
        switch currkey
            case 'q'
                close all;
                return;
        end
    end
end

close all

function onSlider(hObject, eventdata, h)
    input=get(hObject,'Value');
    old=round(get(h(1,1),'XLim'));
    window_width=old(2)-old(1);
    set(h,'XLim',[input input+window_width]);
end

function onEdity(hObject, eventdata, h)
    input=str2double(get(hObject,'String'));
    set(h,'YLim',[0 input]);
end

function onEditx(hObject, eventdata, h)
    input=str2double(get(hObject,'String'));
    old=round(get(h(1,1),'XLim'));
    srs =100; % Hz
    window_width=input*srs;
    set(h,'XLim',[old(1,1) old(1,1)+window_width]);
end
