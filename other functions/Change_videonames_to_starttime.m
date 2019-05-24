clear all;
close all;
%Change name of all videos in a folder to their starttime
d=uigetdir('F:\Measurements Horstlinde','Select video folder'); %select the input-folder that contains the subfolders
% d='F:\Measurements Horstlinde\25-04-2018\Videos\LD';
cd(d);
files = dir();
logid = fopen([d,'\name_change_log.txt'],'a');
fprintf(logid,'Filenames have been changed on: %s \n\n',datestr(now(),'dd-mm-yyyy HH:MM:SS'));

for file = files'
    if file.isdir 
        continue 
    end
    try
        videoobject = VideoReader(file.name);
    catch
        continue;
    end
    fi = dir([file.folder,'\',file.name]);
    endtime = fi.datenum;
    %% Enter camera offset here if needed
    camera_offset = 0;
%    camera_offset = hours(1); % Camera had hour offset on 24-04-2018;
    starttime = endtime - seconds(videoobject.duration) + camera_offset; 
    new_filename = [datestr(starttime,'yyyymmdd_HH-MM-SS'),file.name(end-3:end)];
    if ~strcmp(file.name,new_filename)
        movefile(file.name,new_filename);
        fprintf('Changed `%s` to `%s`\n',file.name,new_filename);
        fprintf(logid,'Changed `%s` to `%s`\n',file.name,new_filename);
    end
end

fclose(logid);