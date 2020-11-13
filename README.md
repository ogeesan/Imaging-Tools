Hallo and welcome to a collection of (Matlab) tools I've made for the lab. Or, if you always want it up to date, you could use Git to link a folder that will always be updated.

Each folder contains a script, and there's a readme file that explains things if you need them. Note that some files have functions that you will need to get from the Matlab File Exchange.

If you find an error while using something in this repository let me know, because this stuff is meant to work for anyone.

# How to use

Some of these tools can be used out of the box, like `correct_motion_GS` and `mclogplot` because there isn't a whole lot of room or reason for variation. But things like dff calculation and event detection are highly dependent on your dataset. I wouldn't use those tools without having read through the code first to understand what's going on.

# How to add the scripts into MATLAB

You could copy/paste the scripts you need into your MATLAB folder, or you could add the scripts into the PATH (`Home > Set Path > Add with Subfolders` to make visible to MATLAB). 

Alternatively, the paths could be added using a script:

```matlab
addpath(genpath('C:\path\to\the\folder\you\want'));
```

`genpath()` will generate paths to all folders and subfolders, while `addpath()` add the given paths to the MATLAB Path. The MATLAB Path is the list of all folders that MATLAB will search for when looking for a script or file.

Personally, I use the `addpath()` method with the [`startup.m` method](https://au.mathworks.com/help/matlab/ref/startup.html) so that I don't have to manually do anything.

# The tools

- Calcium Trace Navigator: Matlab App for quickly visualising different trials and ROIs.

- Calculate DFF | `calc_dff`: convert roimeans to dffmat

- Convert DFF store | `convert_dffstore`: convert between dffmat (Luca's) and dffarray (George's) method of storing data if you have to

- Data Collation: an example of my collation system.

- Detect Calcium Events | `detect_events`: my event detection system for low-activity z-movement susceptible dendrites, which can be adapted to your own needs

- Fluorescence Extraction | `readroi_GS`: extract fluorescence signals from .tif files, with more predictable ROI pixel definition and exclusion of sub-100 values.

- Hierarchical Clustering Visualisation | `clustervis`: quick 'n dirty clustering visualisation

- Lick Extractor | `getlicks`: easily get PortIn and PortOut events from Bpod

- Motion Correction | `correct_motion_GS`: Takahashi's code but with preservation of negative values and some usability improvements.

- Motion Correction Reversal | `reverse_correct_motion`: go from motion corrected files and a mclog.mat file to the raw .tifs again.

- Motion Correction Visualisation | `mclogplot`: visualisation of x-y offset of frames from an `mclog.mat` file. 

- zstacker | `zstacker`: average together multiple sweeps to form a single zstacker