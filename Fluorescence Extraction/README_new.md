This is the script for extracting fluorescence from .tif files.

1. Select the .zip file containing the ROIs.

2. Select the folder containing .tif files to read.

Facrosstrials.mat will be output to the same location as the .zip file.

## How it works

Each pixel in the .tif file has a value reflecting its "brightness". The reading of an ROI takes the average value from within a shape defined in an .roi file.

### Main change: ROI reading is now pixel perfect
The major change that what you draw in ImageJ is now what you get in MATLAB. In older `readroi` scripts, an ROI that appears (in ImageJ) to cover a 3x3 square would actually be treated as a 4x4 square in the script, and other weirdness like that. It probably doesn't make a difference in the end, but I fixed that. So now when you draw your ROIs you can know two things:

1. The ROI you draw is now the ROI that MATLAB sees.
2. Only pixels that are entirely within the area of the ROI are included in the fluorescence extraction.

#### Extra detail

What was the problem and what was changed to fix it?

<<<<<<< Updated upstream
Each ROI is a shape defined by a series of X-Y coordinates, like a connect-the-dots. When you draw your ROI in ImageJ, you'll notice that the vertices/nodes/points of your ROI are at the corners of pixels, not the centre of them. But ImageJ records the vertices of the ROI as being in the centre of the pixel to the downwards-right of where the vertices appear when drawing it. In other words, all coordinates that define the ROI are shifted +0.5 right and +0.5 down to where they are drawn. What we're seeing is not what we're getting, and this produces some unexpected behaviours when the ROIs are brought into Matlab.

`ReadImageJROI` extracts these coordinates from ImageJ's files, and `readroi` feeds this into the function `inpolygon`. `inpolygon` asks the question: "is this pixel in the shape?" There are three answers: yes, no, and *on* the edge. Because the ROIs were being defined according to coordinates at the centre of pixels and that `inpolygon` was returning pixels that were on the ROI edges, pixels that you wouldn't expect to be part of the ROI were being read.

So what have I changed exactly? 

1. I've subtracted 0.5 from the coordinates that are received, making them align with what is drawn in ImageJ.

2. I've altered the logic for `inpolygon` by making it only include pixels that entirely within the shape. Basically, what you see in ImageJ is exactly what you're getting in Matlab.
