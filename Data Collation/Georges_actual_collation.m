%% GS Data Collation
% collect all RE data and 2P data (processed) into a table
prm.cohort = 5;
prm.sessioncheck = false; % if true will generate spreadsheet of SessionData and cease script
prm.cohort_directory = 'E:\GS200220';
% prm.cohort_directory = false; % make false to manually select cohort folder

cohorts = {'GS190603' 'GS190423' 'GS190523' 'GS190617' ...
           'GS200220' 'GS200322'};
cohort_id = cohorts{prm.cohort};
tmr.totalstart = now;
tmr.reset = []; % initialise the thing used to store backspaces in the command update system

if prm.sessioncheck % if just generating list of .mat files
    fprintf('%s SessionData collation commenced, script will terminate afterwards\n',datestr(now,'HH:MM:SS'))
else
    fprintf('%s data collation commenced\n', datestr(now,'HH:MM:SS'))
    Master = readtable('GS19AWR_Sheets.xlsx','Sheet','Master');
    % process the MasterSheet
    Master = Master(~ismissing(Master.Session),:); % remove all entires that don't have a session
    Master = Master(Master.Cohort == prm.cohort,:); % use only the records from the current cohort
end

%% Generate directory
if prm.cohort_directory == false
    cohort_directory = uigetdir([], 'Select folder containing the cohort''s data.');
else
    cohort_directory = prm.cohort_directory;
end
tmr.start = now;
directory = struct2table(dir([cohort_directory '\**'])); % get the location of every file in the cohort folder
fprintf('%s directory of %s generated in %.2f seconds\n',datestr(now,'HH:MM:SS'),cohort_directory,(now-tmr.start)*24*60*60)

%% Generate SessionData filelist if required
if prm.sessioncheck
    tf = contains(directory.name, '.mat');
    matfilelist = directory(tf,:); % get .mat files
    
    tmr.start = now;
    fprintf('%s commencing processing of .mat files\n',datestr(now,'HH:MM:SS'))
    
    % iterate through each .mat file and if it's SessionData
    for xfile = 1:size(matfilelist,1)
        vars = who(matfile(fullfile(matfilelist.folder{xfile},matfilelist.name{xfile}))); % get name of variable stored in the .mat file
        matfilelist.vars(xfile) = vars;
        if strcmp(vars,'SessionData') % if it's a SessionData then record its nTrials
            load(fullfile(matfilelist.folder{xfile},matfilelist.name{xfile}));
            matfilelist.nTrials(xfile) = SessionData.nTrials;
            matfilelist.Date{xfile} = [SessionData.Info.SessionDate ' ' SessionData.Info.SessionStartTime_UTC];
        end
        
        % timing stuff
        tmr.msg = sprintf('%s %i files (%.2f percent) complete\n', datestr(now,'HH:MM:SS'),...
            xfile,xfile/size(matfilelist,1)*100);
        fprintf([tmr.reset tmr.msg])
        tmr.reset = repmat('\b',1,numel(tmr.msg));
    end
    
    % save a table with all names for manual name match in Master Spreadsheet
    tf = strcmp(matfilelist.vars,'SessionData');
    writetable(matfilelist(tf,:),'matfilelist.csv') % write only the SessionData .mat files
    
    fprintf(tmr.reset) % remove the update text
    fprintf('%s completed processing of %i SessionData files in %.2f seconds.\n',...
        datestr(now,'HH:MM:SS'), size(matfilelist,1), (now - tmr.start)*24*60*60)
    msgbox({sprintf('%s operation completed',datestr(now,'HH:MM:ss')); 'SessionData list generated'},'Complete') % a 'lil popup to let you know it's done
    
    return % exit the script because if you're building this I assume you don't need to build a new data .mat
end

%% Collate the cohort's files
datagets = {'Bpod_Data' 'SessionData'}; % heading of filename and heading of data name
folderget = 'SessionID'; % heading of folder name
filetypes = {'Facrosstrials.mat' 'roimeans'; % define tags of file to find and name of column in Master
             'totalaverage.tif' 'fov';
             'mclog.mat' 'mclog';
             'RoiSet.zip' 'RoiSet'};

tmr.reset = [];
tmr.times = NaN(height(Master),4);

