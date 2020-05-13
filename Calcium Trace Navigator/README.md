Hola, this bad boy is a Matlab app for navigating through calcium traces. It will hopefully make manually identifying poor quality trials and ROIs much faster. **To install, open the Calcium Trace Navigator.mlappinstall file**. The app is now accessible in the Apps tab in MATLAB.

The app takes `dffarray` and visualises it. `dffarray` is a cell of size 1 x nTrials. Inside of each cell there's a matrix of size nROIs x nFrames. `dffarray` is taken from the Workspace (Matlab's variables).

Included is dffarray_example.mat which can be loaded into the workspace to see what the visualisation looks like.

Plotting by Trial shows a single trial with all ROIs, and plotting by ROI does the opposite. The Waterfall setting explodes out the races according to their number so that the first trial is at the top (y-values correspond to the trial/roi).