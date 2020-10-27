`zstacker()` is a tool that will average together multiple files *across files*.


# What it's for: higher quality z-stacks

A normal method to take a zstack is to take a single multi-average zstack. In other words, to do a single sweep with each slice being an average of frames taken consecutively. This means that a short spurt of mouse movement can make a slice or even sequence of slices dodgy. The better method is to take multiple zstacks that haven't had any averaging done, and then average them together afterwards. This is what this tool is for.

If doing 3D reconstruction, I highly recommend using `zstacker()`.

# Usage
`zstacker()` will average together all .tif/.tiff files in a single folder together.

## Normal usage for 95% of uses

1. Run `zstacker()`

2. Select a folder containing the zstacks

## Troubleshooting usage: if the end result is still blurry

1. Run `zstacker(true)`

2. Select a folder containing zstacks

3. Use the visualisations to find the problem
   
   1. Use the scroller to find the dodgy frames
   
   2. Use a .csv to define which frames to exclude
      1. One column called "file" that contains the number of the file to exclude
      2. One column called "frames" which contains a string of the format `[firstframe]-[lastframe]`. For example, to exclude the first 50 frames, it'd be "1-50". If you want to exclude multiple blocks of frames from a single file, you can just make a new row with another block of frames.
   3. Note: `sliceViewer()` requires MATLAB 2019b or later

