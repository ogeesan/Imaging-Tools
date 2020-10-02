function readroi_GS(opts)
%{
George Stuyt
version: 201002
I got this from LG. It was credited to "INC 2017 by Marina and Pedro."

Takes ROI set (.zip) and calculates average fluorescence for each ROI on
each .tif file. Saves a variable 'roimeans' with a cell for each trial 
(file). Each cell is m x n (ROI number x frames).

Changes:
- Made ROIs reflective of what is drawn in ImageJ.
- Changed logic of ROI pixel definition to only include pixels entirely
    enclosed by the ROI.
- Added UI to all input areas, no editing of code required.
- Improved timing/live progress information.
%}

%% Select data to be read
% get .zip containing ImageJ ROIs
current_directory = pwd;

if nargin == 0
    opts.default = true;
end

if ~isfield(opts,'preventoverlap'); opts.preventoverlap = true;end % set overlapping pixels to false
if ~isfield(opts,'returntocd'); opts.returntocd = false;end % after completion return to original folder

if opts.returntocd
    current_directory = pwd; % the directory before the function moves things around
end

% -- Define core names
% basedir = dir of RoiSet.zip that Facrosstrials will be saved to
% fname = filename of the RoiSet.zip that is to be used
% mcdir = dir of the files to have their fluorescence extracted
if any(isfield(opts,{'basedir','fname','mcdir'}))
    % if it's specified (e.g. you're using a loop)
    basedir = opts.basedir;
    fname = opts.fname;
    mcdir = opts.mcdir;
else % otherwise just get user input to define file locations
    [fname, basedir] = uigetfile('*.*','Select RoiSet.zip file');
    cd(basedir);
    mcdir = uigetdir([], 'Select folder containing .tif files to read.'); % get folder where files to read are
end

% switch numel(varargin) > 0
%     case false
%         
%         [fname, basedir] = uigetfile('*.*','Select RoiSet.zip file');
%         cd(basedir);
%         mcdir = uigetdir([], 'Select folder containing .tif files to read.'); % get folder where files to read are
%     otherwise
%         basedir = varargin{1};
%         fname = varargin{2};
%         mcdir = varargin{3};
% end


[rois] = ReadImageJROI(fullfile(basedir,fname)); % read in ROIs, cells with structure containing ROI details
nROIs = size(rois,2);

% -- Get files to read
cd(mcdir)
filelist = dir('*.tif*'); % get a list of all .tif files in the folder
fnames = {filelist.name}'; % get filenames
nFiles = size(fnames, 1);

% define name of output file
savepath = fullfile(basedir, 'Facrosstrials.mat');

%% Read fluorescence
% timing stuff
fprintf('%s commenced reading of %i files (in ''%s'') with %i ROIs | outputting to %s\n', datestr(now,'HH:MM:SS'),...
    nFiles,mcdir(find(mcdir == filesep, 1,'last'):end), nROIs, basedir(find(basedir == filesep,2,'last')+1:end-1))
tmr.reset = '';
tmr.times = NaN(nFiles,4); % vector that will record how long each .tif takes

roimeans = cell(1,nFiles); % where the data will be stored

% -- Loop through files
for xfile = 1:nFiles
    tmr.times(xfile,1) = now;
    
    filetoRead = fnames{xfile}; % specify the trial's .tif filename
    tiftag = imfinfo(filetoRead); % load structure of metadata for each frame
    nFrames = numel(tiftag);
    
    % -- Create ROI masks (first loop only)
    if xfile == 1
        [X,Y] = meshgrid(1:tiftag(1).Width,1:tiftag(1).Height); % create grids with arbitrary numbers
        roimasks = false(tiftag(1).Width,tiftag(1).Height,nROIs); % mask is a width x height x nOIs logical that will define pixels of each ROI
        
        % -- Convert coordinates ROI outlines into x-y logical mask
        for xroi = 1:nROIs
            roicoords = rois{xroi}.mnCoordinates + 0.5; % retrieve roi coordinates and add 0.5 to align with what was drawn in ImageJ
            [in, on] = inpolygon(X,Y,roicoords(:,1),roicoords(:,2)); % check which pixels are (entirely) in or on (the edge of) area defined by roicoords
            roimasks(:,:,xroi) = in & ~on; % define roi as pixels within but not on the edge of the polygon
%             roimasks(:,:,xroi) = inpolygon(X,Y,rois{xroi}.mnCoordinates(:,1),rois{xroi}.mnCoordinates(:,2)); % the old code
        end
        
        % -- Remove overlapping true values
        if opts.preventoverlap % if the setting hasn't been changed
            
        end
        
    end

    roimeans{xfile} = NaN(nROIs,nFrames); % initialise matrix
    
    % -- Extract fluorescence
    for xframe = 1:nFrames
        singleframe = imread(fullfile(mcdir,filetoRead), xframe,'Info',tiftag); % load frame
        singleframe(singleframe < 100) = 0; % zero the dark noise
        
        % loop through ROIs
        for xroi = 1:nROIs
            roimeans{xfile}(xroi,xframe) = mean(singleframe(roimasks(:,:,xroi))); 
            % find the mean in singleframe of all pixels that are TRUE in the roi's mask
        end
    end
    
    % stuff for timing information
    tmr.times(xfile,2) = now;
    tmr.times(xfile,3) = (tmr.times(xfile,2) - tmr.times(xfile,1)) * 24 * 60 * 60;
    tmr.times(xfile,4) = nanmean(tmr.times(1:xfile,3)) * (size(tmr.times,1) - xfile) / 60; % estimated time remaining in minutes

    tmr.remainstr = datestr(minutes(tmr.times(xfile,4)),'MM:SS');
    tmr.msg = sprintf('%s %.2f pc done | file %i completed in %.2fs | %s remaining\n', datestr(now,'HH:MM:SS'), ...
        100*xfile/size(tmr.times,1), xfile, tmr.times(xfile,3), tmr.remainstr);
    fprintf([tmr.reset tmr.msg]);
    tmr.reset = repmat('\b',1,length(tmr.msg));
end

tmr.msg = sprintf('%s operation completed in %s | averaged %.2fs per file\n', datestr(now,'HH:MM:SS'), datestr(seconds(sum(tmr.times(:,3))),'MM:SS'),mean(tmr.times(:,3)));
fprintf([tmr.reset, tmr.msg]);

figure('Name','Operation completed','NumberTitle','off')
subplot(2,1,1)
cmap = parula(nROIs);
set(gca, 'ColorOrder', cmap, 'NextPlot', 'replacechildren');
plot(roimeans{1}')
xlabel('Frame');ylabel('Raw fluorescence');title('Fluorescence preview of all trials')

hold on
for xtrial = 2:nFiles
    plot(roimeans{xtrial}')
end
hold off
subplot(2,1,2)
plot(tmr.times(:,3))
xlabel('Loop');ylabel('Time (s)');title('Time per loop');yline(mean(tmr.times(:,3)),':');

varargout{1} = roimeans;
save(savepath, 'roimeans') % save the file

if opts.returntocd
    cd(current_directory) % return matlab to where it was
else
    cd(basedir) % set directory to where the file was saved
end
end