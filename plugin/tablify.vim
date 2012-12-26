" Vim tablification plugin - turns data into nice-looking tables
" Last Change:	2012 Dec 26
" Maintainer:	Vladimir Shvets <stormherz@gmail.com>

" to debug or not to debug (messages, info, etc)
let s:tablify_debug = 0

if exists("g:loaded_tablify") && s:tablify_debug == 0
    finish
endif
let g:loaded_tablify = 1


noremap <script> <silent> <Leader>tt :call <SID>Tablify('left')<CR>
noremap <script> <silent> <Leader>tl :call <SID>Tablify('left')<CR>
noremap <script> <silent> <Leader>tr :call <SID>Tablify('right')<CR>
noremap <script> <silent> <Leader>tc :call <SID>Tablify('center')<CR>

noremap <script> <silent> <Leader>ta :call <SID>Select()<CR>

noremap <script> <silent> <Leader>ts :call <SID>Sort()<CR>

noremap <script> <silent> <Leader>tu :call <SID>Untablify()<CR>

" Outputs debug messages if debug mode is set (g:debug)
function! <SID>DebugEcho(msg)
    if !s:tablify_debug
        return
    endif

    echohl Debug
    echo a:msg
endfunction

" Reassign configuration variables (called before Tablify/Untablify processing)
" Configuration is related to buffer
function! <SID>Reconfigure()
    " delimiters used for tablification/untablification process
    let b:tablify_headerDelimiter = exists('b:tablify_headerDelimiter') ? b:tablify_headerDelimiter : '#'
    let b:tablify_delimiter = exists('b:tablify_delimiter') ? b:tablify_delimiter : '|'

    " filler symmbols for the result table
    let b:tablify_vertDelimiter = exists('b:tablify_vertDelimiter') ? b:tablify_vertDelimiter : '|'
    let b:tablify_horDelimiter = exists('b:tablify_horDelimiter') ? b:tablify_horDelimiter : '-'
    let b:tablify_horHeaderDelimiter = exists('b:tablify_horHeaderDelimiter') ? b:tablify_horHeaderDelimiter : '~'
    let b:tablify_divideDelimiter = exists('b:tablify_divideDelimiter') ? b:tablify_divideDelimiter : '+'

    " number of spaces for left and right table cell padding
    let b:tablify_cellLeftPadding = exists('b:tablify_cellLeftPadding') ? b:tablify_cellLeftPadding : 1
    let b:tablify_cellRightPadding = exists('b:tablify_cellRightPadding') ? b:tablify_cellRightPadding : 1
endfunction

" Main tablification function, turns selected text into table representation
function! <SID>Tablify(align) range
    if a:firstline == a:lastline
        return
    endif

    let b:align = a:align
    call <SID>Reconfigure()

    let tableData = <SID>GetRawData(a:firstline, a:lastline)
    if len(tableData) == 0
        return
    endif

    exec "normal " . a:firstline . 'GV' . (a:lastline - a:firstline) . 'jd'
    call <SID>PrintTable(tableData, a:firstline)
endfunction

" Untablification process, reverts table to plain text
function! <SID>Untablify() range
    if a:firstline == a:lastline
        return
    endif

    call <SID>Reconfigure()

    let prefix = <SID>GetCommonPrefix(a:firstline, a:lastline)
    let tableData = <SID>GetTableData(a:firstline, a:lastline)
    if len(tableData) == 0
        return
    endif

    let lineCnt = (a:lastline - a:firstline) + 1

    exec "normal " . a:firstline . "G" . lineCnt . "dd"
    
    call <SID>PrintData(tableData, a:firstline)

    exec "normal " . a:firstline . "G"
endfunction

