%% correct_motion_GS
%{
version: 201002
Apparently this is Naoya Takahashi's code. I received LG's version and made
some quality of life modifications. The actual motion correction itself
remains the same.

When you run the code you'll get four UIs.
1. Select the base image.
2. Select the folder containing raw .tif files.
3. Select a folder to save the motion corrected files to.
4. Define the name of the experiment.

Changes:
- Widened possible motion correction amount to 40 pixels.
- No removal of negative values.
- Improved UI input system.
- Implemented creation of _totalaverage.tif
- Implemented creation of trial_avgs.mat
- Improved readability of script.
- Improved progress update system.
- Added compatibility for .tiff/.tif extension difference
%}

%% Specify files and filenames
function correct_motion_GS(opts)
% get template image location and location to save output metafiles
[fname, basedir] = uigetfile('*.tif*', 'Pick a Tif-file for base image');
if isequal(fname, 0) || isequal(basedir, 0)
    disp('User canceled')
    return;
end
% current_directory = pwd; % save where you currently are for later
cd(basedir); % cd() sets the current directory (to easily specify the next two path names)
impath = fullfile(basedir, fname); % the location of the base image

% raw files
rawdir = uigetdir('*.tif*', 'Select folder containing Tif-files to motion correct'); % location of raw files
if isequal(rawdir, 0)
    disp('User canceled')
    return;
end

% new save location for motion corrected files
savedir = uigetdir([], 'Select a folder to save motion corrected files into');
if isequal(savedir, 0)
    disp('User canceled')
    return;
end

filelist = dir([rawdir '\*.tif*']); % list of all .tif files in the folder of raw files
fnames = {filelist.name}';
fnames(contains(fnames,'_mc.tif*')) = []; % removes any motion corrected files from being motion corrected again

% I don't know what this is does, some sort of setting for the MC
%kernel = gauss2(hh, ww - 64, 1, 1);    % set filter applied to each frame before cross-correlation calculation. if it is not necessary, set 'kernel = []'.
%kernel = fft2(kernel);
kernel = [];
%% Parse options
if nargin == 0
    opts.default = true;
end
if ~isfield(opts,'corrlimit');opts.corrlimit = 15;end
if ~isfield(opts,'appendnum');opts.appendnum = true;end

%% Get the template file
tif_info = imfinfo(impath); % struct of tif metadata, each row is a single frame
opts.tif_info = tif_info;
nFrames = length(tif_info);
if nFrames == 1
    base = imread(impath, 1); % template is a single frame image
elseif nFrames > 1 % hopefully this isn't true
    disp('Template is not single image, applying motion correction.')
    base = imread(impath, 1);
    base = double(base);
    for i = 2 : 10
        buf = imread(impath, i);
        base = base + double(buf);
    end
    base = base / 10;
    [avg, ~] = cor_mot(impath, base, nFrames, kernel,basedir,opts); % apply the motion correction to the basefile
    base = avg;
    savefn_temp = strrep(impath, '.tif', '_base.tif'); % save basefile to base location
    imwrite(uint16(base), savefn_temp, 'tiff', 'Compression', 'none', 'WriteMode', 'overwrite');
else
    errordlg('Your template is messed up my dude')
    return
end

%% Do the motion correction

nFiles = numel(fnames);
temp = find(savedir == filesep);
fprintf('%s commenced motion correction of %i files to %s\n',...
    datestr(now,'HH:MM:SS'),nFiles,savedir(temp(end-1):end))
nFrames_list = NaN(1,nFiles);

mclog = struct('name',cell(1,nFiles)); % initialise record of frame offset
trial_avgs = NaN(tif_info(1).Height, tif_info(1).Width, nFiles); % presumably 512x512xnFiles (uses base impath)

tmr.reset = ''; % all tmr variables are just used for timing purposes
tmr.times = NaN(nFiles,4); % will keep track of time required for each MC

for xfile = 1:nFiles
    tmr.times(xfile,1) = now; % record start time for file
    opts.xfile = xfile;
    
    impath = fullfile(rawdir,fnames{xfile}); % current filename
    nFrames = length(imfinfo(impath));
    nFrames_list(xfile) = nFrames; % create list of nFrames for weighted average later
    opts.tif_info = imfinfo(impath);
    
    
    % -- Motion correction
    [avg, cloc] = cor_mot(impath, base, nFrames, kernel, savedir,opts); % apply the motion correction (new files are saved from within this function)
    %{
    avg = average of all frames parsed in the motion correction
    cloc = x-y offsets for each frame
    impath = filepath of .tif of interest
    base = array of template file
    nFrames = number of frames
    kernel = something that can alter the maths
    savedir = folder to save mc files to (my addition)
    %}
    
    
    % -- Metadata saving
    trial_avgs(:,:,xfile) = avg; % insert weighted value in
    
    % add information about motion correction into mclog
    mclog(xfile).name = impath;
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
save(fullfile(basedir, 'trial_avgs.mat'),'trial_avgs') % save the raw trial averages for revision if required

