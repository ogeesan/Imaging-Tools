This is my updated version of the motion correction script. 

# How to use

1. Run script

2. Select the file that will serve as the template.

3. Select the folder containing the files you want to motion correct.

4. Select the folder you want to save the motion corrected files to.

# More information

The maths behind it is the same as Naoya Takahashi's code, but I've made some updates to other parts of it.

- Easy specification of which files go where.

- Automatically generates .tif with average of all frames processed (totalaverage.tif).

- Automatically generates average of individual trials (trial_avgs.mat)

- Slick but unintrusive live progress report.