" Creates cell content with known alignment, width, and, of course, word
function! <SID>MakeCell(word, width)
    let res = a:word
    let wordLength = strwidth(a:word)
    if a:width > wordLength
        if b:align == 'right'
            let res = repeat(' ', a:width - wordLength) . res
        elseif b:align == 'center'
            let diff = float2nr(floor((a:width - wordLength) / 2.0))
            let res = repeat(' ', diff) . res . repeat(' ', a:width - wordLength - diff)
        else
            let res = res . repeat(' ', a:width - wordLength)
        endif
    endif

    if b:tablify_cellLeftPadding > 0
        let res = repeat(' ', b:tablify_cellLeftPadding) . res
    endif
    if b:tablify_cellRightPadding > 0
        let res = res . repeat(' ', b:tablify_cellRightPadding)
    endif

    return res
endfunction

" Determines common prefix for range in buffer (used for tables within multi-line comments, etc)
function! <SID>GetCommonPrefix(fline, lline)
    if a:fline == a:lline
        return ''
    endif

    let linenum = a:fline + 1
    let firstline = getline(a:fline)
    let prefix = ''

    while linenum <= a:lline
        let line = getline(linenum)

        if strwidth(prefix) != ''
            let index = stridx(line, prefix)
            if index != 0
                return ''
            endif
        else
            let i = 0
            while strwidth(line) > i && strwidth(firstline) > i && line[i] == firstline[i]
                let prefix .= line[i]
                let i += 1
            endwhile

            let prefixLength = len(prefix)
            if prefixLength == 0 || prefix[prefixLength - 1] != ' '
                return ''
            endif
        endif

        let linenum += 1
    endwhile

    return prefix
endfunction

" returns row lines count
function! <SID>GetRowLinesCount(data)
    if len(a:data) == 0
        return
    endif

    let rowLinesCnt = []
    let columnCnt = len(a:data[0])

    let lineIndex = 0
    for line in a:data
        let i = 0
        let wordsCnt = len(line)

        call add(rowLinesCnt, 0)

        while i < wordsCnt
            let word = line[i]

            let index = stridx(word, '\n')
            if index == -1
                let linesCnt = 1
            else
                let linesCnt = 1
                while index != -1
                    let linesCnt += 1
                    let index = stridx(word, '\n', index + 1)
                endwhile
            endif

            if linesCnt > rowLinesCnt[lineIndex]
                let rowLinesCnt[lineIndex] = linesCnt
            endif

            let i += 1
        endwhile

        let lineIndex += 1
    endfor

    return rowLinesCnt
endfunction

" returns max column widths for table data
function! <SID>GetColumnWidths(data, rowLinesCnt)
    if len(a:data) == 0
        return
    endif

    let maxColumnWidth = []
    let columnCnt = len(a:data[0])

    let i = 0
    while i < columnCnt
        call add(maxColumnWidth, 0)

        let i += 1
    endwhile

    let lineIndex = 0
    for line in a:data
        let i = 0
        let wordsCnt = len(line)

        while i < wordsCnt
            if a:rowLinesCnt[lineIndex] > 1
                let parts = split(line[i], '\\n')
                let wordLength = 0
                for part in parts
                    let part = substitute(part, "^\\s\\+\\|\\s\\+$", '', 'g')
                    let partLength = len(part)
                    if partLength > wordLength
                        let wordLength = partLength
                    endif
                endfor
            else
                let wordLength = len(line[i])
            endif

            if wordLength > maxColumnWidth[i]
                let maxColumnWidth[i] = wordLength
            endif

            let i += 1
        endwhile

        let lineIndex += 1
    endfor

    return maxColumnWidth
endfunction

