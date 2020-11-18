Hola, this bad boy's a Matlab app for navigating through calcium traces. The prime aim is to increase the speed of navigating through the data, and so there are keyboard shortcuts.

# How to install and use

1. To install, open the Calcium Trace Navigator.mlappinstall file. The app is now accessible in the Apps tab in MATLAB.

2. A `dffmat` is required to exist in the workspace (an example can be loaded in with the dff_example.mat).

3. Check out the Help button in the app to see the keyboard shortcuts for speedy navigation.

# More information

The app takes `dffmat` **from the Workspace** and visualises it. `dffmat` is a cell of size nTrials x nROIs, where each cell contains a single dff trace.

Plotting by Trial shows a single trial with all ROIs, and plotting by ROI does the opposite. The Waterfall setting explodes out the traces according to their number so that the first trial is at the top (y-values correspond to the trial/roi).

The dffarray lamp will be green when the `dffmat` meets criteria, yellow when it does not, and red when the variable does not exist in the workspace.

The .mlapp file is the App Designer script I've used to make the app, which you might be interested in if you want to build your own visualisation app.

### Threshold and filtering

A threshold can be used to filter out traces, which will occur when the Filter button is active.

The threshold can either be a number or a three number argument for a std window based calculation. The first value will be  *n* \* STD, and the next two numbers will define the index (window) to calculate the std from. For example, '`3 1:30`' is equivalent to 3 times the std of `data(:,1:30)`, where `data` is all traces that would be plotted.

### Choosing which variable to load

The top-left box that contains "dffmat" specifies the name of the variable the Navigator will look for. However, it will almost always be the case that it will be easier to use a script to replace `dffmat` with what you're interested in.

### Exporting the graph

Hover your mouse at the top right of the plot should show an export-looking arrow, and in that menu there is an option to save the plot. 