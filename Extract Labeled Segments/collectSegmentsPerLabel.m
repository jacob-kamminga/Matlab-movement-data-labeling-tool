function segments = collectSegmentsPerLabel(label_filepath,sensor_filepath,srs,max_lenght_segments,filter)
%% Grab all label files
cd(label_filepath); 
files = dir('*.csv');
labellist = cell2table({0,'labelname','hID'},'VariableNames',{'time','label','hID'});
labellist(1,:)=[];

for file = files'
    try
        hID = getHorseID(file.name);
        l = readtable(file.name);
        hc = cell2table(repmat({hID},height(l),1),'VariableNames',{'hID'});
        labellist = [labellist;l,hc];
    catch e
       warning(['Problem reading ',file.name]); %' error: ',e.message
    end
end
% readable_labels=datestr(sortrows(labellist.G1,1),'dd/mm/yyyy HH:MM:ss');
%save('labellist.mat','labellist');
% load('labellist.mat','labellist');

%labeloptions = readtable([label_filepath,'/label_options.csv'],'ReadVariableNames',false);

%% Grab all sensor data files
pos=cell2struct(cell(6,1),{'A','B','C','D','E','F'},1);
segments = {};% struct('G1',pos,'G2',pos,'G3',pos,'G4',pos);
cd(sensor_filepath); 
files = dir('*.mat');
for file = files'
    
    ret = getSegmentsPerLabel(file.name,labellist,srs,max_lenght_segments);
    
    if isstruct(ret)
        if filter
            %% Filter amount of sensors
            % only select the sensors you want
            ret = selectSensorSubset(ret);
        end
        if isempty(segments)
            segments = ret;
        else
           segments = concatSegments(segments,ret);
        end
    end
end
%% Save in sensor data folder of this day
% only used for visual inspection (see Dropbox\Measurements Enschede\Data Labelling App\visualize data for checking labels\visualize_labeled_data_v3.m)
%save([sensor_filepath,'\segmentsPerLabel.mat'],'segments');

end


function ret = selectSensorSubset(segments)
    ret=struct();
    label_fields = fields(segments);
    for i=1:length(label_fields)
        if isstruct(segments.(label_fields{i}))
            %% add sensors you want here 
%             ret.(label_fields{i}).accel_3dvector_norm = segments.(label_fields{i}).accel_3dvector_norm; 
%             ret.(label_fields{i}).gyro_3dvector_norm = segments.(label_fields{i}).gyro_3dvector_norm;
        else
%             ret.(label_fields{i}) = {};
        end
    end
end
