Naoya Takashi's code for motion correction (and my version) output mclog.mat, a record of offsets applied to each frame. `mclogplot()` visualises these offsets by mapping the x-y offset of each frame onto a two-dimensional colourmap. It's like using x-y coordinates to select a value on the colourwheel.

![Example image](https://github.com/ogeesan/Public-Tools/blob/master/img/mclogplotexample.png?raw=true)

# How to use

`mclogplot(mclog)` will produce an image of the offsets.

There are also some options that can be specified in a structure `options` with use as `mclogplot(mclog, options)`.

- maxmode: 'black' (default) or 'scale'
  
  - black (default): normal 15x15 2D colourspace, with greyscale colourspace extending beyond that if required.
  
  - scale: makes the maximum offset define the colourmap (i.e. will make the differences harder to see)

- maxoffset: integer
  specify the maximum offset, can be used together with scale to define a normal colour space. If nothing is specified, will assume 15 unless there's a larger value.

- meancentre: 'true' or 'false' (default)
  Display offsets relative to the mean offset. It doesn't change anything for me, but it might be useful to you.

- shifts: 'true' or 'false' (default)
  `shifts = mclogplot(mclog,options)` to recover the matrix of the image being used to generate the plot. Useful if you want to extract just one trial's visualisation.

- image: 'true' (default) or 'false'
  Whether or not to produce the figure.

# More information

If you want to see what the colour map looks like:

```matlab
image(calc_cmap_2d(15))
axis square % make the image square
```

The centre the image (a pure white pixel) is coordinate (0, 0), and the amount of offset applied to a frame is used to define which pixel (i.e. colour) will represent that frame.

### How to interpret the plot

The plot allows for qualitative comparison of the x-y offsets of frames. x-axis is frame number, y-axis is trial number. The easiest way to get a feel for it is to watch the included .mp4 file.

When there is a sudden change in colour, this means that the x-y position of the frame suddenly changed. This may indicate that z-movement has occurred. Examining the motion correction plot with fluorescence data can reveal brain-movement correlated fluorescence changes.
