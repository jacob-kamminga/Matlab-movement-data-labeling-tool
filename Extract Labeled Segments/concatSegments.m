function concattedAnimals = concatAnimals(Animal1,Animal2)


fields = fieldnames(Animal1);
fields2 = fieldnames(Animal2);
nr_of_labels1 = length(fields);
nr_of_labels2 = length(fields2);

if(nr_of_labels1~=nr_of_labels2)
    error('Segments don`t have same structure');
end

try
    for i=1:nr_of_labels1
        
        if isstruct(Animal1.(fields{i}))
            sensor_fields = fieldnames(Animal1.(fields{i}));
        elseif isstruct(Animal2.(fields{i}))
            sensor_fields = fieldnames(Animal2.(fields{i}));
        else
            concattedAnimals.(fields{i}) = {};
            continue;
        end
        
%         try
%             sensor_fields = fieldnames(segmentsPerLabel1.(fields{i}));
%         catch
%             try
%                 sensor_fields = fieldnames(segmentsPerLabel2.(fields{i}));
%             catch
%                 concattedSegmentsPerLabel.(fields{i}) = {};
%                 continue;
%             end
%         end
        nr_sensors = length(sensor_fields);
        for j=1:nr_sensors
            try
                segments1 = Animal1.(fields{i}).(sensor_fields{j});
            catch
                segments1 = {};
            end
            
            try
                segments2 = Animal2.(fields{i}).(sensor_fields{j});
            catch
                segments2 = {};
            end
                concattedAnimals.(fields{i}).(sensor_fields{j}) = [segments1,segments2];
        end
    end
catch e
    error(['Something went wrong while concatting segments: ' ,e.message]);
    concattedAnimals = {};
end


