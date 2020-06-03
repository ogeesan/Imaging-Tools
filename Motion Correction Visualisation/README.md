Naoya Takashi's code for motion correction (and my version) output mclog.mat, a record of offsets applied to each frame. `mclogplot()` visualises these offsets by mapping the x-y offset of each frame onto a two-dimensional colourmap. It's like using x-y coordinates to select a value on the colourwheel.

# How to use

1. `mclogplot(mclog)` will work for most people
2. `mclogplot(mclog,true)` will return the plot object itself
3. `[~, shifts] = mclogplot(mclogplot)` where `shifts` is the image matrix itself

# More information

If you want to see what the colour map looks like:

```matlab
image(calc_cmap_2d(15))
axis square % make the image square
```

The centre the image (a pure white pixel) is coordinate (0, 0), and the amount of offset applied to a frame is used to define which pixel (i.e. colour) will represent that frame.

### How to interpret the plot

![](https://gfycat.com/CreativeUnlawfulDipper-small.gif)

The plot allows for qualitative comparison of the x-y offsets of frames. x-axis is frame number, y-axis is trial number.

When there is a sudden change in colour, this means that the x-y position of the frame suddenly changed. This may indicate that z-movement has occurred. Examining the motion correction plot with fluorescence data can reveal brain-movement correlated fluorescence changes.
