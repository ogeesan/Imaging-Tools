# Usage

`dffmat = calc_dff(roimeans)`. Voila.

# Guide

DFF calculation has two loops - finding a baseline and then `(trace - baseline) ./ baseline`. The second loop is very straight-forward, but finding the baseline depends on your data.

My method, *given the relatively low amount of activity*, is to find the most common fluorescence value for an ROI and define that as its baseline value. The caveat is that if your object spends most of its time in an increased fluorescence state, then that will result in an overestimation of the baseline.


