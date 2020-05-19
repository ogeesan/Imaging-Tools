Hola, this bad boy is a Matlab app for navigating through calcium traces. The prime aim is to increase the speed with which we navigate through our data.

-  **To install, open the Calcium Trace Navigator.mlappinstall file**. The app is now accessible in the Apps tab in MATLAB.

- a `dffarray` is required to exist in the workspace.



The dffarray_example.mat is some example data to test the visualisation on.

The app takes `dffarray` and visualises it. `dffarray` is a cell of size 1 x nTrials. Inside of each cell there's a matrix of size nROIs x nFrames. `dffarray` is taken from the Workspace (Matlab's variables).

Plotting by Trial shows a single trial with all ROIs, and plotting by ROI does the opposite. The Waterfall setting explodes out the traces according to their number so that the first trial is at the top (y-values correspond to the trial/roi).

The dffarray lamp will be green when the `dffarray` meets criteria, yellow when it does not, and red when the variable does not exist in the workspace.

### Threshold and filtering

A simple thresholding system can be used to filter out traces with no events. Any trace that does not cross the threshold will be filtered out of view when the Filter button is active.

### Exporting the graph

To export what you see, hovering your mouse at the top right of the plot should show an export-looking arrow, and in that menu there is an option to save the plot. 