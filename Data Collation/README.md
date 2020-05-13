# George's data collation readme

Hiyo, here's a barebones example of how the collation system works. 

The Master_Sheet spreadsheet records which files belong to which mice and the collation script will find those files (if they exist). In other words, it takes a column of filenames and creates a column containing the files themselves.

#### What should I know to be able to adapt this example to my needs?

You definitely need to know about [indexing into tables](https://au.mathworks.com/help/matlab/matlab_prog/access-data-in-a-table.html). Luckily tables can be indexed into just about any way, so if you're used to doing it one way then tables can probably handle it. 

#### You mentioned something about processing specific folders in your talk?

Yes, but it's too complex for my example. The overall gist is the same: the `directory` is used to find the folder you named, and then the code looks for files in that folder that match some criteria. So instead of having to name 5 files per row, you could just name one folder and then define 5 criteria in the code.

#### What's going on in the `if` statement on lines 16-18?

When we use `load()` on a .mat file that contains a structure, it returns the entire structure including the variable name. If we `load()` the structure directly into the table, then we'd have to access it with `Master.Data{row}.Data`. We want to be able to use `Master.Data{xrow}`, without the extra useless bit of indexing so some extra operations are required.