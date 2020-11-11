The event detection system I use for my recordings of dendrites in the auditory cortex.

First, a disclaimer. Although this tool is in a function it isn't used that way in my workflow. This should really be `detect_sparse_dendritic_events()` because that's the specific situation which it's tweaked for. For me, everytime I have a new dataset context I'll tweak the detection to that dataset.

# A verbal explanation of how it works

The detection system has two parts: threshold determination and suprathreshold detection.

## Threshold determination

Each ROI is calculated to have its own threshold for the event detection. I take *all traces* as `data` and define the ROI's threshold as `3 * mad(data,1)`. `mad(data,1)` calculates the median absolute difference of `data`, where the `1` indicates that it is the *median* and not the *mean* absolute difference to be calculated. 

## Suprathreshold detection

Each individual trace goes through the detection process, which simply asks "when is the trace above the ROI's threshold?" The end goal is pairs of values, where the first value is when the trace crosses the threshold on the up (`rise_edges`) and the second is when it crosses the threshold on the down (`fall_edges`).

But before the properties of the events are extracted, there are edge-cases and unusual situations that have to be handled. 

The final loop (`for event...`) gets some basic properties of the event, and then adds that to the list.

# Parameters and methods

## Peak calculation

I have a funny weighted average thing going on for my calcium of the event peak, because z-movement can introduce weird spikes into a trace during an event. Acquisitions with less z-movement may benefit from a simpler peak detection method.

## Edge-cases

There are some odd situations that have to be accounted for, like how the shutter on the MOM is so fast that it cuts off the fluorescence signal before the acquisition ends, or how an event can start before an acquisition so you get an event with no beginning.

I've written in a `prm.edgecase` settings that can have the value of `'conservative'` or `'ambitious'`, which changes how these edge-cases are handled. In most cases it doesn't matter at all, but if the acquisition is short and you're trying to squeeze as much as you can out of it then this may be of use.
