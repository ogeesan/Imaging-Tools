Requires: [Multipage TIFF stack - File Exchange - MATLAB Central](https://au.mathworks.com/matlabcentral/fileexchange/35684-multipage-tiff-stack)

# How to use

1. Run script

2. Select the file that will serve as the template.

3. Select the folder containing the files you want to motion correct.

4. Select the folder you want to save the motion corrected files to.

# Changes to data

1. Negative values are no longer removed
   The old code was using `imwrite()` which can't handle negative values (which exist in the raw files), so `saveastiff()`  ([source](https://au.mathworks.com/matlabcentral/fileexchange/35684-multipage-tiff-stack)) is used instead.

2. Search window widened to 40 pixels
   In the old code, if the real offset for a frame was more than 15 pixels then this could not be done. I've widened the search window to 40 pixels.

3. Allowance for negative correlation
   Sometimes, the maximum correlation between the frame and the base is negative. In the old code this was not recognised due to the method for defining the search window. I've altered the method (converted 0s to NaNs) so that if a negative value is the maximum then it will be used.

The first change simply preserves data. Negative values are actually just noise, but excluding them during motion correction is probably a bad idea so `readroi_GS` will do that instead.

The second and third changes should resolve situations where motion correction appears to have failed. I suppose Takahashi thought offsets of >15 were simply not worth it, so extra care should be taken around acquisitions where >15 offsets are required.

# Usability improvements

- Easy specification of which files go where.

- Automatically generates .tif with average of all frames processed (totalaverage.tif).

- Automatically generates average of individual trials (trial_avgs.mat)

- Slick but unintrusive live progress report.
