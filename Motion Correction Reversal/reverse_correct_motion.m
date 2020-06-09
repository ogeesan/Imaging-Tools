function reverse_correct_motion
%{
version: 200609
George Stuyt

A script for reversing motion correction using mclog.mat. Remember to
verify that it worked before deleting anything...

%}
%% Receive user input

% get mclog
[fname,pname] = uigetfile('*.*','Select the mclog.mat');
load(fullfile(pname,fname),'mclog');
cd(pname)

% get motion corrected file directory
pname_mc = uigetdir([],'Select the folder containing the motion corrected .tif files'); % get motion corrected files
directory_mc = dir(fullfile(pname_mc,'*.tif'));
nFiles = size(directory_mc,1);

% get folder to save new files to
pname_new = uigetdir([],'Select a folder to save the "new" files to');

%% Validate user input

% check if frames in mclog and in images match
nFrames = NaN(nFiles,3);
for xfile = 1:nFiles
    filename = directory_mc(xfile).name;
    info = imfinfo(fullfile(pname_mc,filename)); % get metadata about the file
    nFrames(xfile,1) = size(info,1);
    nFrames(xfile,2) = numel(mclog(xfile).hshift);
end
if nFrames(:,1) ~= nFrames(:,2) % if they don't then we got a problem
    error('number of frames in files do not match. Cancelling script')
end

% check if files already exist in the folder
savefilename = mclog(1).name;
temp = strfind(savefilename,'\');
savefilename = savefilename(temp(end)+1:end);
temp = dir(pname_new);
if any(strcmp({temp.name},savefilename))
    answer = questdlg('The save folder appears to contain files already named, do you wish to overwrite them?',...
        'Continue or pause?',...
        'Yes, proceed with reversal','No, cancel script','No, cancel script');
    if strcmp(answer, 'No, cancel script')
        fprintf('%s user cancelled script\n',datestr(now,'HH:MM:SS'))
        return
    end
end

%% Reverse motion correction
fprintf('%s commenced reversal of motion correction for %i files into:\n',datestr(now,'HH:MM:SS'),...
    nFiles)
fprintf('         %s\n',pname_new)
tmr.reset = ''; % all tmr variables are just used for timing purposes
tmr.times = NaN(nFiles,4); % will keep track of time required for each MC

for xfile = 1:nFiles
    tmr.times(xfile,1) = now; % record start time for file
    
    filename = directory_mc(xfile).name;
    info = imfinfo(fullfile(pname_mc,filename)); % get metadata about the file
    nFrames = size(info,1);
    options.message = false; % suppress message from saveastiff();
    
    % shed names down to just the original filename 
    savefilename = mclog(xfile).name;
    temp = strfind(savefilename,'\');
    savefilename = savefilename(temp(end)+1:end);
    
    % build new save location
    savename = fullfile(pname_new,savefilename);
    
    for xframe = 1:nFrames
        
        % -- Read and reverse frame
        frame = imread(fullfile(pname_mc,filename),xframe);
        hshift = mclog(xfile).hshift(xframe);
        vshift = mclog(xfile).vshift(xframe);
        frame = circshift(frame,[-vshift -hshift]); % just apply the opposite as recorded in mclog
        
        % -- Save new frame
        if xframe == 1
            options.overwrite = true; % overwrite if there's already something there
            saveastiff(frame,savename,options);
            options.append = true; % from now on append frames onto the file
            options.overwrite = false;
        else
            flag = 1;
            while flag
                try
                    saveastiff(frame,savename,options);
                    flag = 0;
                catch % if some sort of error occurs during the write, wait and then try again
                    pause(0.2);
                end
            end
        end
        
    end
    
    % -- Timing stuff
    tmr.times(xfile,2) = now; % record when the loop finished
    tmr.times(xfile,3) = (tmr.times(xfile,2) - tmr.times(xfile,1)) * 24 * 60 * 60; % time for this loop in seconds
    tmr.times(xfile,4) = nanmean(tmr.times(1:xfile,3)) * (size(tmr.times,1) - xfile) / 60; % estimated time remaining in minutes
    tmr.remainstr = datestr(minutes(tmr.times(xfile,4)),'MM:SS');
    tmr.msg = sprintf('%s %.2f done | loop %i completed in %.2fs | %s remaining\n', datestr(now,'HH:MM:SS'),...
        100*xfile/(size(tmr.times,1)), xfile, tmr.times(xfile,3), tmr.remainstr);
    fprintf([tmr.reset, tmr.msg]); % backspace the current update, insert new update
    tmr.reset = repmat(sprintf('\b'), 1, length(tmr.msg)); % create backspaces to delete current msg on next loop
end

tmr.msg = sprintf('%s operation completed in %s | averaged %.2fs per file\n', datestr(now,'HH:MM:SS'), ...
    datestr(seconds(sum(tmr.times(:,3))),'MM:SS'),mean(tmr.times(:,3)));
fprintf([tmr.reset, tmr.msg]);
figure('Name','Operation completed','NumberTitle','off')
plot(tmr.times(:,3)) % plot time taken for each loop
xlabel('Loop');ylabel('Time (s)');title('Time per loop');yline(mean(tmr.times(:,3)),':');