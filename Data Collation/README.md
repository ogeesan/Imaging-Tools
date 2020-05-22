Hiyo, here's an example of how the collation system works. The GS_collate_cohort_example.m script contains the basics, but it definitely needs work to be adapted to your own needs.

#### How does it work?

The Master_Sheet.xlsx spreadsheet records which files belong to which mice and the collation script will find those files (if they exist). In other words, it takes a column of filenames and creates a column containing the files themselves. The magic function is `dir(**)`, which outputs the full directory of everything from your current directory. Then, the code moves through the spreadsheet row by row and if a filename was specified it checks for that file in the directory.

#### What should I know to be able to adapt this example to my needs?

You definitely need to know about [indexing into tables](https://au.mathworks.com/help/matlab/matlab_prog/access-data-in-a-table.html). Luckily tables can be indexed into just about any way, so if you're used to doing it one way then tables can probably handle it. 

#### What's going on in the `if` statement on lines 16-18?

When we use `load()` on a .mat file that contains a structure, it returns the entire structure including the variable name. If we `load()` the structure directly into the table, then we'd have to access it with `Master.Data{row}.Data`. We want to be able to use `Master.Data{xrow}`, without the extra useless bit of indexing. 

#### Why use this system?

Tables are a very useful system in Matlab, and I use them all time for other things. Considering the amount (in terms of storage space) of data that's stored in the table isn't super massive, I figure it's best to collate data into a storage system that I already know how to use.

The limitations of this system are its storage size. The larger the .mat file the longer it takes to load in, and Matlab only handles variables < 2GB. 

#### You've talked about auto-collating from folders...

The collate_cohort_complex_example.m script is the script I use to collate data as-is.  To make it work (and maybe to understand it) you definitely need some Matlab skill. The overall gist is the same - define a name to look for and then locate it within the directory. Then, the script searches for files in that folder that meet a set of criteria. The whole process uses a combination of different techniques so that's why it might be hard to decipher.