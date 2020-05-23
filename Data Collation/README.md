Hiyo, here's an example of how the collation system works. The GS_collate_cohort_example.m script contains the basics, but it definitely needs work to be adapted to your own needs. 

In Georges_actual_collation.m you'll find the actual script I use to collate cohort data. If you've got some Matlab background you can probably deciper what's going on, otherwise best steer clear.

# How does it work?

The Master_Sheet.xlsx spreadsheet records which files belong to which mice and the collation script will find those files (if they exist). In other words, it takes a column of filenames and creates a column containing the files themselves. 

What follows a description of how this is done in the two sections, and I highly recommend using the Matlab Help Center's documentation on the relevant functions to understand what they are doing.

## Section 1: Getting the ingredients

First, we need to get the record of what we want. In Example_Master_Sheet.xlsx, there is a column called "datafile" and in that column some filenames are specified. `readtable()` is used to load this spreadsheet into Matlab as `Master`. 

Then, we need to generate a record of all files that are available. To do this we use `dir(**)`, where the '**' is a "wildcard" indicating that `dir` should also search subfolders. The output of `dir` is a structure containing all of the files and their paths, which I've named `directory`. I convert `directory` into a table with `struct2table()` because I'm more used to working with tables. 

And so we have `Master`, a record of what we want, and `directory`, a record of what can be obtained.

### Pathnames, filenames, directories?

- Pathname: the location of the thing e.g. `C:\users\George\Documents\Memes\`. It's like the address of the folder that you need to be in to see the file.

- Filename: the name of the file itself.

- The *current directory* (aka current folder) is where Matlab's file view (the left window) is located.

It's possible to load a file using only its filename if it's visible in the current directory (since Matlab always checks the current directory first). But if the file is somewhere else that isn't in, you don't have to move your current folder there to load it. You can specify the pathname (e.g. `load('D:\USB_Drive\Data\test.mat')`) and Matlab would find the file by following the path.

## Section 2: locating and loading the files

Searching for files involves looping through each row in the spreadsheet, each time extracting the value in the "datafile" column, which is define as `filename`.

Now comes the magic trick: `strcmp(filename, directory.name)`. This is doing a comparison of the string `filename` to all strings in `directory.name`, which is a list of all of the filenames that `dir` returned. In the example there are only a few files, but if you're running `dir(**)` on a large collection this might be thousands of files. What we get is `filerow`, a logical vector (i.e. a list of 1s and 0s) that is 1 whenever the two match.

If there's only one file that has a name that matches `filename`, then that's perfect. We use `filerow` to find the pathname, and then put them together (`[pathname '\' filename]`) to get the full path to the file.

# More information

#### What should I know to be able to adapt this example to my needs?

You definitely need to know about [indexing into tables](https://au.mathworks.com/help/matlab/matlab_prog/access-data-in-a-table.html). Luckily tables can be indexed into just about any way, so if you're used to doing it one way then tables can probably handle it. 

#### What's going on in the `if` statement on lines 16-18?

When we use `load()` on a .mat file that contains a structure, it returns the entire structure including the variable name. If we `load()` the structure directly into the table, then we'd have to access it with `Master.Data{row}.Data`. We want to be able to use `Master.Data{xrow}`, without the extra useless bit of indexing.

#### Why use this system?

Tables are a very useful system in Matlab, and I use them all time for other things. Considering the amount (in terms of storage space) of data that's stored in the table isn't super massive, I figure it's best to collate data into a storage system that I already know how to use.

The limitations of this system are its storage size. The larger the .mat file the longer it takes to load in, and Matlab only handles variables < 2GB. 

#### You've talked about auto-collating from folders...

The collate_cohort_complex_example.m script is the script I use to collate data as-is. To get folder-based collation to work for yourself you'd need the Matlab skill to understand the script anyway. But here's how it works.

1. Define and locate the folder that was named.

2. Find files that meet a set of criteria.

Since all of the files I want are named descriptively (e.g. all of the fluorescence files contain "Facrosstrials.mat" in the filename), the criteria are wholly contained within the filename. It's possible to `load()` in files to see if they meet criteria, but this would take a very long time.

Instead of `strcmp()`, I use `strfind()` which looks for a pattern (`tagname`) in a string. This is because while my files might end in a particular string, there might also be text before that in the filename. For each specified folder name, the script loops through the different `tagname`s that I'm after and checks to see if those exist in the folder that I've specified. There's an `if` statement for the different `tagname`s because depending on what's being acquired a different loading/parsing process might be required.

I know it's a bit wild but if you need help setting it up then I can help with that.