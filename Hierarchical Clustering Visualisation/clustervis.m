% clustervis
function clustervis(data, varargin)
% clustervis(data, [optional cluster number]), data is matrix where each row is a different object
%{
Hierarchical clustering tool
George Stuyt September 2020
Version: 2020-09-18


%}
%% Perform clustering and maths

% -- Internal parameters
linkagetype = 'ward'; % the type of clustering used in linkage() and clusterdata()
wss_sample_proportion = 0.3; % proportion of total possible clusters to use in the wss calculation

% -- Calculate distances between each point
distancevector = pdist(data); % get distance between all observations (rows)
% is a vector of distances of all combinations aka (size(data,1) C 2)

% -- Perform clustering
clustertree = linkage(distancevector,linkagetype); % cluster links Ward's method
% each row is formation of new cluster, with distance in (x,3) position

% -- Optimise leaf order
leaforder = optimalleaforder(clustertree,distancevector); % define order of nodes according to similarity
% it's used to make the dendrogram pretty and ordered

% -- Determine number of final clusters
nSamples = round(size(clustertree,1) * wss_sample_proportion);

wss = plotScree(data,nSamples,linkagetype); % calculate the within-cluster sum of squares for 1:nSamples final cluster numbers
if nargin == 1 % if unspecified
    nClusters = findelbow(wss); % use an automated solution
elseif nargin == 2 % if specified
    nClusters = varargin{1};
end

% -- Allocate final clusters
clustercategory = cluster(clustertree,'MaxClust',nClusters); % elbow point cluster numbers

%% Plot the figure

% -- A. Plot dendrogram
dend_thresh = clustertree(end-nClusters+2,3)-eps;
% a linkage distance threshold is used to colour the final clusters, so we
% need to find the distance that separates nClusters and nClusters+1

subplot(2,2,1) % initialise 2x2 grid figure, activate first plot space
[~, ~, dendro_order] = dendrogram(... % dendro_order specifies what order the nodes have been moved to on the dendrogram (after Reorder)
    clustertree,... % the record of each node and its clustering order/distance
    0,... % number of nodes to show, 0 = show all of them
    'orientation','left',... % flip it horizontally to align with heatmap
    'Reorder',leaforder,... % optimise leaforder
    'ColorThreshold',dend_thresh); % cut the dendrogram at this value and give clusters below a unique colour
title('A. Dendrogram')
% xline(dend_thresh,'--'); % add line where clusters are being cut (if you're interested)
yticks([]) % remove yticks because they'll be shown in the heatmap plot
xlabel('Linkage distance')
xlim([0 clustertree(end,3)]) % the maximum linkage distance for a nice fit
ax = gca; % used for later access to align plot A with plot B

% -- B. Plot heatmap matched to dendrogram
subplot(2,2,2)
imagesc(data(flip(dendro_order),:)) 
% dendro_order is from bottom to top, but imagesc plots top to bottom
% flip() just reverses the order of the vector
title('B. Reordered data')

ylabel('Objects ordered by dendrogram');
grid on; set(gca,'tickdir','out');
ax.YLim = get(gca,'YLim'); % set plot A axis to match plot B
heatmap_xlim = get(gca,'XLim'); % store xlim to set plot D's

% -- C. Elbow method visualisation
subplot(2,2,3)
plot(wss,'.-')
title('C. Elbow point')
box off; grid on
xline(nClusters,'--','Elbow','LabelVerticalAlignment','Top'); % draw line where elbow is being decided
xlabel('Number of clusters')
ylabel('Avg. Within-cluster sum-of-squares')
xlim([1 inf])

% -- Plot averaged traces
subplot(2,2,4)
groups = unique(clustercategory(flip(dendro_order)),'stable'); % get the unique groups, in order as they are in outperm
% this should mean that the top group of plot A is plotted as blue, the
% second as red (following the default ColorOrder)
avgdata = cell(numel(groups),1); % pre-allocate storage of data
for xgroup = 1:numel(groups) % iterate through each cluster group
    current_group = groups(xgroup); % get number of current group
    avgdata{xgroup} = data(clustercategory == current_group,:); % get all traces that are in the group/cluster
    avgdata{xgroup} = nanmean(avgdata{xgroup},1); % mean of those values
end
avgdata = vertcat(avgdata{:}); % convert cell array into matrix
plot(avgdata')
title('D. Averages of clusters')
xlim(heatmap_xlim) % align to plot B
box off; grid on
ylabel('Averaged value')
xlabel('Sample points')
sgtitle(sprintf('Hierarchical clustering with %i final clusters',nClusters))

end
%% functions
function wss = plotScree(data, nSamples, linkagetype)
% taken from: https://stackoverflow.com/questions/8016313/agglomerative-clustering-in-matlab?rq=1

%{
Calculate the average within-cluster sum-of-squares for each potential
number of final clusters. nSamples defines how many different clusters to
check for. I don't really get what happens in the loop but it looks right.
%}

wss = zeros(1, nSamples); % initialise vector that the wss values willbe stored in
wss(1) = (size(data, 1)-1) * sum(var(data, [], 1)); % get wss for when all data is in one cluster

for nClusters = 2:nSamples
    clustercategory = clusterdata(data,'maxclust',nClusters,'linkage',linkagetype); % get which cluster each data point is in
    wss(nClusters) = sum(...
        (grpstats(clustercategory, clustercategory, 'numel')-1) ... % total number of objects in each cluster
        .* sum(grpstats(data, clustercategory, 'var'), 2)... % sum of variances in each of those clusters
        );
end

end

function idxOfBestPoint = findelbow(wsscurve)
% taken from: https://stackoverflow.com/questions/2018178/finding-the-best-trade-off-point-on-a-curve
% these comments aren't mine (George)

%# get coordinates of all the points
nPoints = numel(wsscurve);
allCoord = [1:nPoints;wsscurve]';              %'# SO formatting

%# pull out first point
firstPoint = allCoord(1,:);

%# get vector between first and last point - this is the line
lineVec = allCoord(end,:) - firstPoint;

%# normalize the line vector
lineVecN = lineVec / sqrt(sum(lineVec.^2));

%# find the distance from each point to the line:
%# vector between all points and first point
vecFromFirst = bsxfun(@minus, allCoord, firstPoint);

%# To calculate the distance to the line, we split vecFromFirst into two 
%# components, one that is parallel to the line and one that is perpendicular 
%# Then, we take the norm of the part that is perpendicular to the line and 
%# get the distance.
%# We find the vector parallel to the line by projecting vecFromFirst onto 
%# the line. The perpendicular vector is vecFromFirst - vecFromFirstParallel
%# We project vecFromFirst by taking the scalar product of the vector with 
%# the unit vector that points in the direction of the line (this gives us 
%# the length of the projection of vecFromFirst onto the line). If we 
%# multiply the scalar product by the unit vector, we have vecFromFirstParallel
scalarProduct = dot(vecFromFirst, repmat(lineVecN,nPoints,1), 2);
vecFromFirstParallel = scalarProduct * lineVecN;
vecToLine = vecFromFirst - vecFromFirstParallel;

%# distance to line is the norm of vecToLine
distToLine = sqrt(sum(vecToLine.^2,2));

%# now all you need is to find the maximum
[~,idxOfBestPoint] = max(distToLine);
end