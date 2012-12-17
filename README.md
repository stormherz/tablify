#Tablify

Tablify is a VIM plugin that turns simple structured data into nice-looking tables.

##Installation
Put `tablify.vim` in your vim's plugin directory and you're ready to go.


##Usage
There is a small list of commands you need to know before starting making tables out of your text. Assuming your `<Leader>` is `\`:  
`\tl` or `\tt` - turns selected lines into table (left-aligned text)  
`\tc` - turns selected lines into table (centered text)  
`\tr` - turns selected lines into table (right-aligned text)  
`\tu` - convert selected table back into raw text format in case you want to add some changes in it

Every line of your future table is a text line with cells, separated by `|` symbol (or any other symbol you choose for `g:tablify_raw_delimiter` variable in your `.vimrc` file).

Let's assume we have a few lines of text we would like to see as table:  

    Artist | Song | Album | Year
    Tool | Useful idiot | Ænima | 1996
    Pantera | Cemetery Gates | Cowboys from Hell | 1990
    Ozzy Osbourne | Let Me Hear You Scream | Scream | 2010

Now select these lines and press `\tt` to make a table:

    +---------------+------------------------+-------------------+------+
    | Artist        | Song                   | Album             | Year |
    +---------------+------------------------+-------------------+------+
    | Tool          | Useful idiot           | Ænima             | 1996 |
    +---------------+------------------------+-------------------+------+
    | Pantera       | Cemetery Gates         | Cowboys from Hell | 1990 |
    +---------------+------------------------+-------------------+------+
    | Ozzy Osbourne | Let Me Hear You Scream | Scream            | 2010 |
    +---------------+------------------------+-------------------+------+

I bet it was pretty simple. Now you can press `u` to undo making of table or select table and press `\tu` to return to the text you're started from. After that you can try `\tc` and `\tr` to see what it looks like to have aligned text in table.

It is obvious that our table here have some kind of header and it will be great to visually distinguish it from table data. To do so, just separate the header cells with `#` symbol (or any other symbol you choose for `g:tablify_header_delimiter` variable in your `.vimrc` file):  

    Artist # Song # Album # Year
    Tool | Useful idiot | Ænima | 1996
    Pantera | Cemetery Gates | Cowboys from Hell | 1990
    Ozzy Osbourne | Let Me Hear You Scream | Scream | 2010


And that's what we get after tablification:

    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    | Artist        | Song                   | Album             | Year |
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    | Tool          | Useful idiot           | Ænima             | 1996 |
    +---------------+------------------------+-------------------+------+
    | Pantera       | Cemetery Gates         | Cowboys from Hell | 1990 |
    +---------------+------------------------+-------------------+------+
    | Ozzy Osbourne | Let Me Hear You Scream | Scream            | 2010 |
    +---------------+------------------------+-------------------+------+


## Configuration
You can configure the behaviour of tablify with global variables:  
`g:loaded_tablify` - set to `1` to disable loading of the plugin  
`g:tablify_header_delimiter` - default value is `#`, symbol that will be used for header cells separation  
`g:tablify_raw_delimiter` - default value is `|`, symbol that will be used for header cells separation  
`g:tablify_vertical_delimiter` - default value is `|`, vertical delimiter symbol for filling up table rows  
`g:tablify_horizontal_delimiter` - default value is `-`, horizontal delimiter symbol for filling up table rows  
`g:tablify_horizontal_header_delimiter` - default value is `~`, horizontal delimiter symbol for filling up tabls header rows  
`g:tablify_no_inner_rows` - default value is 0, you can set value to 1 to disable inner delimiter rows  
`g:tablify_left_padding` - default value is 1, number of spaces used for left cell padding  
`g:tablify_right_padding` - default value is 1, number of spaces used for right cell padding
