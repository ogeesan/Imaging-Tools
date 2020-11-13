function data = convert_dffstore(dffdata)
% dffdata can be dffmat (Luca's) or dffarra (George's) format
% this will convert to the other

%%
sizes = size(dffdata);

if any(sizes == 1) % if it's a 1 dimensional cell it's dffarray
    formattype = 'dffarray'; outputtype = 'dffmat';
    nTrials = numel(dffdata);
    nRois = size(dffdata{1},1);
    
    data = cell(nTrials,nRois);
    for trial = 1:nTrials
        for roi = 1:nRois
            data{trial,roi} = dffdata{trial}(roi,:);
        end
    end
else % it must be dffmat
    formattype = 'dffmat'; outputtype = 'dffarray';
    nTrials = size(dffdata,1);
    nRois = size(dffdata,2);
    
    data = cell(1,nTrials);
    for trial = 1:nTrials
        nFrames = numel(dffdata{trial,1});
        tempmatrix = NaN(nRois,nFrames);
        for roi = 1:nRois
            tempmatrix(roi,:) = dffdata{trial,roi};
        end
        data{trial} = tempmatrix;
    end
end

fprintf('Detected storage type %s, converted to %s\n',formattype,outputtype)
end