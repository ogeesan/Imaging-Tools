function fig = mclogplot(mclog)
% converts mclog struct into an image
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
    xvshift = 16-vshift(frame); % convert shift values to index into the cmap
    xhshift = hshift(frame) + 16;
    shifts(xtrial,frame,:) = cmap_2d(xvshift,xhshift,:); % take a colour from the cmap corresponding to the x-y shift position
  end
end

fig = image(shifts);

end