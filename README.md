Hallo and welcome to a collection of (Matlab) tools I've made for the lab. You can download this repository as a .zip file with the big 'ol green button. Or, if you always want it up to date, you could use Git to link a folder that will always be updated.

Each folder contains a script, and there's a readme file that explains things if you need them. Note that some files have functions that you will need to get from the Matlab File Exchange.

If you find an error while using something in this repository let me know, because this stuff is meant to work for anyone.

# The tools

- Calcium Trace Navigator: Matlab App for quickly visualising different trials and ROIs.

- Data Collation: an example of my collation system.

- Fluorescence Extraction: extract fluorescence signals from .tif files, with more predictable ROI pixel definition and exclusion of sub-100 values.

- Hierarchical Clustering Visualisation: quick 'n dirty clustering visualisation

- Lick Extractor: easily get PortIn and PortOut events from Bpod

- Motion Correction: Takahashi's code but with preservation of negative values and some usability improvements.

- Motion Correction Visualisation: visualisation of x-y offset of frames from an `mclog.mat` file. 

- Motion correction reversal: go from motion corrected files and a mclog.mat file to the raw .tifs again.
