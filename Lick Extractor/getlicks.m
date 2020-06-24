function [portins, portouts] = getlicks(Events)
% [portins, portouts] = getlicks(SessionData.RawEvents.Trial{trial}.Events)
%{
GS 24th June 2020
- Returns times of portins and portouts for a single trial
- Automatically detects which port the lick 'o meter was plugged into so that
  you don't have to
- Accounts for edge cases
- Won't work if more than one lick 'o meter was used
%}

%% Code baby
tf = contains(fields(Events),'Port'); % check to see if a port event exists
if any(tf) % port events won't be recorded if there were none in that trial
    
    eventfields = fields(Events); % get list of recorded events
    
    % -- Get identity of port Event name
    tf = contains(eventfields,'In'); % find index of PortXIn fieldname (number could differ), assuming there's only one port hooked up
    if any(tf)
        portnumber = eventfields{tf};
        portnumber = sscanf(portnumber,'Port%dIn'); % get number for the port
        portins = Events.(eventfields{tf});
        
        portnumber = ['Port' num2str(portnumber) 'Out']; % number of the port used in In
        tf = contains(eventfields,portnumber);
        if sum(tf) == 1
            portouts = Events.(eventfields{tf});
        else
            portouts = [];
        end
    else
        portins = [];
        portouts = [];
    end
    
    
    % -- Handle weird Bpod bug
    % sometimes Bpod Gen2 has some sort of freak out and records a
    % bunch of out events - these data just have to be removed
    if sum(contains(eventfields,'Out')) > 1 % check if there were more than 1 Out type events
        portins(end) = []; % remove the last times as it seems that some sort of bug occurs
        portouts(end) = [];
    end
    
    % -- Handle edge cases (Outs before Ins and Ins before Outs)
    if ~isempty(portins) && ~isempty(portouts) && portouts(1) < portins(1)
        portouts(1) = [];
    end
    
    if ~isempty(portins) && isempty(portouts)
        portouts = portins;
    elseif isempty(portins) && ~isempty(portouts) % if there's only an out, record nothing
        portins = [];
        portouts = [];
    elseif ~isempty(portins) && ~isempty(portouts)
        if portouts(1) < portins(1); portouts(1) = []; end % if there's an out before an in, remove it
        if portins(end) > portouts(end) && numel(portins) > numel(portouts)
            portouts(end+1) = portins(end); end % if there's an in after an out, make the last recorded out at the same time
    end
    
else
    portins = [];
    portouts = [];
end
