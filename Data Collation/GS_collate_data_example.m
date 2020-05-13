%% Get the record of file you want and the location of all available files
Master = readtable('Example_Master_Sheet.xlsx','ReadVariableNames',true); % read the spreadsheet containing all the files you've named

directory = dir('**'); % generates a directory of all folders, sub-folders, and files from the Current Folder
directory = struct2table(directory); % convert the structure into a table (which is easier to work with)

%% Load in data into Master
for row = 1:height(Master)
    filename = Master.datafile{row}; % get the filename that we're looking for    
    
    filerow = strcmp(filename,directory.name); % find the row in the directory for the file named in Master
    
    if sum(filerow) == 1 % if there's a match
        loaded_file = load([directory.folder{filerow} '\' filename]); % temporarily load in the file here
        
        if isstruct(loaded_file) % if the file is a structure we need to unpack it before adding it into the table
            fieldname = fieldnames(loaded_file); % read the name of the structure
            Master.Data{row} = loaded_file.(fieldname{1}); % we index back into the thing we loaded because structures are weird
            
        else % otherwise just chuck the data in
            Master.Data{row} = loaded_file;
        end
        
    elseif sum(filerow) > 1 % more than one true = multiple files with that name
        warning(sprintf('file ''%s'' of row %i has duplicates',filename,row)) % display a warning message if there is a duplicate
    end    
end

% save('GSeg_Master.mat','Master'); % save the finished product for later loading