function segmentsPerLabel = getSegmentsPerLabel(input_sensor_file,all_labels,sample_rate_sensors,max_lenght_segments)
segmentsPerLabel=struct();
% Aggregate sensor data per label indicated in label file.
IDTABLE = cell2table({
'Viva',	'CCDC3016AE9D6B4';
'Driekus',	'CCDC3016C04F558';
'Galoway',	'CCDC301688BDC0C';
'Barino',	'CCDC3016A3F89FE';
'Zonnerante',	'CCDC301653728E4';
'Patron',	'CCDC29BCF3C';
'Duke',	'CCDC3016A17897C';
'Porthos',	'CCDC3016401B78B';
'Bacardi',	'CCDC3016FC0FDE2';
'Happy',	'CCDC3016D45EA09';
'Clever',	'CCDC30169DF220E';
'Noortje',	'CCDC3016707B61E';
'Flower',	'CCDC301683589E7';
'Peter Pan',	'CCDC30169E66C48';
'Niro',	'CCDC30164C847DF';
'Sense',	'CCDC301661B33D7';
});
IDTABLE.Properties.VariableNames = {'name','SN'};
%% Max Segment length
% Attempt to improve distribution of samples between training/cv/test datasets
max_seg_length = max_lenght_segments*sample_rate_sensors; %samples

%% Load Accelerometer data
load(input_sensor_file);
try
    accelFileLength = height(data); 
catch e
    segmentsPerLabel = 0;
    return
end
accelFileLength = accelFileLength / sample_rate_sensors / 60 /60 /24;
accelStopTime = datenum(refTime)+accelFileLength;
accelRefTime = datenum(refTime);
%accel_3dvector_norm = sqrt(sum([data.Ax data.Ay data.Az].^2,2));
%accelhg_3dvector_norm = sqrt(sum([axhg ayhg azhg].^2,2));
data.gyro_3dvector = sqrt(sum([data.Gx data.Gy data.Gz].^2,2));
data.compass_3dvector = sqrt(sum([data.Mx data.My data.Mz].^2,2));
accel_tick_size = 1000/sample_rate_sensors; %ms
accel_times = 0:accel_tick_size:(height(data)/(sample_rate_sensors/1000))-accel_tick_size;

%% Load labels
hID = IDTABLE.name(strcmp(IDTABLE.SN,sensor_SN(4:end)));
hID=hID{1};
segmentsPerLabel.hID = hID;
% Grab all labels that are between start and stop of this file
labellist = all_labels(all_labels.time>=accelRefTime & all_labels.time<=accelStopTime & strcmp(all_labels.hID,hID), :);
if size(labellist,1) <= 1
    if accelFileLength*24*60 > 5  % Show warning if file is longer than 5 min.
        warning(['Less than 2, or no, labels found for file and file is longer than 5min. ', input_sensor_file]);
    end
    segmentsPerLabel = 0;
    return
end
%% Get label ticks
labellist.label_ticks = labellist.time - accelRefTime;
labellist.label_ticks =round(labellist.label_ticks * 24 * 60 * 60 * sample_rate_sensors);
labellist = sortrows(labellist);
labellist.label_times = cellstr(datestr(labellist.time,'dd/mm/yyyy HH:MM:ss'));

 
%% Add segment for all sensors per label
if (height(labellist)==1)
    warning(['Only one label in file: ',filename]);
end

for i=1:height(labellist)
    % If this is the last label, the end will have to be the end of the
    % file
    if i==height(labellist)
        from=labellist.label_ticks(i);
        to=accelFileLength;
    else
        from=labellist.label_ticks(i);
        to=labellist.label_ticks(i+1);
    end
    if from==0
        from=1;
    end
    fieldname = strrep(labellist.label{i},'-','_');
    % Did we already see this label before?
    if(isfield(segmentsPerLabel,fieldname))
        % Yes, add to existing field
        segmentsPerLabel.(fieldname) = addSegment(segmentsPerLabel.(fieldname),data(from:to,:),max_seg_length);   
    else
        % No, add new field
        ret =  addSegment({},data(from:to,:),max_seg_length);
        segmentsPerLabel.(fieldname) = ret;
    end
    
end

fieldnames = fields(segmentsPerLabel);
for field=fieldnames'
    if isstruct(segmentsPerLabel.(field{1}))
        % When there is data, store the time information of labels (used in
        % visual check environment)
         fieldname = strrep(field{1},'_','-');
        segmentsPerLabel.(field{1}).times =  cellstr(datestr(labellist.time(strcmp(labellist.label,fieldname)),'HH:MM:SS'))';
    end
end


