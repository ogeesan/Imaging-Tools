function varargout = mclogplot(mclog,option)
% option = false will prevent figure being drawn, otherwise defaults to
% creating new figure
%{
George Stuyt 3rd June 2020
Creates visualisation of motion correction offsets using a two dimensional
colourmap.
%}

% -- Find session parameters
nTrials = size(mclog,2);
nFrames_list = 1:nTrials;
for trial = 1:nTrials
  nFrames_list(trial) = numel(mclog(trial).vshift);
end
nFrames_max = max(nFrames_list);

% -- Define 2D colormap
cmap_2d = calc_cmap_2d(15);

% -- Calculate shifts
shifts = NaN(nTrials,nFrames_max,3); % initialise the image

for xtrial = 1:nTrials
  vshift = mclog(xtrial).vshift; % get shift values for this trial
  hshift = mclog(xtrial).hshift;
  for frame = 1:numel(mclog(xtrial).vshift)
    xvshift = vshift(frame) + 16; % convert shift values to index into the cmap
    xhshift = hshift(frame) + 16;
    shifts(xtrial,frame,:) = cmap_2d(xvshift,xhshift,:); % take a colour from the cmap corresponding to the x-y shift position
  end
end

% -- Define output of function
if nargin > 1 % if option was specified
    switch option
        case true % output the object itself
        varargout{1} = image(shifts);
    end
else
    image(shifts)
end
    
varargout{2} = shifts;


end