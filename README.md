Hallo and welcome to a collection of (Matlab) tools I've made for the lab. Or, if you always want it up to date, you could use Git to link a folder that will always be updated.

Each folder contains a script, and there's a readme file that explains things if you need them. Note that some files have functions that you will need to get from the Matlab File Exchange.

If you find an error while using something in this repository let me know, because this stuff is meant to work for anyone.

# How to use

You could copy/paste the scripts you need into your MATLAB folder, or you could add the scripts into the PATH (`Home > Set Path > Add with Subfolders` to make visible to MATLAB). 

Alternatively, the paths could be added using a script:

```matlab
addpath(genpath('C:\path\to\the\folder\you\want'));
```

`genpath()` will generate paths to all folders and subfolders, while `addpath()` add the given paths to the MATLAB Path. The MATLAB Path is the list of all folders that MATLAB will search for when looking for a script or file.

Personally, I use the `addpath()` method with the [`startup.m` method](https://au.mathworks.com/help/matlab/ref/startup.html) so that I don't have to manually do anything.

# The tools

- Calcium Trace Navigator: Matlab App for quickly visualising different trials and ROIs.

- Convert DFF store: convert between dffmat (Luca's) and dffarray (George's) method of storing data if you have to

- Data Collation: an example of my collation system.

- Detect Calcium Events: a out-of-the-box usable event detection, which should really be used as a scaffold for your own system.

- Fluorescence Extraction: extract fluorescence signals from .tif files, with more predictable ROI pixel definition and exclusion of sub-100 values.

- Hierarchical Clustering Visualisation: quick 'n dirty clustering visualisation

- Lick Extractor: easily get PortIn and PortOut events from Bpod

- Motion Correction: Takahashi's code but with preservation of negative values and some usability improvements.

- Motion Correction Visualisation: visualisation of x-y offset of frames from an `mclog.mat` file. 

- Motion Correction Reversal: go from motion corrected files and a mclog.mat file to the raw .tifs again.

- zstacker: average together multiple sweeps to form a single zstacker