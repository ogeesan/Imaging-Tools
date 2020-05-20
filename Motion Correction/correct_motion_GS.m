%% correct_motion_GS
%{
version: 200520
Apparently this is Naoya Takahashi's code. I received LG's version and made
some quality of life modifications. The actual motion correction itself
remains the same.

When you run the code you'll get four UIs.
1. Select the base image.
2. Select the folder containing raw .tif files.
3. Select a folder to save the motion corrected files to.
4. Define the name of the experiment.

Changes:
- Improved UI input system.
- Implemented creation of _totalaverage.tif
- Implemented creation of trial_avgs.mat
- Improved readability of script.
- Improved progress update system.
%}

%% Specify files and filenames
% get template image location and location to save output metafiles
[fname, pname_base] = uigetfile('*.tif', 'Pick a Tif-file for base image');
if isequal(fname, 0) || isequal(pname_base, 0)
    disp('User canceled')
    return;
end
current_directory = pwd; % save where you currently are for later
cd(pname_base); % cd() sets the current directory (to easily specify the next two path names)
imf = [pname_base fname]; % the location of the base image

% raw files
pname_raw = uigetdir('*.tif', 'Select folder containing Tif-files to motion correct'); % location of raw files
if isequal(pname_raw, 0)
    disp('User canceled')
    return;
end

% new save location for motion corrected files
pname_save = uigetdir([], 'Select a folder to save motion corrected files into');
if isequal(pname_save, 0)
    disp('User canceled')
    return;
end

filelist = dir([pname_raw '\*.tif']); % list of all .tif files in the folder of raw files
names = {filelist.name}';
names(contains(names,'_mc.tif')) = []; % removes any motion corrected files from being motion corrected again

savefn = pname_base; % the basic naming system


% I don't know what this is does, some sort of setting for the MC
%kernel = gauss2(hh, ww - 64, 1, 1);    % set filter applied to each frame before cross-correlation calculation. if it is not necessary, set 'kernel = []'.
%kernel = fft2(kernel);
kernel = [];

%% Get the template file
tif_info = imfinfo(imf); % struct of tif metadata, each row is a single frame
nFrames = length(tif_info);
if nFrames == 1
    base = imread(imf, 1); % template is a single frame image
elseif nFrames > 1 % hopefully this isn't true
    disp('Template is not single image, applying motion correction.')
    base = imread(imf, 1);
    base = double(base);
    for i = 2 : 10
        buf = imread(imf, i);
        base = base + double(buf);
    end
    base = base / 10;
    [avg, ~] = cor_mot(imf, base, nFrames, kernel); % apply the motion correction to the basefile
    base = avg;
    savefn_temp = [pname_base strrep(imf, '.tif', '_base.tif')]; % save basefile to base location
    imwrite(uint16(base), savefn_temp, 'tiff', 'Compression', 'none', 'WriteMode', 'overwrite');
    baseFile = savefn_temp;
else
    errordlg('Your template is messed up my dude')
    return
end

%% Do the motion correction

nFiles = numel(names);
fprintf('%s commenced motion correction of %i files\n',datestr(now,'HH:MM:SS'),nFiles)
nFrames_list = NaN(1,nFiles);

mclog = struct('name',cell(1,nFiles)); % initialise record of frame offset
trial_avgs = NaN(tif_info(1).Width, tif_info(1).Width, nFiles); % presumably 512x512xnFiles (uses base imf)

tmr.reset = ''; % all tmr variables are just used for timing purposes
tmr.times = NaN(nFiles,4); % will keep track of time required for each MC

