clear all
close all
dbstop if error
addpath('.'); % add current folder to Matlab Search Path
% rng('shuffle');
rng('default'); 
rng(2018); % Seed random generator

%% Setup
label_filepath='C:\Dropbox\Measurements Horstlinde\Labels';
sensor_data_filepath='F:\Measurements Horstlinde\'; 
% sensor_data_filepath='F:\debug\'; 
outputfolder = 'F:\Representation learning\with_features\horses\statistical\';
% outputfolder = 'C:\Users\kammingajw\stack\Metingen Horstlinde\';
logtablepath = [outputfolder,'data_class_size_overview.xlsx'];
logTable = cell2table(cell(0,5),'VariableNames',{'ID','Fold','Type','Class','Size'});
% log_fID = fopen([outputfolder,'data_generation_log.txt'],'w');
% if log_fID <= 0
%    error('Could not open log file');
% end

nr_folds=3;
overlap=0.5; % Window overlap in percentage (0 - 1)
window_size=2; % sec
max_seg_l= inf; %10; % Maximum length of segments (sec)
% selected_columns={'Ax','Ay','Az','Gx','Gy','Gz','Mx','My','Mz'};
selected_columns={};
% column_fs = [100,100,100,100,100,100,12,12,12]; % sampling rate (Hz) per column
column_fs = [100]; % sampling rate (Hz) per column
generate_columns={'A_3D'};%,'G_3D','M_3D','ODBA'}; % These will be generated, must be specified by user..
% column_fs = [column_fs,100,100,12,100]; % sampling rate (Hz) for generated columns
% generate_columns={};
assert(size(column_fs,2)==size([selected_columns,generate_columns],2));
% features that should be calculated (must be implemented in calcFeatures.m)
selected_features={'max','min','mean','std','median','twenty_fith_p','seventy_fith_p','mean_DC', ...
    'mean_AC','skew','kurtosis','zcr','principal_freq','spectral_energy','freqEntropy','mag_1',...
    'mag_2','mag_3','mag_4','mag_5','mag_6'};  
% selected_features={'max'};  

%% Grab all labels
labellist = getLabellist(label_filepath);
save([label_filepath,'\labellist.mat'],'labellist');
% load([label_filepath,'\labellist.mat'],'labellist');

try 
     load([outputfolder,'\datatable.mat']);
     warning('Not creating new datatable, using stored file!');
catch

    %% Iterate over all data folders and aggregate data for each horse
    % Get all date folders
    cd(sensor_data_filepath);
    dates_list = dir;
    dates_list = dates_list([dates_list.isdir]); 
    dates_list = dates_list(~ismember({dates_list.name},{'.' '..'}));
    segments=struct();
    datatable=[];
    segctr=1;
    for j=1:length(dates_list) % loop over date folders
        main_folder = cd(dates_list(j).name); % cd to date
        if(isdir('./Sensordata'))
            cd('Sensordata');
        else
        	warning('folder Sensordata not found in: %s',dates_list(j).name);
        	continue;
        end
        % Get all horse folders for this day
        horses_list = dir;
        horses_list = horses_list([horses_list.isdir]); 
        horses_list = horses_list(~ismember({horses_list.name},{'.' '..'}));
        l=length(horses_list);
        for i=1:length(horses_list) % loop over all horse folders

            idx=regexp(horses_list(i).name,'\w*');
            horsename=horses_list(i).name(idx(end):end);
%             if ~strcmp(horsename,'Happy')
%                 warning('Skipping: %s',horsename);
%                 continue;
%             end
    %         if (sum(strcmp(labellist.hID,horsename))>0) % Skip folder if this
                oldfolder = cd(horses_list(i).name); 
                files = dir('*.mat');
                for file = files' % loop over all files
                    [data,segctr]=createDataTable(file.name,selected_columns,generate_columns,labellist,label_filepath,max_seg_l,segctr);
                    if istable(data)
                        if isfield(datatable,horsename)
                            datatable.(horsename) = [datatable.(horsename);data];
                        else
                             datatable.(horsename) = data;
                        end
                        seg_idx=unique(datatable.(horsename).segment);
                        for d=1:length(seg_idx)
                            l=unique(datatable.(horsename).label(datatable.(horsename).segment==seg_idx(d)));
                            assert(size(l,1)==1&&size(l,2)==1);
                        end
                    end
                end
    %             if istable(datatable.(horsename))
    %                
    %             end
                cd(oldfolder);
    %         end
        end
        cd(main_folder); % cd back to main folder
    end
   save([outputfolder,'\datatable.mat']);
end


