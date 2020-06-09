function varargout = mclogplot(mclog,options)
% options (image, maxoffset) are optional
%{
George Stuyt 3rd June 2020
Creates visualisation of motion correction offsets using a two dimensional
colourmap.
%}

% -- Define options
if nargin == 1
    options.image = true;
end

if ~isfield(options,'maxmode');options.maxmode = 'black';end % scale plot (scale) or make >maxoffset values black
if ~isfield(options,'maxoffset'); options.normoffset = 15;end % the normal maximum offset (to keep colours consistent)
if ~isfield(options,'meancentre');options.meancentre = false;end % isn't really worth it
if ~isfield(options,'shifts');options.shifts = false;end
if ~isfield(options,'image');options.image = true;end

nTrials = size(mclog,2);

% -- Centre offsets on mean offset if requested
% not recommended, doesn't really change anything
if options.meancentre
    % find mean offsets
    meanoffsets = NaN(nTrials,2);
    for trial = 1:nTrials
        meanoffsets(trial,1) = mean(mclog(trial).vshift);
        meanoffsets(trial,2) = mean(mclog(trial).hshift);
        
    end
    meanoffsets = mean(meanoffsets,1);
    meanoffsets = round(meanoffsets); % [vshift hshift] mean
    
    % offset the offsets by mean offset amount
    for trial = 1:nTrials
        mclog(trial).vshift = meanoffsets(1) + mclog(trial).vshift;
        mclog(trial).hshift = meanoffsets(2) + mclog(trial).hshift;
    end
end

% -- Check for maximum possible mclog offset amount
nFrames_list = 1:nTrials;
maxoffset = NaN(nTrials,2);

for trial = 1:nTrials
  nFrames_list(trial) = numel(mclog(trial).vshift);
  maxoffset(trial,1) = max(abs(mclog(trial).vshift));
  maxoffset(trial,2) = max(abs(mclog(trial).hshift));
end

maxoffset = max(maxoffset,[],'all'); % maximum offset value in session
nFrames_max = max(nFrames_list);

% -- Define 2D colormap
if options.normoffset > maxoffset
    maxoffset = options.normoffset;
end
normoffset = options.normoffset;

switch options.maxmode
    case 'scale'
        cmap_2d = calc_cmap_2d(maxoffset);
        
    case 'black'
        cmap_2d = calc_cmap_2d(normoffset);
        tempmap = zeros(maxoffset*2+1,maxoffset*2+1,3);
        shiftvalues = -maxoffset:maxoffset;
        d = sqrt((normoffset/maxoffset)^2/2);
        valuemap = @(x) 1/(1-d)*x + 1 - 1/(1-d);
        for x = 1:maxoffset*2+1
            for y = 1:maxoffset*2+1
                
                hshift = shiftvalues(x);
                vshift = shiftvalues(y);
                % use XY coordinates to map into HSV colorspace
                value = sqrt(abs(vshift)^2 + abs(hshift)^2)/sqrt(2*maxoffset^2); % represent magnitude of change in saturation
                value = valuemap(value);
                if abs(hshift) <= normoffset && abs(vshift) <= normoffset
                    value = 0;
                end
                % convert HSV values to RGB and insert into cmap_2d
                rgb = hsv2rgb([0 0 value]);
                tempmap(x,y,:) = rgb';
            end
        end
        topleftcorner = maxoffset - normoffset + 1;
        tempmap(topleftcorner:topleftcorner + normoffset*2,topleftcorner:topleftcorner + normoffset*2,:) = cmap_2d;
        cmap_2d = tempmap;
    otherwise
        error('maxmode option not recognised')
end

% -- Calculate shifts
shifts = NaN(nTrials,nFrames_max,3); % initialise the image

for xtrial = 1:nTrials
  vshift = mclog(xtrial).vshift; % get shift values for this trial
  hshift = mclog(xtrial).hshift;
  

  for frame = 1:numel(mclog(xtrial).vshift)
    xvshift = vshift(frame) + maxoffset + 1; % convert shift values to index into the cmap
    xhshift = hshift(frame) + maxoffset + 1;
    shifts(xtrial,frame,:) = cmap_2d(xvshift,xhshift,:); % take a colour from the cmap corresponding to the x-y shift position
  end
end

% -- Define output of function
if options.image; image(shifts);end
if options.shifts
varargout{1} = shifts;
end


end