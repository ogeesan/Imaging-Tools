function dffmat = calc_dff(roimeans)
% dffmat = calc_dff(roimeans)

%% Main
binsize = 1;
nROIs = size(roimeans{1},1);
nTrials = size(roimeans,2);

% -- Find ROI baseline values
roibaselines = NaN(1,nROIs); % store medians of percentiles
for roi = 1:nROIs
    
    % --- Collect all traces from the ROI
    data = cell(1,nTrials); % insert into cells as traces can be different length
    for trial = 1:nTrials
        data{trial} = roimeans{trial}(roi,:);
    end
    data = [data{:}]; % horzcat() cells into vector
    
    bins = 0:binsize:ceil(max(data)/binsize)*binsize; % define bins to sort into as 
    [counts, edges] = histcounts(data,bins); % histogram of values across all trials
    edges = edges + binsize / 2; % restructure edges to have values in centre of bin
    edges(end) = [];

    [~, idx] = max(counts);
    roibaselines(roi) = edges(idx); % baseline is the most common value
end

% -- Calculate delta fluorescence
dffmat = cell(nTrials,nROIs);
for trial = 1:nTrials
    for roi = 1:nROIs
        ftrace = roimeans{trial}(roi,:); % extract relevant trace from roimeans
        ftrace = (ftrace - roibaselines(roi)) ./ roibaselines(roi); % calculate dff trace
        
        % Assume values for first and last two frames (prevents frame
        % closure from messing with the filtering)
        ftrace(1:2) = ftrace(3);
        ftrace(end-1:end) = ftrace(end-2);
        
        ftrace = sgolayfilt(ftrace,2,7); % Salvitzky-Golay smoothing, 2,7 works pretty well
        dffmat{trial,roi} = ftrace; % insert into dffarray
    end
end