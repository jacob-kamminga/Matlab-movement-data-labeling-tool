function [featureTable,loss] = calcFeatures(inputTable,T,ws,sampling_rates,overlap,selected_features,selected_columns)
% this function calculates all features within the segments with seg_idx
% ws: window size in seconds
featureTable=0;
loss=0;
r=1; %result row counter
% take highest sampling rate (columns with lower fs are assumed to be filled up with NaN for missing values)
window_size=ws*max(sampling_rates); 

% Design filters, we need two filters per different sampling rate
rates=unique(sampling_rates);
for i=1:length(rates)
    lpFilt.(['f_',num2str(rates(i))]) = designfilt('lowpassiir', 'FilterOrder', 20, 'HalfPowerFrequency', .5, 'SampleRate', rates(i), 'DesignMethod', 'butter');
    hpFilt.(['f_',num2str(rates(i))]) = designfilt('highpassiir', 'FilterOrder', 20, 'HalfPowerFrequency', .5, 'SampleRate', rates(i), 'DesignMethod', 'butter');
end
% fvtool(lpFilt);
% res=[];
res = num2cell(zeros(floor(height(inputTable)/(window_size*overlap)),size(selected_columns,2)*size(selected_features,2)+2)); % +2 for label and segment column
header={'label','segment'};
% loop over segments
seg_idx = sort(T.segment);
nsegs=length(seg_idx);
wh = waitbar(0,'Calculating features..','Name','Calculating features');

% figure;
% ax1 = subplot(2,1,1); % top subplot
% ax2 = subplot(2,1,2); % top subplot
% ylim([ax1 ax2],[0,80]);

for i=1:nsegs
   	waitbar(i/nsegs,wh,sprintf('Calculating features.. (%.2f%%)',i/nsegs*100));
    segment = inputTable(inputTable.segment==seg_idx(i),selected_columns);
    %% DEBUG
%     plot(ax1,segment.A_3D);
%     title(ax1,string(unique(inputTable.label(inputTable.segment==seg_idx(i)))));
%     drawnow;
    %%
    sl=height(segment); % segment length
    nr_windows = floor(sl/(window_size*overlap));
    % loop over windows
    for w=1:nr_windows
        if(w==1)
            from = 1;
            to = window_size;
        else
            from = round((w-1)*window_size*overlap);
            to = round(from+window_size-1);
        end
        if(to>sl) % window does not fit in segment
%             skipped_windows=skipped_windows+1
            loss=loss+sl-from;
            continue;
        end
%         l=unique(inputTable.label(inputTable.segment==seg_idx(i)));
%         assert(size(l,1)==1&&size(l,2)==1);
%         l=inputTable.label(inputTable.segment==seg_idx(i));
%         find a single occurence of the label for this segment (the first one)
%         col_row={inputTable.label(find(inputTable.segment==seg_idx(i), 1, 'first'))};

        col_row = {T.label(T.segment==seg_idx(i))};
        col_row=[col_row,{seg_idx(i)}];
       
               
        % loop over columns
        for c=1:size(selected_columns,2)
            window_data = segment.(selected_columns{c})(from:to);
            if(isnan(mean(window_data))) % Some of the sensors have a lower sampling rate, 
                                         % in order to match the other higher sampled data, the missing sampling points are filled with NaN values.
                window_data = window_data(~isnan(window_data));
                window_size_c = length(window_data); % Update window size
%                 Fs=fs*window_size_c/window_size; % Update Fs
            else
                window_size_c = window_size;
            end
%             plot(ax2,window_data);
%             ylim([ax1 ax2],[0,80]);
             
            frow=num2cell(zeros(1,size(selected_features,2)));
            % select filter for this column's sampling rate
            lpFilt_u = lpFilt.(['f_',num2str(sampling_rates(c))]);
            hpFilt_u = hpFilt.(['f_',num2str(sampling_rates(c))]);
            
            % sampling_rates(c) is the fs for this column
            fd = sampling_rates(c)*(0:(window_size/2))/window_size; % Define the frequency domain f
            v = window_data .* hann(length(window_data)); % Apply Hanning window
            FFT = fft(v);
            %Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length window_size.
            P2 = abs(FFT/window_size_c);
            ra = floor(window_size_c/2+1);
            P1 = P2(1:ra);
            P1(3:end-1) = 2*P1(3:end-1); % ?
%             plot(f,P1);
            % Left out DC bin(s) here
            filtered_spectrum = P1;
            filtered_spectrum(1:3) = 0;
            magnitudes = sort(abs(filtered_spectrum),1,'descend'); % Asuming first n components are magnitudes with highest values. LEFT OUT DC BIN!!
            [maxval,idx] = max(abs(filtered_spectrum));
            
            for f=1:size(selected_features,2)
                switch(selected_features{f})
                    case 'max'
                        frow{f} = max(window_data);
                    case 'min'
                        frow{f} = min(window_data);
                    case 'mean'
                        frow{f} = mean(window_data);
                    case 'std'
                        frow{f} = std(window_data);
                    case 'median'
                        frow{f} = median(window_data);
                    case 'twenty_fith_p'
                        frow{f} = prctile(window_data,25);
                    case 'seventy_fith_p'
                        frow{f} = prctile(window_data,75);
                    case 'mean_DC'
                        frow{f} = mean(filter(lpFilt_u,window_data));
                    case 'mean_AC'
                        frow{f} = mean(abs(filter(hpFilt_u,window_data))); % Mean rectified high pass filtered signal (AC) (Fahrenberg et.al)
                    case 'skew'
                        frow{f} = skewness(window_data);
                    case 'kurtosis'
                        frow{f} = kurtosis(window_data);
                    case 'zcr'
                    	zmean = window_data'-mean(window_data);
                        it=1:length(zmean)-1;
                        crs=find ((zmean(it)>0 & zmean(it+1)<0) | (zmean(it)<0 & zmean(it+1)>0));
                        zc = length(crs);
                        frow{f} = round(zc/ws);
                    case 'principal_freq'
                        frow{f} = fd(idx); %the frequency corresponding to max value
                    case 'spectral_energy'
                        P = sum(FFT.*conj(FFT)); % Same output as: sum(abs{f}.^2);
                        frow{f} = P; % Same output as: sum(abs(FFT).^2);
                    case 'freqEntropy'
                        frow{f} = calcEntropy(FFT,window_size_c);
                    case 'mag_1'  
                        frow{f} = magnitudes(1);
                    case 'mag_2'  
                        frow{f} = magnitudes(2);
                    case 'mag_3'  
                        frow{f} = magnitudes(3);
                    case 'mag_4'  
                        frow{f} = magnitudes(4);
                    case 'mag_5'  
                        frow{f} = magnitudes(5);
                    case 'mag_6'  
                        frow{f} = magnitudes(6);
                    otherwise
                        error('Undefined feature: %s',selected_features{f});
                end
            end
          
            col_row = [col_row,frow];
            if(i==1&&w==1)
                str = repmat(selected_columns(c),1,size(selected_features,2));
                str = strcat(str,'_');
                header = [header,strcat(str,selected_features)];
               % header = [header,strcat(selected_features,['_',selected_columns{c}])]; 
            end
        end
        res(r,:)=col_row;
        r=r+1;
    end
end
close(wh);
% Remove leftover rows that do not contain data
idx = cellfun('isclass', res, 'categorical');
res   = res(idx, :);
% Finally, transform into table
featureTable = cell2table(res,'VariableNames',header);
end