function EventTable = detect_events(dffarray)
% EventTable = detect_events(dffarray)

prm.mindur = 10; % minimum # of frames above threshold to be considered event
prm.interdistance = 5; % minimum # of frames between an offset and onset
prm.edgecase = 'ambitious'; % decide how edge-cases will be handled

nTrials = numel(dffarray);
nROIs = size(dffarray{1},1);

%% - Calculate thresholds
thresholds = NaN(nROIs,1); % vector that will store the threshold value for each ROI
for roi = 1:nROIs
    % -- Get all dff values for a single roi
    data = cell(nTrials,1);
    for trial = 1:nTrials
        data{trial} = dffarray{trial}(roi,:); % each cell is a trace from a trial
    end
    data = [data{:}]; % unpack all of the traces into a single vector
    
    % -- Define the threshold
    thresholds(roi) = 3*mad(data,1);
end

%% - Detect events
counter = 0;
for roi = 1:nROIs
    threshold = thresholds(roi);
    for trial = 1:nTrials
        
        % -- Get ftrace and account for possible shutter closure
        ftrace = dffarray{trial}(roi,:);
        ftrace(end-2:end) = NaN; % trim the last values due to laser shutoff
        % (if an event goes below threshold in the final frames of a trace
        % it could be because the fluorescence signal disappeared because
        % of the shutter, so making it NaN makes the detection blind to
        % what happens there)
        
        sup_threshold = ftrace > threshold; % logical of values above threshold
        if sup_threshold(end-3) == 1 % if the third to last value is true
            sup_threshold(end-2:end) = 1; % make the final two true as well (to account for shutter closure)
        end
        
        % -- Find rise and fall edges
        diff_sup_ftrace = diff(sup_threshold);
        rise_edges = find(diff_sup_ftrace == 1);
        fall_edges = find(diff_sup_ftrace == -1);
        
        % -- Handle edge cases (haha)
        if ~isempty(fall_edges) && ~isempty(rise_edges) && fall_edges(1) < rise_edges(1) 
            % If there's a fall before a rise add on a rise at the firrst
            % frame
            rise_edges = [1 rise_edges];
        end
        
        if numel(rise_edges) > numel(fall_edges) % if there's more rises than falls
            switch prm.edgecase
                case 'conservative'
                    rise_edges(end) = []; % remove the last rise
                case 'ambitious'
                    fall_edges(end+1) = numel(ftrace); % add on a fall at the end
            end
        elseif numel(fall_edges) > numel(rise_edges) % if there's more falls than rises
            fall_edges(1) = []; % remove the fall
            % I actually don't know if this situation is possible but just
            % in case
        end
        
        
        % -- Remove very short differences between on/off which are
        % probably artefacts (this is different to events which are too
        % short)
        tf = ([rise_edges NaN] - [NaN fall_edges]) < prm.interdistance;
        tf = find(tf);
        rise_edges(tf) = [];
        fall_edges(tf-1) = [];
        
        % -- Remove events that are too short
        tf = (fall_edges - rise_edges) < prm.mindur;
        rise_edges(tf) = [];
        fall_edges(tf) = [];
        
        %                     hold on
        %                     scatter(rise_edges,repmat(threshold,1,numel(rise_edges)),'g')
        %                     scatter(fall_edges,repmat(threshold,1,numel(fall_edges)),'r')
        %                     hold off
        
        % -- Loop through each detected events
        for event = 1:numel(rise_edges)
            %% Extract event properties
            onset = rise_edges(event);
            offset = fall_edges(event);
            
            % -- Find peak values
            signal_window = ftrace(onset:offset);
            [peak, idxs] = sort(signal_window,'descend','MissingPlacement','last');
            
            % weighted average of five values, with SECOND highest with max
            % weight
            peak = (peak(2) + peak(1)*4/5 + peak(3)*3/5 + peak(4)*2/5 + peak(5)*1/5) / (5/5 + 4/5 + 3/5 + 2/5 + 1/5);
            % Location of peak the average between two maxs
            loc = mean(idxs(1:2));
            
            % -- Find width
            leftwidth = loc - find(signal_window > (peak / 2),1,'first');
            rightwidth = find(signal_window > (peak / 2),1,'last') - loc;
            
            % process some info
            realloc = loc + onset - 1; % account for window offset
            
            if strcmp(prm.edgecase,'conservative')
                if offset > numel(ftrace)- 2; offset = NaN;end
                if onset <= 2; onset = NaN;end
            end
            
            % Save event into Events structure
            counter = counter + 1;
            Events(counter).ROI = roi;
            Events(counter).Trial = trial;
            Events(counter).Onset = onset;
            Events(counter).Offset = offset;
            Events(counter).Peak = peak;
            Events(counter).Loc = realloc;
            Events(counter).LeftWidth = leftwidth;
            Events(counter).RightWidth = rightwidth;
            Events(counter).Threshold = threshold;
            %             hold on
            %             scatter(realloc,peak)
            %             plot([realloc-leftwidth realloc+rightwidth],[peak / 2 peak / 2],'k')
            %             plot([realloc realloc],[0 peak],'k')
            %             scatter([onset offset], [thresholds(roi) thresholds(roi)],[],[0 1 0; 1 0 0])
            %             hold off
        end        
    end
end
EventTable = struct2table(Events); % convert structure into table