for xfile = 1:nFiles
    tmr.times(xfile,1) = now; % record start time for file
    
    imf = [pname_raw '\' names{xfile}]; % current filename
    nFrames = length(imfinfo(imf));
    nFrames_list(xfile) = nFrames; % create list of nFrames for weighted average later
    
    
    % -- Motion correction
    [avg, cloc] = cor_mot(imf, base, nFrames, kernel, pname_save); % apply the motion correction (new files are saved from within this function)
    %{
    avg = average of all frames parsed in the motion correction
    cloc = x-y offsets for each frame
    imf = filepath of .tif of interest
    base = array of template file
    nFrames = number of frames
    kernel = something that can alter the maths
    pname_save = folder to save mc files to (my addition)
    %}
    
    
    % -- Metadata saving
    trial_avgs(:,:,xfile) = avg; % insert weighted value in
    
    % add information about motion correction into mclog
    mclog(xfile).name = imf;
    mclog(xfile).vshift = cloc(:, 1);
    mclog(xfile).hshift = cloc(:, 2);
%     mclog(xfile).avg = avg; % considering each 512x512 is almost 2MB, yeah nah
    

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

% -- Save trial_avgs.mat
save([savefn 'trial_avgs.mat'],'trial_avgs') % save the raw trial averages for revision if required

% -- Save totalaverage.tif
% convert trial averages to weight average
for xfile = 1:nFiles
    trial_avgs(:,:,xfile) = trial_avgs(:,:,xfile) .* nFrames_list(xfile) ./ sum(nFrames_list);
end

trial_avgs = mean(trial_avgs,3); % sum everything together for weighted average
imwrite(uint16(trial_avgs), [savefn 'totalaverage.tif'], 'tiff', 'Compression', 'none', 'WriteMode', 'overwrite');

% -- Save mclog.mat
save([savefn 'mclog.mat'], 'mclog') % save mclog


% -- Script end notification
cd(current_directory) % return to the directory you were at originally
tmr.msg = sprintf('%s operation completed in %s | averaged %.2fs per loop\n', datestr(now,'HH:MM:SS'), ...
    datestr(seconds(sum(tmr.times(:,3))),'MM:SS'),mean(tmr.times(:,3)));
fprintf([tmr.reset, tmr.msg]);
figure
subplot(4,1,[1 2 3])
imagesc(trial_avgs) % plot what the totalaverage.tif looks like
xticklabels([]);yticklabels([]);title('totalaverage.tif')
axis square
colormap('gray')
colorbar
subplot(4,1,4)
plot(tmr.times(:,3)) % plot time taken for each loop
xlabel('Loop');ylabel('Time (s)');title('Time per loop');yline(mean(tmr.times(:,3)),':');

%% FUNCTIONS
function [avg, cloc] = cor_mot(rawname, base, nFrames, kernel,savepath)
savename = rawname(find(rawname == '\',1,'last')+1:end); % shed path from raw name
savename = strrep([savepath '\' savename], '.tif', '_mc.tif'); % define new name

avg = zeros(size(base)); % initialise storage of average for trial
cloc = zeros(nFrames, 2); % initialise offset meta

for xframe = 1:nFrames
    frame = imread(rawname, xframe); % read in a single frame from the .tif file
    
    % -- Apply motion correction to the frame
    lag = corpeak2(base, frame, kernel); % returns xy coords for motion correction, I think by finding max correlation between base and frame
    cloc(xframe, :) = lag; % cloc = corrected location (Y-X coordinates)
    frame = circshift(frame, lag); % frame is shifted circularly
    avg = avg + double(frame); % each frame is added together
    
    % -- Write frame into new .tif file
    if xframe == 1 % if first frame then write a new file
        imwrite(uint16(frame), savename, 'tiff', 'Compression', 'none', 'WriteMode', 'overwrite'); % write a new _mc file
    else % append frame to the existing file
        flag = 1;
        while flag
            try
                imwrite(uint16(frame), savename, 'tiff', 'Compression', 'none', 'WriteMode', 'append'); % append the next frame
                flag = 0;
            catch
                pause(0.2);
            end
        end
    end

end
avg = avg / nFrames;
end


% the act of motion correction, using phase correlation
function y = corpeak2(base, frame, kernel)

[height, width] = size(base);
base = base(:, 33 : width - 32); % Edge of the movie is not involved in the following calculation
frame = frame(:, 33 : width - 32); % Edge of the movie is not involved in the following calculation
width = width - 64;

% fast Fourier transforms
fourier_base = fft2(double(base));
fourier_frame = fft2(double(frame));

% kernel is used to define a filter? I don't know
if ~isempty(kernel)
    fourier_frame = fourier_frame .* kernel;
    buf = ifft2(fourier_frame);
    buf = ifftshift(buf);
    fourier_frame = fft2(buf);
end

buf = fourier_base .* conj(fourier_frame);
cf = ifft2(buf); % inverse fast Fourier transform

cf(16 : height - 15, :) = 0;
cf(:, 16 : width - 15) = 0;

% get xy coords of max value in cf (which corresponds to the offset)
[mcf1, id1] = max(cf, [], 1);
[~, id2] = max(mcf1);

% account for edge cases
if id1(id2) > height / 2
    vertical = id1(id2) - height - 1;
else
    vertical = id1(id2) - 1;
end
if id2 > width / 2
    horizontal = id2 - width - 1;
else
    horizontal = id2 - 1;
end
y = [vertical horizontal]; % row-column indexing
end
