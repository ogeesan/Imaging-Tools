function zstacker(visualise,opts)
% zstacker() will prompt selection of a folder, which will then average all
% files together.
% 
% Two arguments:
%   visualise (optional) : true/false : show what everything looks like and
%       remove problematic frames
%   opts (optional) : complex settings, not required by most users


%{
George Stuyt 2020
version: 2020-10-29

sliceViewer requires 2019b
%}

%% Process inputs and decision trees


if nargin == 0; visualise = false;end
if nargin < 2; opts.default = true;end

savename = 'zstack.tif'; % the default name
if opts.default
    stack_dir = uigetdir([],'Pick directory of files');
else
    stack_dir = opts.stack_dir; % ability to define location, e.g. for programattic definition
end

%% Load directory of files
tic
directory = dir(fullfile(stack_dir,'*.tif*')); % get all tif files in that folder

% exclude file that matches the name of an already existing averaged zstack
tf = strcmp({directory.name},savename);
directory(tf) = [];

nFiles = size(directory,1);
for xfile = 1:nFiles
    imgpath = fullfile(directory(xfile).folder,directory(xfile).name);
    directory(xfile).path = imgpath;
    directory(xfile).info = imfinfo(imgpath); % load in imfinfo because it's faster to do it once
    directory(xfile).nFrames = numel(directory(xfile).info);
    directory(xfile).Height = directory(xfile).info(1).Height;
    directory(xfile).Width = directory(xfile).info(1).Width;
end

% - Validate that all of the files are the same
parameters = {'nFrames' 'Height' 'Width'};
for xparameter = 1:numel(parameters)
    parameter = parameters{xparameter};
    data = NaN(1,nFiles);
    for xfile = 1:nFiles % loop through the values
        data(xfile) = directory(xfile).(parameter);
    end
    
    if ~all(data == data(1)) % check if all the values are the same
        error('Files do not have the same parameters in %s:\n%s',parameter,num2str(data)) % ceases the script
    end
    
end

nFrames = numel(directory(1).info);
imheight = directory(1).info(1).Height;
imwidth = directory(1).info(1).Width;
fprintf('Identified %i files in %.2f seconds\n',nFiles,toc)
%% Load all the files in
rawdata = cell(nFrames,nFiles);
tic
msg = sprintf('Commenced loading in of %i frames...\n',numel(rawdata));
fprintf(msg)
for xframe = 1:nFrames
    for xfile = 1:nFiles
        img = imread(directory(xfile).path,xframe,'Info',directory(xfile).info);
        rawdata{xframe,xfile} = img;
    end
end
clearmsg = repmat('\b',1,numel(msg));
msg = sprintf('%i images loaded in %.2f seconds\n',numel(rawdata),toc);
fprintf([clearmsg msg])


%% Create visualisation if requested
if ~visualise

    avgdata = NaN(imheight,imwidth,nFrames);
    for xframe = 1:nFrames
        temp = mean(cat(3,rawdata{xframe,:}),3);
        avgdata(:,:,xframe) = temp;
    end