%% Loop over all horse datatables
horsefields = fields(datatable);
for hid = 1:length(horsefields)

    %% Generate crossvalidation partitions based on segments
    % first compress 
    segnrs=unique(datatable.(horsefields{hid}).segment);
    T=table();
    T.label = datatable.(horsefields{hid}).label;
    T.segment = datatable.(horsefields{hid}).segment;
    T = varfun(@mean,datatable.(horsefields{hid})(:,{'label','segment'}),'GroupingVariables',{'label','segment'}); %GroupCount variable is length of each segment
    T = T(T.GroupCount>=window_size*max(column_fs),:); % Keep only segments that are larger than windowsize
    % c = cvpartition(T.label,'KFold',5); % create fold indices
    CV = getStratifiedCVsets(T.label,nr_folds);

    %% Calculate features for this horse
    [featureTable, tloss] =  calcFeatures(datatable.(horsefields{hid}), T, window_size, column_fs, overlap, selected_features,[selected_columns,generate_columns]);
     
    %% Split features per fold
    for fold=1:nr_folds
        % Collect the segment numbers for this fold
        trainsegments = T.segment(CV.train{1,fold});
        cvsegments = T.segment(CV.cv{1,fold});
        testsegments = T.segment(CV.test{1,fold});
        lt=height(T);
        fprintf('%s fold: %i\n',horsefields{hid},fold);
        fprintf('Ratio train: %.2f%%\n',round(length(trainsegments)/lt*100,2));
        fprintf('Ratio cv: %.2f%%\n',round(length(cvsegments)/lt*100,2));
        fprintf('Ratio test: %.2f%%\n\n',round(length(testsegments)/lt*100,2));
        
        trainFeatureTable = featureTable(ismember(featureTable.segment, trainsegments),:);
        cvFeatureTable =  featureTable(ismember(featureTable.segment, cvsegments),:);
        testFeatureTable =  featureTable(ismember(featureTable.segment, testsegments),:);
        
%         loss=zeros(1,3);
%         [trainFeatureTable,loss(1)] = calcFeatures(datatable.(horsefields{hid}),trainsegments,window_size,column_fs,overlap,selected_features,[selected_columns,generate_columns]);
        logTable = printClassSizes(logTable,fold,horsefields{hid},'train',trainFeatureTable.label);
%         [cvFeatureTable,loss(2)] = calcFeatures(datatable.(horsefields{hid}),cvsegments,window_size,column_fs,overlap,selected_features,[selected_columns,generate_columns]);
        logTable = printClassSizes(logTable,fold,horsefields{hid},'cv',cvFeatureTable.label);
%         [testFeatureTable,loss(3)] = calcFeatures(datatable.(horsefields{hid}),testsegments,window_size,column_fs,overlap,selected_features,[selected_columns,generate_columns]);
        logTable = printClassSizes(logTable,fold,horsefields{hid},'test',testFeatureTable.label);
%         tloss=sum(loss); % total loss in samples (due to non fitting windows)
        fprintf('%i seconds of data was lost in total. Bigger segment size decreases loss.\n',round(tloss/max(column_fs)));
        xlsx_output_file_path = [outputfolder,horsefields{hid}]
        % Create directory when it doesn't exist
        if ~exist(xlsx_output_file_path, 'dir')
        	mkdir(xlsx_output_file_path);
        end

        xlsx_output_file_path=[xlsx_output_file_path,'\fold_',num2str(fold)];

        delete([xlsx_output_file_path,'_training.xlsx']);
        writetable(trainFeatureTable,[xlsx_output_file_path,'_training.xlsx']);
        delete([xlsx_output_file_path,'_crossval.xlsx']);
        writetable(cvFeatureTable,[xlsx_output_file_path,'_crossval.xlsx']);
        delete([xlsx_output_file_path,'_test.xlsx']);
        writetable(testFeatureTable,[xlsx_output_file_path,'_test.xlsx']);

%         total_datapoints = height(trainFeatureTable);
%         total_datapoints = total_datapoints+height(cvFeatureTable);
%         total_datapoints = total_datapoints+height(testFeatureTable);

        % Check data loss
        % Worst case is all segments have window_size-1 samples loss
        wc = lt*(window_size*max(column_fs)-1);
%         wcs = wc/(window_size*max(column_fs)); % worst case of lost number datapoints
%         expected = (height(datatable.(horsefields{hid}))-tloss) / (window_size*max(column_fs)*overlap);
%         assert(expected-total_datapoints == 0,'There are %i datapoints unaccounted for',expected-total_datapoints);
        assert(tloss<=wc,'Data loss is higher than worst case. loss: %d worst case: %d',tloss,wc);
    end
   
   
end
% fclose(log_fID);
 writetable(logTable,logtablepath);


function logTable = printClassSizes(logTable,fold,ID,type,cat_vec)
    cats=categories(cat_vec);
    catcounts = countcats(cat_vec);
    for i=1:length(cats)
%         fprintf(logTable,'%s has %i datapoints of class `%s` in %s\n',ID,catcounts(i),cats{i},type);
        logTable = [logTable; {ID,fold,type,cats{i},catcounts(i)}];
    end
end