" Sorts table by one of the columns (user input)
function! <SID>Sort() range
    call <SID>Reconfigure()

    call inputsave()
    let column = str2nr(input('Sort column: '))
    call inputrestore()

    let data = <SID>GetTableData(a:firstline, a:lastline)
    if len(data) == 0
        return
    endif

    if column < 1 || column > len(data['data'][0])
        return
    endif

    let columnData = <SID>GetColumn(data['data'], column - 1)
    if len(columnData) == 0
        return
    endif

    let columnDict = {}
    let i = 0

    let numbersMatched = 0

    for columnValue in columnData
        if columnValue =~ '^\d\+$'
            let numbersMatched += 1
        endif

        let columnDict[i] = columnValue
        let i += 1
    endfor
    let allNumbers = (numbersMatched == len(columnData)) ? 1 : 0

    let newData = []

    if allNumbers == 0
        let sortedValues = sort(columnData)
    else
        function! <SID>NumericSort(i1, i2)
            return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
        endfunction
        let sortedValues = sort(columnData, "<SID>NumericSort")
    endif

    for value in sortedValues
        for [i, v] in items(columnDict)
            if value == v
                let from = i
            endif
        endfor

        call add(newData, data['data'][from])
    endfor

    let data['data'] = newData[:]
    let values = newData[:]
    if len(data['header']) > 0
        call insert(values, data['header'], 0)
    endif
    let rowLinesCnt = <SID>GetRowLinesCount(values)
    let data['rowLinesCnt'] = rowLinesCnt

    let linesCnt = a:lastline - a:firstline
    exec "normal " . a:firstline . 'GV' . linesCnt . 'jd'
    call <SID>PrintTable(data, a:firstline)
    
endfunction

" returns column list from table data
function! <SID>GetColumn(data, column)
    let res = []

    let i = 0

    let cnt = len(a:data[0])
    if a:column < 0 || a:column >= cnt
        return 0
    endif

    for words in a:data
        call add(res, words[a:column])
    endfor

    return res
endfunction

" Prints table using collected table data starting at specified line
function! <SID>PrintTable(data, line)
    if len(a:data) == 0
        return
    endif
    
    let columnWidths = a:data['widths']
    let columnCnt = len(a:data['data'][0])

    let i = 0
    let delimiterRow = b:tablify_divideDelimiter
    let columnsWidth = 0
    while i < columnCnt
        if b:tablify_cellLeftPadding > 0
            let spacer = repeat(b:tablify_horDelimiter, b:tablify_cellLeftPadding) 
            let delimiterRow = delimiterRow . spacer
            let columnsWidth += b:tablify_cellLeftPadding
        endif
        if b:tablify_cellRightPadding > 0
            let spacer = repeat(b:tablify_horDelimiter, b:tablify_cellRightPadding) 
            let delimiterRow = delimiterRow . spacer
            let columnsWidth += b:tablify_cellRightPadding
        endif
    
        let delimiterRow .= repeat(b:tablify_horDelimiter, columnWidths[i]) . b:tablify_divideDelimiter
        let columnsWidth += columnWidths[i]
        let i += 1
    endwhile
    let delimiterHeaderRow = repeat(b:tablify_horHeaderDelimiter, len(columnWidths) + 1 + columnsWidth)

    let prefix = a:data['prefix']
    let delimiterRow = prefix . delimiterRow
    let delimiterHeaderRow = prefix . delimiterHeaderRow

    let isHeader = (len(a:data['header']) == 0) ? 0 : 1

    let i = a:line

    let values = a:data['data']
    if isHeader == 1
        call insert(values, a:data['header'], 0)
    endif
    
    let saveCursor = getpos(".")

    let rowLinesCnt = a:data['rowLinesCnt']

    let lineIndex = 0
    for line in values
        let j = 0

        if rowLinesCnt[lineIndex] == 1
            let newLine = b:tablify_vertDelimiter

            for word in line
                let cell = <SID>MakeCell(word, columnWidths[j])
                let newLine .= cell . b:tablify_vertDelimiter

                let j += 1
            endfor

            call append(i - 1, prefix . newLine)
            let i += 1
        else
            let lines = []
            let k = 0
            while k < rowLinesCnt[lineIndex]
                let lst = []
                for rlc in columnWidths
                    let length = rlc + b:tablify_cellLeftPadding + b:tablify_cellRightPadding
                    call add(lst, repeat(' ', length))
                endfor

                call add(lines, lst)
                let k += 1
            endwhile

            let k = 0
            for word in line
                let parts = split(word, '\\n', 1)

                let newLine = b:tablify_vertDelimiter
                if len(parts) > 1
                    let n = 0
                    for part in parts
                        let trimmedPart = substitute(part, "^\\s\\+\\|\\s\\+$", '', 'g')

                        let cell = <SID>MakeCell(trimmedPart, columnWidths[j])
                        let lines[n][k] = cell

                        let n += 1
                    endfor
                else
                    let cell = <SID>MakeCell(word, columnWidths[j])
                    let lines[0][k] = cell
                endif

                let j += 1
                let k += 1
            endfor

            for addLine in lines
                let newLine = join(addLine, b:tablify_vertDelimiter)
                let newLine = b:tablify_vertDelimiter . newLine . b:tablify_vertDelimiter

                call append(i - 1, prefix . newLine)
                let i += 1
            endfor
        endif

        if isHeader == 1 && lineIndex == 0
            call append(i - 1, delimiterHeaderRow)
        else
            call append(i - 1, delimiterRow)
        endif

        let i += 1
        let lineIndex += 1
    endfor

    let lastline = i - 1

    if isHeader == 1
        call append(a:line - 1, delimiterHeaderRow)
    else
        call append(a:line - 1, delimiterRow)
    endif
    call setpos('.', saveCursor)

