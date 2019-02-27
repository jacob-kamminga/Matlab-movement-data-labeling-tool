%import horsedata
close all;
clear all;

% folder = 'F:\Measurements Horstlinde\25-4-2018\Sensordata\11. Clever\';
% 
% cd(folder);
% files = dir('*.csv');
% %filename = 'Data-002.csv';
d=uigetdir('C:\Users\lieke\OneDrive\Documenten\Studie\Module 12\Measurements Horstlinde\15-05-2018'); %select the input-folder that contains the subfolders
cd(d);
list = dir;
list = list([list.isdir]); 
list = list(~ismember({list.name},{'.' '..'}));
l=length(list);
for i=1:l
    oldfolder = cd(list(i).name);
    files = dir('*.csv');
    for file = files'
        folder=[file.folder,'\'];
        filename=file.name;
        % Get time reference
        fileID = fopen ([folder,filename]);
        if fileID ~= -1
          for n=1:1 % skip n lines
            fgetl (fileID);
          end
          % get SN from sensor
          line = fgetl(fileID);
          t=textscan(line,'%s %s %s %s %s %s %s %s');
          sensor_SN = t{8}{:};
          SrefTime = fgetl (fileID);
          SrefTime = SrefTime(14:end);
          refTime = datenum(SrefTime,"yyyy-mm-dd, HH:MM:SS.FFF");
          fclose (fileID);
        else
            continue;
        end

        % Get data
        data = readtable([folder,filename],'Delimiter', ',', 'Format', '%f%f%f%f%f%f%f%f%f%f%f','CommentStyle',';');
        data.Properties.VariableNames = {'Time', 'Ax', 'Ay','Az', 'Gx', 'Gy', 'Gz', 'Mx', 'My', 'Mz', 'T'};

        %% Convert accelerometer data to m/s? 
        data.Ax = data.Ax*9.807/4096; %See GCDC_HAM_User manual page 23
        data.Ay = data.Ay*9.807/4096;
        data.Az = data.Az*9.807/4096;
        data.vector = sqrt(sum([data.Ax data.Ay data.Az].^2,2)); 

        %% Convert gyroscope data to ?/s
        data.Gx = data.Gx/16.384;
        data.Gy = data.Gy/16.384;
        data.Gz = data.Gz/16.384;

        %% Convert magnetometer data to ?T (micro Tesla)
        data.Mx = data.Mx/3.413;
        data.My = data.My/3.413;
        data.Mz = data.Mz/3.413;

        %% Convert temperature data to ?C
        data.T = data.T/1000;
        filepath = [folder,datestr(refTime,'yyyymmdd_HH-MM-SS'),'.mat'];
        horse_name = list(i).name;
        
        save(filepath,'data','file','horse_name','refTime','SrefTime','sensor_SN');
    end
      cd(oldfolder); 
end









