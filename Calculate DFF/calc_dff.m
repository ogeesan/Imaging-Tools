function dffmat = calc_dff(roimeans)
% dffmat = calc_dff(roimeans)

%% Main

% if the roimeans uses the old storage then it needs to be converted
if size(roimeans{1},1) > 1
    nTrials = numel(roimeans);
    nRois = size(roimeans{1},1);
    data = cell(nTrials,nRois);
    for trial = 1:nTrials
        for roi = 1:nRois
            data{trial,roi} = roimeans{trial}(roi,:);
        end
    end
    roimeans = data;
end

binsize = 1;
nRois = size(roimeans,2);
nTrials = size(roimeans,1);

% -- Find ROI baseline values
roibaselines = NaN(1,nRois); % store medians of percentiles
for roi = 1:nRois
    
    data = [roimeans{:,roi}]; % get all values for this roi from all trials
    
    bins = 0:binsize:ceil(max(data)/binsize)*binsize; % define bins to sort into as 
    [counts, edges] = histcounts(data,bins); % histogram of values across all trials
    edges = edges + binsize / 2; % restructure edges to have values in centre of bin
    edges(end) = [];

    [~, idx] = max(counts);
    roibaselines(roi) = edges(idx); % baseline is the most common value
end

% -- Calculate delta fluorescence
dffmat = cell(nTrials,nRois);
for trial = 1:nTrials
    for roi = 1:nRois
        ftrace = roimeans{trial,roi};
        ftrace = (ftrace - roibaselines(roi)) ./ roibaselines(roi); % calculate dff trace
        
        % Assume values for first and last two frames (prevents frame
        % closure from messing with the filtering)
        ftrace(1:2) = ftrace(3);
        ftrace(end-1:end) = ftrace(end-2);
        
        ftrace = sgolayfilt(ftrace,2,7); % Salvitzky-Golay smoothing, 2,7 works pretty well
        dffmat{trial,roi} = ftrace; % insert into dffarray
    end
end