for row = 1:height(Master)
    tmr.times(row,1) = now;
    
    % -- Obtain files in folder of interest
    getname = Master.(folderget){row}; % get name of folder we're keen in
    getrow = strcmp(getname,directory.name) & directory.isdir; % get location of the folder we're keen in
    if sum(getrow) > 1 % if there are multiple folders with the name
        warning('name ''%s'' of row %i has duplicates',getname,row)
        tmr.reset = [];
    elseif sum(getrow) == 0 && ~isempty(getname) % if something was specified but nothing found
        warning('name ''%s'' of row %i was not found',getname,row)
        tmr.reset = [];
        
    elseif sum(getrow) == 1
        getfolder = [directory.folder{getrow} '\' getname]; % get full folderpath
        files = strcmp(getfolder,directory.folder); % logical of all files in that folder (excluding files further down)
        files = find(files); % convert to number for easy looping over
        
        for idx = 1:size(filetypes,1)
            
            tagname = filetypes{idx,1}; % this is just the tag we're looking for
            tf = false(1,numel(files)); % logical for filenames that contain tag
            for xfile = 1:numel(files) % only looping over files in getfolder, not everything
                tf(xfile) = ~isempty(strfind(directory.name{files(xfile)},tagname)); % find which of the files in the folder contain the tag
            end
            if sum(tf) > 1
                warning('name ''%s'' of row %i has duplicates',tagname,row) % display a warning message if there is a duplicate
            elseif sum(tf) == 1
                getname = directory.name{files(tf)}; % define the full file name
                
                if strcmp(tagname,'mclog.mat')
                    loaded_file = load(fullfile(getfolder, getname)); % temporarily load in the file here
                    fieldname = fieldnames(loaded_file); % read the name of the structure
                    Master.(filetypes{idx,2}){row} = loaded_file.(fieldname{1}); % we index back into the thing we loaded because structures are weird
                elseif strcmp(tagname,'totalaverage.tif')
                    loaded_file = imread(fullfile(getfolder, getname));
                    Master.(filetypes{idx,2}){row} = double(loaded_file);
                elseif strcmp(tagname,'RoiSet.zip')
                    [rois] = ReadImageJROI(fullfile(getfolder, getname)); % read in ROIs, cells with structure containing ROI details
                    roicoords = cell(1,size(rois,2));
                    for roi = 1:numel(roicoords)
                        roicoords{roi} = rois{roi}.mnCoordinates - 0.5; % retrive roi coordinates and subtract 0.5 to align with what was drawn in ImageJ
                    end
                    Master.(filetypes{idx,2}){row} = roicoords;
                elseif strcmp(tagname,'Facrosstrials.mat')
                    Master.(filestyp{idx,3}){row} = load(fullfile(getfolder, getname));
                end
            end
            
        end
    end
    
    % -- Obtain individual files
    getname = Master.(datagets{1,1}){row}; % get the filename that we're looking for
    getrow = strcmp({getname},directory.name); % find the row in the directory for the file named in Master
    if sum(getrow) > 1
        warning('name ''%s'' of row %i has duplicates',getname,row)
        tmr.reset = [];
    elseif sum(getrow) == 0 && ~isempty(getname)
        warning('name ''%s'' of row %i was not found',getname,row)
        tmr.reset = [];
    elseif sum(getrow) == 1 % if there's a match
        loaded_file = load([directory.folder{getrow} '\' getname]); % temporarily load in the file here
        fieldname = fieldnames(loaded_file); % read the name of the structure
        SessionData = loaded_file.(fieldname{1}); % unpack the behavioural file
        % process rotary encoder data
        SessionData.RotaryEncoderData = rotarydataposthoc(SessionData.RotaryEncoderData); % fix weird values
        SessionData.RotaryEncoderData = rotarydatadistance(SessionData.RotaryEncoderData,7.625,true); % 7.625 radius, wheel is spinning backwards = true
        
        Master.(datagets{1,2}){row} = SessionData; % insert data into table
    end
    
    % timing materials
    tmr.times(row,2) = now;
    tmr.times(row,3) = (tmr.times(row,2) - tmr.times(row,1)) * 24*60*60;
    tmr.times(row,4) = nanmean(tmr.times(:,3));
    tmr.pc = (height(Master)-row) / height(Master);
    tmr.msg = sprintf('%s %02.2f pc complete | row %i in %02.2f seconds | %.2f seconds remaining\n',...
        datestr(now,'HH:MM:ss'), tmr.pc, row, tmr.times(row,3),tmr.times(row,4));
    fprintf([tmr.reset tmr.msg]);
    tmr.reset = repmat('\b',1,numel(tmr.msg));
    
end

tmr.start = now;
save(strcat(cohort_id,'_cohortMaster_raw.mat'),'Master'); % save file
tmr.dur = (now - tmr.totalstart)*24*60*60;
fprintf(tmr.reset)
fprintf('%s collation completed in %.2f seconds | saved file in %.2f seconds\n',datestr(now,'HH:MM:SS'),...
    tmr.dur,(now - tmr.start)*24*60*60)