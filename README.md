Tablify
=======

Tablify is simple tablification plugin for VIM. It formats the raw data into nice-looking tables as shown below.

Text for tablification
----------------------

`test|word|another<br />
orbituary|so|masterpiece<br />
cat|slave|grave`

After selecting these lines you can <Leader>tt to fast-tablify data, <Leader>tc to tablify data with center alignment and <Leader>tr for right align

Tablification results
---------------------

### Without inner rows (left, center, right align)
`+---------+-----+-----------+			+---------+-----+-----------+			+---------+-----+-----------+`
`|test     |word |another    |			|  test   |word |  another  |			|     test| word|    another|`
`|orbituary|so   |masterpiece|			|orbituary| so  |masterpiece|			|orbituary|   so|masterpiece|`
`|cat      |slave|grave      |			|   cat   |slave|   grave   |			|      cat|slave|      grave|`
`+---------+-----+-----------+			+---------+-----+-----------+			+---------+-----+-----------+`

### With inner rows (left, center, right align)
`+---------+-----+-----------+			+---------+-----+-----------+			+---------+-----+-----------+`
`|test     |word |another    |			|  test   |word |  another  |			|     test| word|    another|`
`+---------+-----+-----------+			+---------+-----+-----------+			+---------+-----+-----------+`
`|orbituary|so   |masterpiece|			|orbituary| so  |masterpiece|			|orbituary|   so|masterpiece|`
`+---------+-----+-----------+			+---------+-----+-----------+			+---------+-----+-----------+`
`|cat      |slave|grave      |			|   cat   |slave|   grave   |			|      cat|slave|      grave|`
`+---------+-----+-----------+			+---------+-----+-----------+			+---------+-----+-----------+`

### With inner rows and cell padding (left, center, right align)
`+-----------+-------+-------------+		+-----------+-------+-------------+		+-----------+-------+-------------+`
`| test      | word  | another     |		|   test    | word  |   another   |		|      test |  word |     another |`
`+-----------+-------+-------------+		+-----------+-------+-------------+		+-----------+-------+-------------+`
`| orbituary | so    | masterpiece |		| orbituary |  so   | masterpiece |		| orbituary |    so | masterpiece |`
`+-----------+-------+-------------+		+-----------+-------+-------------+		+-----------+-------+-------------+`
`| cat       | slave | grave       |		|    cat    | slave |    grave    |		|       cat | slave |       grave |`
`+-----------+-------+-------------+		+-----------+-------+-------------+		+-----------+-------+-------------+`
