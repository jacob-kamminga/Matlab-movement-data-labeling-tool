function result = addSegment(input,data,max_seg_length,label)
    
    result = input;
    seg_length = height(data);
    st = seg_length;
    
    
    %% Recursively split segments until segments are smaller than max_seg_length
    if seg_length > max_seg_length
        %disp(['Splitting ' num2str(seg_length) ' max: ' num2str(max_seg_length)]);
        % Will diving the segment in half be sufficient?
%         if seg_length/2 <= max_seg_length 
            st = round(seg_length/2); % split tick
            result = addSegment(result,data(1:st,:),max_seg_length,label);
            st=st+1;
            result = addSegment(result,data(st:end,:),max_seg_length,label);
            %         else
            
%         end
    else
    
    try
        seg_nr = size(result.data,2)+1; % current segment
    catch
        seg_nr = 1;
        result.data = {};     
    end
        %data.segment = repmat(seg_nr,height(data),1);
        %data.label = repmat(label,height(data),1);
        result.data{seg_nr} = data;
    end
end