% -- Save totalaverage.tif
% convert trial averages to weight average
for xfile = 1:nFiles
    trial_avgs(:,:,xfile) = trial_avgs(:,:,xfile) .* nFrames_list(xfile) ./ sum(nFrames_list);
end

trial_avgs = mean(trial_avgs,3) .* 1000; % sum everything together for weighted average, multiply because unit16 will "compress" it
imwrite(uint16(trial_avgs), fullfile(basedir, 'totalaverage.tif'), 'tiff', 'Compression', 'none', 'WriteMode', 'overwrite');

% -- Save mclog.mat
save(fullfile(basedir, 'mclog.mat'), 'mclog') % save mclog

% cd(current_directory) % return to the directory you were at originally

% -- Script end notification
tmr.msg = sprintf('%s operation completed in %s | averaged %.2fs per loop\n', datestr(now,'HH:MM:SS'), ...
    datestr(seconds(sum(tmr.times(:,3))),'MM:SS'),mean(tmr.times(:,3)));
fprintf([tmr.reset, tmr.msg]);
figure('Name','Operation completed','NumberTitle','off')
subplot(4,1,[1 2 3])
imagesc(trial_avgs,[0 prctile(trial_avgs(:),95)]) % plot what the totalaverage.tif looks like
xticklabels([]);yticklabels([]);title('totalaverage.tif')
axis square
colormap('gray')
colorbar
subplot(4,1,4)
plot(tmr.times(:,3)) % plot time taken for each loop
xlabel('Loop');ylabel('Time (s)');title('Time per loop');yline(mean(tmr.times(:,3)),':');

if exist('mclogplot.m','file') == 2 % if the visualisation is on the matlab path
    figure('Name','Motion Correction','NumberTitle','off');
    mclogplot(mclog);
    set(gca,'TickDir','out')
    xlabel('Frame');ylabel('File') 
    title('Motion correction visualisation')
end

end
%% FUNCTIONS
function [avg, cloc] = cor_mot(impath, base, nFrames, kernel,savedir,opts)
[~, savename, ~] = fileparts(impath); % shed directory and extension (.tiff/.tif) from path

if opts.appendnum
    xfile = opts.xfile;
    filetail = sprintf('_%05i_mc.tif',xfile); % number motion correction files independently
else
    filetail = '_mc.tif';
end
savename = [savename filetail]; % concat the strings (savename doesn't have an extension)

savepath = fullfile(savedir,savename); % define new name

avg = zeros(size(base)); % initialise storage of average for trial
cloc = zeros(nFrames, 2); % initialise offset meta

for xframe = 1:nFrames
    frame = imread(impath, xframe,'Info',opts.tif_info); % read in a single frame from the .tif file
    
    % -- Apply motion correction to the frame
    lag = corpeak2(base, frame, kernel,opts); % returns xy coords for motion correction, I think by finding max correlation between base and frame
    cloc(xframe, :) = lag; % cloc = corrected location (Y-X coordinates)
    frame = circshift(frame, lag); % frame is shifted circularly
    avg = avg + double(frame); % each frame is added together
    tiffopts.message = false;
        
    % -- Write frame into new .tif file
    if xframe == 1 % if first frame then write a new file
        tiffopts.overwrite = true; % overwrite if there's already something there
        saveastiff(frame,savepath,tiffopts);
        tiffopts.append = true; % from now on append frames onto the file
        tiffopts.overwrite = false;
%         imwrite(uint16(frame), savename, 'Tiff', 'Compression', 'none', 'WriteMode', 'overwrite'); % write a new _mc file
    else % append frame to the existing file
        flag = 1;
        while flag
            try
                saveastiff(frame,savepath,tiffopts);
%                 imwrite(uint16(frame), savename, 'Tiff', 'Compression', 'none', 'WriteMode', 'append'); % append the next frame
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
function y = corpeak2(base, frame, kernel,opts)

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

buf = fourier_base .* conj(fourier_frame); % complex double
cf = ifft2(buf); % inverse fast Fourier transform - the phase correlation, imagesc(cf) if you want to see it

% restrict search window of max correlation search
correctionlimit = opts.corrlimit; % maximum value in one direction
cf(correctionlimit + 1 : height - correctionlimit, :) = NaN;
cf(:, correctionlimit + 1 : width - correctionlimit) = NaN;
% cf(16 : height - 15, :) = 0; % original
% cf(:, 16 : width - 15) = 0;

% get xy coords of max value in cf (which corresponds to the offset)
[mcf1, vertidxs] = max(cf, [], 1); % the maximum values in each column - a vector of maxes from each column
[~, horzidx] = max(mcf1); % the maximum values in the row of maximums - index of the max i.e. horizontal index

% account for the size of the image and direction and stuff
if vertidxs(horzidx) > height / 2 % if 
    vertical = vertidxs(horzidx) - height - 1;
else
    vertical = vertidxs(horzidx) - 1;
end
if horzidx > width / 2
    horizontal = horzidx - width - 1;
else
    horizontal = horzidx - 1;
end
y = [vertical horizontal]; % row-column indexing
end
