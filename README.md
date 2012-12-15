Tablify
=======

Tablify is simple tablification plugin for VIM. It formats the raw data into nice-looking tables as shown below.

Text for tablification
----------------------

    test|word|another
    orbituary|so|masterpiece
    sad|slave|grave

After selecting these lines you can `<Leader>tt` to fast-tablify data, `<Leader>tc` to tablify data with center alignment and `<Leader>tr` for right align.
If you want to edit raw table data (original text for tablification) you can select the table and press `<Leader>tu` to revert table to raw text.

Tablification results
---------------------

### Without inner rows (left align)
    +---------+-----+-----------+
    |test     |word |another    |
    |orbituary|so   |masterpiece|
    |sad      |slave|grave      |
    +---------+-----+-----------+

### With inner rows (left align)
    +---------+-----+-----------+
    |test     |word |another    |
    +---------+-----+-----------+
    |orbituary|so   |masterpiece|
    +---------+-----+-----------+
    |sad      |slave|grave      |
    +---------+-----+-----------+

### With inner rows and cell padding (left align)
    +-----------+-------+-------------+
    | test      | word  | another     |
    +-----------+-------+-------------+
    | orbituary | so    | masterpiece |
    +-----------+-------+-------------+
    | sad       | slave | grave       |
    +-----------+-------+-------------+
