close all;
clear all;
dbstop if error;

%% File names and variables
% sensordata_file_path= 'D:\Measurements Enschede\7-8-2017\Sensordata\';
% label_file_path = 'C:\Dropbox\Measurements Enschede\Labels\';
dates = {'7-8-2017';'8-8-2017';'9-8-2017';'10-8-2017';'14-8-2017';'16-8-2017'};
label_filepath='C:\Dropbox\Measurements Enschede\Labels';

goatIDs = {'fG1','fG2','fG3','fG4'};
srs = 100; % Sampling Rate Sensors (Hz)
max_lenght_segments = 10; %sec
pos_ids={'A','B','C','D','E','F'};
pos=cell2struct(cell(6,1),pos_ids,1);
segments=struct;
fG1=pos;fG2=pos;fG3=pos;fG4=pos;
%% Collect Segments Per Label
for d=1:size(dates,1)
    % for each date
    sensordata_filepath=['F:\Measurements Enschede\',dates{d},'\Sensordata']
    filter=true
    % this function saves the segments per goat
    segments = collectSegmentsPerLabel(label_filepath,sensordata_filepath,srs,max_lenght_segments,filter);
    fG1 = concatAnimals(fG1,segments.G1);
    fG2 = concatAnimals(fG2,segments.G2);
    fG3 = concatAnimals(fG3,segments.G3);
    fG4 = concatAnimals(fG4,segments.G4);
end

for k=1:4
    G=eval(goatIDs{k});
    % Due to limited memory size we need to store datasets per position of
    % each goat (this contains all data over multiple days).
    A=G.A; B=G.B; C=G.C; D=G.D; E=G.E; F=G.F;
    for i=1:6
        save(['F:\Measurements Enschede\Aggregated Data_2\segments_',goatIDs{k},'_',pos_ids{i},'.mat'],pos_ids{i});
    end
end


%% Do the k-fold thing

%moved to separate file, see do_the_kfold_thing.m