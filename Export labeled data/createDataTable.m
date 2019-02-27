function [data,segctr] = createDataTable(input_sensor_file,selected_columns,generate_columns,labellist,label_filepath,max_seg_l,segctr)
% Create a table from raw sensor data and a list of labels
% The data is divided into segments with a length of max_seg_l (Seconds)
% All data that has no label information is labeled as 'unknown'
    %% Load Accelerometer data
    input = load(input_sensor_file);
    srs=100; %Hz, sample rate sensors (should be inside input or sensor object)
    try
        inputHeight = height(input.data); 
        meta=[];%{'label','segment'};
        data =  cell2table(cell(inputHeight,size(selected_columns,2)+size(generate_columns,2)+size(meta,2)), 'VariableNames', [meta,selected_columns,generate_columns]);
        for i=1:size(selected_columns,2)
           data.(selected_columns{i}) = input.data.(selected_columns{i});
        end
    catch e
        e.message
        data = 0;
        return
    end
    %% Generate additional dimensions
    % Add dimension generation here
    for i=1:size(generate_columns,2)
        switch generate_columns{i}
            case 'A_3D'
                data.A_3D = sqrt(sum([input.data.Ax input.data.Ay input.data.Az].^2,2));
            case 'G_3D'
                data.G_3D = sqrt(sum([input.data.Gx input.data.Gy input.data.Gz].^2,2));
            case 'M_3D'
                data.M_3D = sqrt(sum([input.data.Mx input.data.My input.data.Mz].^2,2));
            case 'C_3D'
                data.M_3D = sqrt(sum([input.data.cx input.data.cy input.data.cz].^2,2));
            case 'ODBA'
                % derivation of overall dynamic body acceleration (odba)
                Axdyn = input.data.Ax-movmean(input.data.Ax,srs);
                Aydyn= input.data.Ay-movmean(input.data.Ay,srs);
                Azdyn = input.data.Az-movmean(input.data.Az,srs);
                data.ODBA=abs(Axdyn)+abs(Aydyn)+abs(Azdyn);
            otherwise
                error('Please provide a function that generates column `%s`',generate_columns{i});
        end
    end

    fileLength = inputHeight / srs / 60 /60 /24; % convert to matlab time spec (frac of day)
    accelStopTime = datenum(input.refTime)+fileLength;
    accelRefTime = datenum(input.refTime);
    accel_tick_size = 1000/srs; %ms
    accel_times = 0:accel_tick_size:(height(data)/(srs/1000))-accel_tick_size;
    %% Load labels
    try
        IDTABLE = readtable([label_filepath,'\IDTABLE.csv']);
        hID = IDTABLE.name(strcmp(IDTABLE.SN,input.sensor_SN(4:end)));
        hID=hID{1};
    catch e
       error('Please provide IDTABLE in label folder. Error: %s',e.message); 
    end
    labellist.str_time = datestr(labellist.time,'yyyymmdd_HH:MM:SS');
    %fprintf('startime %s\n',datestr(accelRefTime,'yyyymmdd_HH:MM:SS'));
    %fprintf('stoptime %s\n',datestr(accelStopTime,'yyyymmdd_HH:MM:SS'));

    % Grab all labels that are between start and stop of this file
    local_labels = labellist(labellist.time>=accelRefTime & labellist.time<=accelStopTime & strcmp(labellist.hID,hID), :);
    if size(local_labels,1) <= 1
        if fileLength*24*60 > 5  % Show warning if file is longer than 5 min.
            warning(['Less than 1, or no, labels found for file and file is longer than 5min. ', input_sensor_file]);
        end
        data = 0;
        return
    end
    %% Get label ticks
    local_labels.label_ticks = local_labels.time - accelRefTime;
    local_labels.label_ticks =round(local_labels.label_ticks * 24 * 60 * 60 * srs);
    local_labels = sortrows(local_labels);
    %% Add labels and segments to data table
    max_seg_l = max_seg_l*srs;
    data.label(:)= {'unknown'}; % initialize all labels as unknown
    data.segment(:) = 0;%repmat(0,inputHeight,1); % intialize all segments as 0
    
    for i=1:height(local_labels)
        % If this is the last label, the end will have to be the end of the
        % file
        if i==height(local_labels)
            from=local_labels.label_ticks(i);
            to=inputHeight;
        else
            from=local_labels.label_ticks(i);
            to=local_labels.label_ticks(i+1);
        end
        if from==0
            from=1;
        end
        fieldname = strrep(local_labels.label{i},'-','_');
        data.label(from:to)=local_labels.label(i);

        seg_l = to-from;
        if (seg_l > max_seg_l) % split into smaller segments
            sticks=from:max_seg_l:to;
            if sticks(end)<to
                sticks(end+1)=to; % cover the last bit
            end
            for j=1:length(sticks)-1
                data.segment(sticks(j):sticks(j+1))= segctr; 
                segctr=segctr+1;
            end
        else % take the whole segment
            data.segment(from:to)= segctr;
            segctr=segctr+1;
        end

    end
    % split remaining segments (numbered 0) into smaller segments
    [row col] = find(data.segment==0); % get all indices
    a=diff(row);
    b=find(a>1); %endpoint indices

    if(isempty(b))
        % this is one continuous segment
        remainder = [row(1) row(end)];
    else % these are multiple sequences
        b=[b length(row)]; % add last endpoint
        c=diff(b); % get the lengths of sequences
        c=[b(1) c]; % add the first length
        d=b-c+1; % get the start indices
        remainder = [d' b'];
    end
    for i=1:size(remainder,1) % iterate over all from and to indices
        sticks=remainder(i,1):max_seg_l:remainder(i,2); % from:inc:to
            if sticks(end)<remainder(i,2)
                sticks(end+1)=remainder(i,2); % cover the last bit
            end
            for j=1:length(sticks)-1
                data.segment(sticks(j):sticks(j+1))= segctr;
                segctr=segctr+1;
            end
    end
    data.label=categorical(data.label);
    
    
    
    
    
end