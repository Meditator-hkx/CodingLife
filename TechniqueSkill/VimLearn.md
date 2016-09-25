# Vim-Operation-Basics

*2016.9.23 Friday*

## Round 1

1. < h   > l   ^ k   v j ----- move left, right, up and down
2. <ESC> returns to normal mode
3. `:q!` represents *exit forcely*
4. `wq` represents quit after saving a file
5. `vimtutor` leads to the guide of vim
6. `x` means delete a character after cursor
7. `i` means insert a word after cursor

## Round 2

1. `dw` means delete until the end of the word after cursor
2. `d$` means delete until the end of line after cursor
3. `[number] d object` means delete *number* times of an object (w, e, $)
4. `de` means delete until the end of line, but not including spaces
5. `dd` means delete the whole line in which the cursor lies
6. `u` undo the last command while `U` undo all the commands to a line
7. `CTRL-R` undo the *undo* command before

## Round 3

1. `p` means paste the content
2. `r` means can take place of primary character after cursor
3. `cw` means can take place of the words after cursor while entering inserting mode
4. `[number] c object` means can take place of *number* objects (w, e, $)

## Round 4

1. `CTRL-g` shows the line information you stay 
2. `SHIFT-G` means jump to the last line of the file
3. Input the line number and then `SHIFT-G` will lead back to that line 
4. Input `/` with a string like `/errror` can look up this specified string in the whole file, press `n` or `SHIFT-N` to specify the next string occuring order
5. `%` defines the maching of '()' or '{}' or '[]'
6. `s/old/new/g` can replace all the *old* by *new* of the cursor line
7. `%s/old/new/g` can replace all the *old* ny *new*

## Round 5
1. `!:` means that you can execute *external command*, for instance `!:ls` and `!:dir`
2. `:w FILENAME` saves a file to a specified file *FILENAME*
3. `:#,# w FILENAME`  saves partial content to file *FILENAME*
4. `:r FILENAME` insert content of file *FILENAME* to current file

## Round 6
1. `o` means insert text at next line of current cursor, you can also try `SHIFT-O`
2. `a` means insert text after cursor, you can also try `SHIFT-A`
3. `SHIFT-R` means replace multiple characters sequentially
4. `/word` will look up the *word* in the file for a match, and `:set ic` means ignore the Captial letter or small letter, `:set hls is` can highlight the *word* to look up

## Round 7
1. `:help` leads to the online help system

## Round 8
1. `:edit ~/.vimrc` can edit the vimrc file
2. `read $VIMRUNTIME/vimrc_example.vim` can import the vimrc case (template)
3. `:wirte` can save the file