endfunction

" Prints data structure as raw text on specified line
function! <SID>PrintData(data, line)
    let header = a:data['header']
    let isHeader = (len(header) > 0) ? 1 : 0
    let values = a:data['data']

    let prefix = a:data['prefix']

    if len(values) == 0
        return
    endif

    let dataLines = values
    if isHeader == 1
        call insert(dataLines, header, 0)
    endif

    let line = a:line - 1

    let i = 0
    for values in dataLines
        let list = []
        for value in values
            call add(list, value)
        endfor

        let unificator = ' ' . b:tablify_delimiter . ' '
        if isHeader == 1 && i == 0
            let unificator = ' ' . b:tablify_headerDelimiter . ' '
        endif

        let newLine = prefix . join(list, unificator)
        call append(line, newLine)

        let line += 1
        let i += 1
    endfor
endfunction

" Gathers data from plain text
function! <SID>GetRawData(fline, lline)
    let linenum = a:fline

    let header = []
    let values = []
    let prefix = <SID>GetCommonPrefix(a:fline, a:lline)
    let prefixLength = len(prefix)

    let prevCnt = 0
    while linenum <= a:lline
        let line = getline(linenum)
        if line == ''
            return {}      
        endif

        let isHeader = 0
        
        let words = split(line, escape(b:tablify_delimiter, '$^'), 1)
        
        let wordsCnt = len(words)
        if wordsCnt == 1
            let words = split(line, escape(b:tablify_headerDelimiter, '$^'), 1)
            let wordsCnt = len(words)
            if wordsCnt > 1
                let isHeader = 1
            endif
        endif

        if linenum == a:fline
            let prevCnt = wordsCnt
        elseif prevCnt != wordsCnt
            return {}
        endif

        let i = 0
        let trimmedWords = []
        while i < wordsCnt
            let word = words[i]

            if i == 0 && prefixLength > 0
                let word = strpart(word, prefixLength)
            endif

            let trimmedWord = substitute(word, "^\\s\\+\\|\\s\\+$", '', 'g')
            call add(trimmedWords, trimmedWord)

            let i += 1
        endwhile

        if isHeader == 1
            let header = trimmedWords
        else
            call add(values, trimmedWords)
        endif
        
        let linenum += 1
    endwhile

    let tableData = values[:]
    if len(header) > 0
        call insert(tableData, header, 0)
    endif
    let rowLinesCnt = <SID>GetRowLinesCount(tableData)
    let maxColumnWidths = <SID>GetColumnWidths(tableData, rowLinesCnt)

    return {
        \'rowLinesCnt': rowLinesCnt,
        \'prefix': prefix,
        \'widths': maxColumnWidths,
        \'header': header,
        \'data': values}
endfunction

