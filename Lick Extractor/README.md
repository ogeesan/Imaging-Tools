# Usage

This function takes in an `Events` structure and returns vectors of lick times as recorded by Bpod.

`[portins, portouts] = getlicks(SessionData.RawEvents.Trial{trial}.Events)`

Where `trial` is the trial number. `portins` is when the light beam was broken, and the corresponding value in `portouts` is when the light beam was restored.

I didn't make the function return events for all trials because I don't assume how you store your trial-by-trial data. But one way to do it would be like so:

```matlab
nTrials = SessionData.nTrials;
data = cell(nTrials,2);
for trial = 1:nTrials
    [portins, portouts] = getlicks(SessionData.RawEvents.Trial{trial}.Events);
    data{trial,1} = portins;
    data{trial,2} = portouts;
end
```


