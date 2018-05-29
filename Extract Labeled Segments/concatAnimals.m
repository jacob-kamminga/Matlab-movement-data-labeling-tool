function concattedAnimals = concatAnimals(segmentsPerLabel1,segmentsPerLabel2)

pos_fields = fieldnames(segmentsPerLabel1);
pos_fields2 = fieldnames(segmentsPerLabel2);
nr_of_pos = length(pos_fields);
nr_of_pos = length(pos_fields2);

if(nr_of_pos~=nr_of_pos)
    error('Segments don`t have same structure');
end

try
    for i=1:nr_of_pos
        if isstruct(segmentsPerLabel1.(pos_fields{i}))
            label_fields = fieldnames(segmentsPerLabel1.(pos_fields{i}));
        elseif isstruct(segmentsPerLabel2.(pos_fields{i}))
            label_fields = fieldnames(segmentsPerLabel2.(pos_fields{i}));
        else
            concattedAnimals.(pos_fields{i}) = {};
            continue;
        end
        
        nr_labels = length(label_fields);
        for j=1:nr_labels
            try
                sensor_fields = fieldnames(segmentsPerLabel1.(pos_fields{i}).(label_fields{j}));
            catch
                try
                    sensor_fields = fieldnames(segmentsPerLabel2.(pos_fields{i}).(label_fields{j}));
                catch
                    concattedAnimals.(pos_fields{i}).(label_fields{j}) = {};
                    continue;
                end
            end

            nr_sensors = length(sensor_fields);
            for k=1:nr_sensors
                try
                    segments1 = segmentsPerLabel1.(pos_fields{i}).(label_fields{j}).(sensor_fields{k});
                catch
                    segments1 = {};
                end
                try
                    segments2 = segmentsPerLabel2.(pos_fields{i}).(label_fields{j}).(sensor_fields{k});
                catch
                    segments2 = {};
                end
                    concattedAnimals.(pos_fields{i}).(label_fields{j}).(sensor_fields{k}) = [segments1,segments2];
            end
        end
    end
catch e
    error(['Something went wrong while concatting segments: ' ,e.message]);
    concattedAnimals = {};
end


