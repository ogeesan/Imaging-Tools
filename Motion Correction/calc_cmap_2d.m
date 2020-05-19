function cmap_2d = calc_cmap_2d(shiftmax)
% shiftmax = maximum value of offset
% generates cmap_2d, an image that's used to visualise 2D coordinates

% get values to index into for each coordinate
% (centre of image is 0-0
hshifty = -shiftmax:shiftmax;
vshifty = flip(hshifty);

nShifts = shiftmax * 2 + 1; % number of total shifts
cmap_2d = zeros(nShifts,nShifts,3); % initialise the image

% loop through each position in cmap_2d
for xvshift = 1:nShifts
    for xhshift = 1:nShifts
        % get the representative offset values
        hshift = hshifty(xhshift);
        vshift = vshifty(xvshift);
        
        % use XY coordinates to map into HSV colorspace
        hue = 0.5 + atan2d(vshift,hshift)/360; % represent direction of change on the colourwheel
        saturation = sqrt(abs(vshift)^2 + abs(hshift)^2)/sqrt(2*shiftmax^2); % represent magnitude of change in saturation
        value = 1 - (abs(vshift) + abs(hshift)) / nShifts; % add in some up/down representation as well
        
        % convert HSV values to RGB and insert into cmap_2d
        rgb = hsv2rgb([hue saturation value]);
        cmap_2d(xvshift,xhshift,1) = rgb(1);
        cmap_2d(xvshift,xhshift,2) = rgb(2);
        cmap_2d(xvshift,xhshift,3) = rgb(3);
    end
end
end
                    