" Gathers data from existing table
function! <SID>GetTableData(fline, lline)
    let linenum = a:fline
    let header = []
    let dataLines = []

    let prefix = <SID>GetCommonPrefix(a:fline, a:lline)
    let prefixLength = len(prefix)

    let nextHeader = 0
    let validLines = 0
    let mergedLine = []
    let rowLinesCnt = []
    let currentRowCount = 1

    while linenum <= a:lline
        let line = getline(linenum)

        if line == ''
            return {}
        endif

        if prefixLength > 0
            let line = strpart(line, prefixLength)
        endif

        let lineLength = len(line)
        let isHeader = (line[0] == b:tablify_horHeaderDelimiter && line[lineLength - 1] == b:tablify_horHeaderDelimiter) ? 1 : 0
        let isInnerRow = (line[0] == b:tablify_divideDelimiter && line[lineLength - 1] == b:tablify_divideDelimiter) ||
            \(isHeader == 1) ? 1 : 0

        if isHeader == 1
            let nextHeader = 1
        endif

        if isInnerRow == 1
            let validLines += 1
            let linenum += 1

            if len(mergedLine) != 0
                if isHeader == 1
                    let header = mergedLine
                else
                    call add(dataLines, mergedLine)
                endif
                call add(rowLinesCnt, currentRowCount)
            endif

            let mergedLine = []
            let currentRowCount = 1
            continue
        endif

        let data = split(line, b:tablify_vertDelimiter)
        let cnt = len(data)

        let n = 0
        if len(mergedLine) == 0
            while n < cnt
                call insert(mergedLine, '', n)
                let n += 1
            endwhile
        endif

        let j = 0
        while j < cnt
            let data[j] = substitute(data[j], "^\\s\\+\\|\\s\\+$", '', 'g')
            if mergedLine[j] != '' && data[j] != ''
                let mergedLine[j] .= '\n'
                let currentRowCount += 1
            endif
            let mergedLine[j] .= data[j]
            let j += 1
        endwhile

        let linenum += 1
    endwhile

    let values = dataLines[:]
    if len(header) > 0
        call insert(values, header, 0)
    endif

    if validLines == 0
        return {}
    endif

    let maxColumnWidths = <SID>GetColumnWidths(values, rowLinesCnt)

    let res = {
        \'rowLinesCnt': rowLinesCnt,
        \'prefix': prefix,
        \'widths': maxColumnWidths,
        \'header': header,
        \'data': dataLines}
    return res
endfunction

" returns 1 if line is in row format
function! <SID>isTableRow(line)
    if a:line == ''
        return 0
    endif

    let lineLength = len(a:line)

    if a:line[0] == b:tablify_divideDelimiter && a:line[lineLength - 1] == b:tablify_divideDelimiter
        return 1
    endif

    if a:line[0] == b:tablify_horHeaderDelimiter && a:line[lineLength - 1] == b:tablify_horHeaderDelimiter
        return 1
    endif

    let elements = split(a:line, escape(b:tablify_vertDelimiter, '$^'), 1)
    if len(elements) > 1
        return 1
    endif
    
    let elements = split(a:line, escape(b:tablify_headerDelimiter, '$^'), 1)
    if len(elements) > 1
        return 1
    endif

    return 0
endfunction

" Selects the table if the cursor is in it
function! <SID>Select()
    call <SID>Reconfigure()

    let firstline = 0
    let lastline = 0

    let storedLine = line('.')

    let linenum = storedLine
    let line = getline(linenum)

    if <SID>isTableRow(line) == 0
        return
    endif

    while <SID>isTableRow(line) == 1
        let linenum -= 1
        let line = getline(linenum)
    endwhile
    
    let firstline = linenum + 1

    let linenum = storedLine
    let line = getline(linenum)
    while <SID>isTableRow(line) == 1
        let linenum += 1
        let line = getline(linenum)
    endwhile
    let lastline = linenum + 1

    let linesCnt = (lastline - firstline) - 2

    exec "normal " . firstline . "GV" . linesCnt . "j"
endfunction