else
    [fname, fdir] = uigetfile([stack_dir filesep '*.*'],...
        'Select exclusion table file'); % get the location of the excluded frame .csv file

    % - Tile images from one slice into big image
    tiledata = cell(nFrames,1);
    for xframe = 1:nFrames
        temp = imtile(rawdata(xframe,:));
        temp = temp ./ prctile(temp,99,'all');
        temp(temp > 1) = 1;
        tiledata{xframe} = temp;
    end
    nrows = size(temp,1) / imheight;
    ncols = size(temp,2) / imwidth;
    
    % -- Create sliceView
    figure('Name','Each file tiled together','NumberTitle','off');
    sliceViewer(cat(3,tiledata{:})); % Requires 2019b
    set(gcf,'Position',[100 100 700 700])
    
    % -- Add text to identify which image is which file
    xfile = 0;
    for xrow = 1:nrows
        for xcol = 1:ncols
            xfile = xfile + 1;
            
            % if the image doesn't exist, don't draw a name
            if xfile > nFiles
                break
            end
            
            % get the middle of the image
            plts.ymid = round(xrow*imheight - imheight/2);
            plts.xmid = round(xcol*imwidth - imwidth/2);
            
            % offset and then write number of file
            text(plts.xmid - round(imheight*0.4),...
                plts.ymid - round(imwidth*0.45),...
                sprintf('file: %i',xfile),...
                'Color','w','FontSize',12)
        end
    end
    
    % -- Add lines to allow easier comparison
    cmap = repmat(0.3,1,3); % the right shade of grey
    for xrow = 1:nrows
        yline(xrow*imheight,'Color','w') % major line separating images
        yline(xrow*imheight - imheight/2,'Color',cmap); % centre cross
    end
    for xcol = 1:ncols
        xline(xcol*imheight,'Color','w')
        xline(xcol*imwidth - imwidth/2,'Color',cmap);
    end
    
    % - Preallocate the other figures
    figure('Name','Excluded frames','NumberTitle','off',...
        'Position',[200 200 400 400]);
    axexcluded = gca;
    
    figavg = figure('Name','Preview of zstack','NumberTitle','off',...
        'Position',[300 300 500 500]);
    
    flag = true;
    %%
    while flag % repeat the visual check and frame exclusion process until satified
        
        % - Process the exclusion
        df = readtable(fullfile(fdir,fname));
        framestf = true(nFiles,nFrames);
        for xblock = 1:height(df)
            xfile = df.file(xblock);
            frames = df.frames{xblock};
            frames = regexp(frames,'\d*','Match');
            frames = str2double(frames);
            framestf(xfile,frames(1):frames(2)) = false;
        end
        % -- Visualise the exclusion
        imagesc(framestf,'Parent',axexcluded)
        ylabel('File #');xlabel('Frame');title('Frames to exclude')
        colormap('bone')
        grid on
        set(gca,'XMinorGrid','on')
        
        % - Create an average but exclude tf
        avgdata = NaN(imheight,imwidth,nFrames);
        normdata = avgdata;
        for xframe = 1:nFrames
            tf = framestf(:,xframe);
            temp = mean(cat(3,rawdata{xframe,tf}),3);
            avgdata(:,:,xframe) = temp;
            
            temp = temp ./ prctile(temp,99,'all');
            temp(temp>1) = 1;
            normdata(:,:,xframe) = temp;
        end
        sliceViewer(normdata,'Parent',figavg)
        
        % - Decide whether to repeat the process of save the result
        answer = input('INPUT AN OPTION:\n    1: Reload and revisualise\n    2: Confirm and save\n','s');
        switch answer % 's' tag in input() results in everything being str
            case '1'
                fprintf('Reloading...\n')
            case '2'
                fprintf('Confirming and saving...\n')
                break % break out of this while loop
        end
        
        %{
        this is old code that tries to use a GUI, but since interacting
        with the other plots is required this questdlg() needs to be
        non-modal, which would be a pain to write so instead I use input()
        answer = questdlg('Next step?',...
            'Determine next step',...
            'Confirm and save','Reload and reexamine',...
            'Reload and rexamine');
        switch answer
            case 'Confirm and save'
                break % break out of this while loop
            case 'Reload and rexamine'
                fprintf('Reloading...\n')
        end
        %}
    end
end

%% save the final product
tic
savepath = fullfile(stack_dir,savename); % save the zstack into the folder
tiffsaveexists = exist('saveastiff','file'); % check that the person is using the better tiffsaving

for xframe = 1:nFrames
    tiffopts.message = false;
    frame = avgdata(:,:,xframe);
    frame = uint16(frame); %! conversion necessary for neuTube loading
    % -- Write frame into new .tif file
    if xframe == 1 % if first frame then write a new file
        tiffopts.overwrite = true; % overwrite if there's already something there
        if tiffsaveexists
            saveastiff(frame,savepath,tiffopts);
            tiffopts.append = true; % from now on append frames onto the file
            tiffopts.overwrite = false;
        else
            imwrite(frame, savepath, 'Tiff', 'Compression', 'none', 'WriteMode', 'overwrite');
        end
    else % append frame to the existing file
        flag = 1;
        while flag
            try
                if tiffsaveexists
                    saveastiff(frame,savepath,tiffopts);
                else
                    imwrite(frame, savepath, 'Tiff', 'Compression', 'none', 'WriteMode', 'append'); % append the next frame
                end
                flag = 0;
            catch
                pause(0.2);
            end
        end
    end
end
fprintf('%s %s saved in %.2f seconds\n',datestr(now,13),savepath,toc)
%% Some legacy stuff that does what sliceViewer does but worse
% imh = imagesc(tiledata{1});
% axis equal
% ylim([0 size(tiledata{1},1)])
%
% % -- Add text description to each tile
%
% xfile = 0;
% for xrow = 1:nrows
%     for xcol = 1:ncols
%         xfile = xfile + 1;
%         plts.ymid = round(xrow*imheight - imheight/2);
%         plts.xmid = round(xcol*imwidth - imwidth/2);
%         if xfile > nFiles
%             break
%         end
%
%         text(plts.xmid - round(imheight*0.4),...
%             plts.ymid - round(imwidth*0.45),...
%             sprintf('file: %i',xfile),...
%             'Color','w','FontSize',12)
%     end
% end
%
% % -- Add lines to allow easier comparison
% temp = repmat(0.3,1,3);
% for xrow = 1:nrows
%     yline(xrow*imheight,'Color','w')
%     yline(xrow*imheight - imheight/2,'Color',temp);
% end
% for xcol = 1:ncols
%     xline(xcol*imheight,'Color','w')
%     xline(xcol*imwidth - imwidth/2,'Color',temp);
% end
%
%
%
% fps = 15;
% for xframe = 1:nFrames
%     tic
%     imh.CData = tiledata{xframe};
%     pause(1/fps - toc)
% end
