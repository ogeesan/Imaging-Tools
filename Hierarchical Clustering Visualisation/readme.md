# Hierarchical Clustering Visualisation
## How to use
`clustervis(data,[nClusters])`, where `data` is a matrix where each row is a different object (e.g. different cell) and each column is a different sample (e.g. time point). `[nClusters]` is an optional argument that determines how many final groups `data` will be placed into.

Considerations:
- Traces in plot D aren't colour-matched to plot A
- Remember to consider how to/if to normalise your data (e.g. own maximum, z-score)

## How does hierarchical clustering work?
I'd recommend you watch this YouTube video:

https://www.youtube.com/watch?v=7xHsRkOdVwo

The code just implements that.

## How do I extract the sub-populations that the clustering creates?
That has to be done separately `clustervis()` is mainly a visualisation aide. An example workflow is this:

1. Feed `clustervis()` your `data` without specifying `nClusters` to see how things pan out.
2. Play with `nClusters` until you find something that seems right.
3. Use `clusterdata(data,'linkage','ward','maxclust',[your number])` to return the categories that each value has been sorted into.
4. From then it'd require checking the number of values in each cluster to cross-reference with the `clustervis()`' dendrogram.

Either way, pulling apart the pieces of the function to use them yourself won't hurt.

## Determining number of final clusters
The method that's used here is the *within-cluster sum-of-squares*, which is just one method for determing how many final clusters should be used. 

### What's happening when I don't specify `nClusters`?
If the second argument isn't entered into `clustervis()` then the function automatically finds a number of clusters that may or may not work.

In the C plot, imagine drawing a line between the first and last points. Then, find the point that is the furthest from that line --- that's the number of clusters that'll be used.