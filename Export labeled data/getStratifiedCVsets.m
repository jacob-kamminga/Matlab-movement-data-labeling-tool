function CV = getStratifiedCVsets(cat_vec,nfolds)
% This function partitions categories in cat_vec in test, cv, and train sets 
% Sampling is always stratified
% Each partition is divided into nfolds
% The numbers in CV are indices of cat_vec
% The indices are randomly shuffled before partitioning
% Author: Jacob Kamminga 18-06-2018

categories = unique(cat_vec);
ncats = numel(categories);
CV.test=cell(1,nfolds); 
CV.cv=cell(1,nfolds); 
CV.train=cell(1,nfolds); 
    
for i=1:ncats
    indices=find(cat_vec==categories(i))';
    % Randomly reorder the indices
    randidx = randperm(length(indices));
    indices=indices(randidx);
    total_rows = length(indices);
    if total_rows<nfolds 
        % not enough for training, dump these few items in test sets of all
        % folds
        for k=1:nfolds
            CV.test{k}=[CV.test{k},indices];
        end
        warning('Not sufficient data of class: %s for %i folds. Only testing data for this class',categories(i),nfolds);
        continue;
    end
    training_rows_per_fold = floor(total_rows/nfolds);
    for k=1:nfolds
        from_test =((k-1)*training_rows_per_fold+1);
        to_test = from_test+training_rows_per_fold-1;
        CV.test{k} = [CV.test{k},indices(from_test:to_test)];
        from_cv = to_test+1; 
        if(from_cv>=total_rows)
            from_cv=1;
        end
        % Use mod to check for loop around (should happen at last fold)
        to_cv = mod(from_cv + training_rows_per_fold-1,total_rows);
        if(to_cv<from_cv)
            cvind = [from_cv:total_rows,1:to_cv];
        else
            cvind = from_cv:to_cv;
        end
        CV.cv{k} = [CV.cv{k},indices(cvind)];
        train = indices;
        % train indices are all the remaining indices
        train([from_test:to_test,cvind]) = [];
        CV.train{k} = [CV.train{k},train];
    end
end

for fold=1:nfolds
%     figure;
%     subplot(3,1,1);
%     histogram(cat_vec(CV.train{1,fold}));
%     grid minor;
%     subplot(3,1,2);
%     histogram(cat_vec(CV.cv{1,fold}));
%     grid minor;
%     subplot(3,1,3);
%     histogram(cat_vec(CV.test{1,fold}));
%     grid minor;
    a=(CV.train{1,fold});
    b=(CV.cv{1,fold});
    c=(CV.test{1,fold});
    d=[a,b,c];
    assert(isequal(sort(cat_vec(d)),sort(cat_vec))); % verify that no segments were lost
end

CV.NumTestSets = nfolds;


end