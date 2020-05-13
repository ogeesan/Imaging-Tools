function fig = mclogplot(mclog)
% --- Find session parameters
nTrials = size(mclog,2);
nFrames_list = 1:nTrials;
for trial = 1:nTrials
  nFrames_list(trial) = numel(mclog(trial).vshift);
end
nFrames_max = max(nFrames_list);

% --- Define 2D colormap
cmap_2d = calc_cmap_2d(15);

% --- calculate shifts
shifts = NaN(nTrials,nFrames_max,3);

for xtrial = 1:nTrials
  vshift = mclog(xtrial).vshift;
  hshift = mclog(xtrial).hshift;
  for frame = 1:numel(mclog(xtrial).vshift)
    xvshift = 16-vshift(frame);
    xhshift = hshift(frame) + 16;
    shifts(xtrial,frame,:) = cmap_2d(xvshift,xhshift,:);
  end
end

% this calculates difference in shifts, it's pretty useless
% for trial = 1:nTrials
%   dhshift = diff([mclog(trial).hshift(1) mclog(trial).hshift']);
%   dvshift = diff([mclog(trial).vshift(1) mclog(trial).vshift']);
%   for frame = 1:numel(mclog(trial).vshift)
%     % change -15:15 values to 1:31 for indexing into cmap_2d
%     xvshift = 16 - dvshift(frame); % reverse the index so 1st quadrant is +ve +ve
%     xhshift = dhshift(frame) + 16;
%     shifts(trial,frame,:) = cmap_2d(xvshift,xhshift,:);
%   end
% end

fig = image(shifts);

end