function cmap_2d = calc_cmap_2d(shiftmax)
% shiftmax = maximum value of offset
hshifty = -shiftmax:shiftmax;
vshifty = flip(hshifty);
shifts = shiftmax * 2 + 1;
cmap_2d = zeros(shifts,shifts,3);
% loop through each position in cmap_2d
for xvshift = 1:shifts
    for xhshift = 1:shifts
        % get the representative offset values
        hshift = hshifty(xhshift);
        vshift = vshifty(xvshift);
        
        % use XY coordinates to map onto HSV colorspace
        hue = 0.5 + atan2d(vshift,hshift)/360; % represent direction of change
        saturation = sqrt(abs(vshift)^2 + abs(hshift)^2)/sqrt(2*shiftmax^2); % represent magnitude of change
        value = 1 - (abs(vshift) + abs(hshift)) /shifts; % 
        
        % convert HSV values to RGB and insert into cmap_2d
        rgb = hsv2rgb([hue saturation value]);
        cmap_2d(xvshift,xhshift,1) = rgb(1);
        cmap_2d(xvshift,xhshift,2) = rgb(2);
        cmap_2d(xvshift,xhshift,3) = rgb(3);
    end
end
% THE OLD CODE USED TO BUILD IT BOI
% % Define 2D colormap
% plotem = false;
% shiftmax = 15; % the maximum pixel offset value
% hshifty = -shiftmax:shiftmax;
% vshifty = flip(hshifty);
% shifts = shiftmax * 2 + 1;
% cmap_2d = zeros(shifts,shifts,3);
% loop through each position in cmap_2d
% for xvshift = 1:shifts
%     for xhshift = 1:shifts
%         get the representative offset values
%         hshift = hshifty(xhshift);
%         vshift = vshifty(xvshift);
%         
%         use XY coordinates to map onto HSV colorspace
%         hue = 0.5 + atan2d(vshift,hshift)/360; % represent direction of change
%         saturation = sqrt(abs(vshift)^2 + abs(hshift)^2)/sqrt(2*shiftmax^2); % represent magnitude of change
%         value = 1 - (abs(vshift) + abs(hshift)) /shifts; % 
%         
%         convert HSV values to RGB and insert into cmap_2d
%         rgb = hsv2rgb([hue saturation value]);
%         cmap_2d(xvshift,xhshift,1) = rgb(1);
%         cmap_2d(xvshift,xhshift,2) = rgb(2);
%         cmap_2d(xvshift,xhshift,3) = rgb(3);
%     end
% end
% if plotem == true
%   subplot(3,4,[1 2 3; 5 6 7; 9 10 11])
%   image(cmap_2d)
%   title('2D colormap')
%   xlabel('hshift (x shift)');xticks(1:5:31);xticklabels(-15:5:15)
%   ylabel('vshift (y shift)');yticks(1:5:31);yticklabels(flip(-15:5:15))
%   axis square
% end
% 
% demonstration of representation
% if plotem == true
%   for xhsv = 1:3
%     cmap_eg = ones(shifts,shifts,3);
%     for xvshift = 1:shifts
%       for xhshift = 1:shifts
%         hshift = hshifty(xhshift);
%         vshift = vshifty(xvshift);
%         base = 1;
%         hue = base;
%         saturation = base;
%         value = base;
%         use XY coordinates to map onto HSV colorspace
%         if xhsv == 1
%           hue = 0.5 + atan2d(vshift,hshift)/360; % represent direction of change
%         elseif xhsv == 2
%           saturation = sqrt(abs(vshift)^2 + abs(hshift)^2)/sqrt(2*shiftmax^2); % represent magnitude of change
%         elseif xhsv == 3
%           value = 1 - (abs(vshift) + abs(hshift)) /shifts; %
%         end
%         
%         convert HSV values to RGB and insert into cmap_2d
%         rgb = hsv2rgb([hue saturation value]);
%         cmap_eg(xvshift,xhshift,1) = rgb(1);
%         cmap_eg(xvshift,xhshift,2) = rgb(2);
%         cmap_eg(xvshift,xhshift,3) = rgb(3);
%       end
%     end
%     
%     subplot(3,4,xhsv*4)
%     image(cmap_eg)
%     axis square
%     if xhsv == 1
%       title({'Hue' 'Direction of change'})
%     elseif xhsv == 2
%       title({'Saturation' 'Magnitude of change'})
%     else
%       title({'Value' 'Distance from axes kinda'})
%     end
%   end
% end
end