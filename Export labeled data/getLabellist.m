% Grab al labels from labels-directory and append into one table
function labellist = getLabellist(label_filepath)
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
end