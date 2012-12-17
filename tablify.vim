" Vim tablification plugin - turns data into nice-looking tables
" Last Change:	2012 Dec 16
" Maintainer:	Vladimir Shvets <stormherz@gmail.com>

" to debug or not to debug (messages, info, etc)
let s:debug = 0

if exists("g:loaded_tablify") && s:debug == 0
    finish
endif
let g:loaded_tablify = 1

" delimiter used for tablification/untablification process
let s:headerDelimiter = '#'
let s:delimiter = '|'
if exists("g:tablify_header_delimiter")
    let s:headerDelimiter = g:tablify_header_delimiter
endif
if exists("g:tablify_raw_delimiter")
    let s:delimiter = g:tablify_raw_delimiter
endif

" fillers for the result table
let s:vertDelimiter = '|'
let s:horDelimiter = '-'
let s:horHeaderDelimiter = '~'
let s:divideDelimiter = '+'
if exists("g:tablify_vertical_delimiter")
    let s:vertDelimiter = g:tablify_vertical_delimiter
endif
if exists("g:tablify_horizontal_delimiter")
    let s:horDelimiter = g:tablify_horizontal_delimiter
endif
if exists("g:tablify_horizontal_header_delimiter")
    let s:horHeaderDelimiter = g:tablify_horizontal_header_delimiter
endif
if exists("g:tablify_division_delimiter")
    let s:divideDelimiter = g:tablify_division_delimiter
endif

" use row delimiters
let s:noInnerRows = 0
if exists("g:tablify_no_inner_rows")
    let s:noInnerRows = g:tablify_no_inner_rows
endif

" space paddings for table cell content
let s:cellLeftPadding = 1
let s:cellRightPadding = 1
if exists("g:tablify_left_padding")
    let s:cellLeftPadding = g:tablify_left_padding
endif
if exists("g:tablify_right_padding")
    let s:cellRightPadding = g:tablify_right_padding
endif

" alignment
let s:align = 'left'
if exists("g:tablify_align")
    let s:align = g:tablify_align
endif

noremap <script> <silent> <Leader>tt :call <SID>Tablify('left')<CR>
noremap <script> <silent> <Leader>tl :call <SID>Tablify('left')<CR>
noremap <script> <silent> <Leader>tr :call <SID>Tablify('right')<CR>
noremap <script> <silent> <Leader>tc :call <SID>Tablify('center')<CR>

noremap <script> <silent> <Leader>tu :call <SID>Untablify()<CR>

" Outputs debug messages if debug mode is set (g:debug)
function! <SID>DebugEcho(msg)
    if !s:debug
        return
    endif

    echohl Debug
    echo a:msg
endfunction

function! <SID>Tablify(align) range
    let s:align = a:align

    if a:firstline == a:lastline
        return
    endif

    let columnWidths = <SID>GetColumnWidths(a:firstline, a:lastline)
    let columnCnt = len(columnWidths)
    if columnCnt == 0
        return
    endif

    let i = 0
    let delimiterRow = s:divideDelimiter
    let columnsWidth = 0
    while i < columnCnt
        if s:cellLeftPadding > 0
            let spacer = repeat(s:horDelimiter, s:cellLeftPadding) 
            let delimiterRow = delimiterRow . spacer
            let columnsWidth += s:cellLeftPadding
        endif
        if s:cellRightPadding > 0
            let spacer = repeat(s:horDelimiter, s:cellRightPadding) 
            let delimiterRow = delimiterRow . spacer
            let columnsWidth += s:cellRightPadding
        endif
    
        let delimiterRow .= repeat(s:horDelimiter, columnWidths[i]) . s:divideDelimiter
        let columnsWidth += columnWidths[i]
        let i += 1    
    endwhile
    let delimiterHeaderRow = repeat(s:horHeaderDelimiter, len(columnWidths) + 1 + columnsWidth)

    let i = a:firstline
    let isHeader = 0
    while i <= a:lastline
        let line = getline(i)
        let words = split(line, s:delimiter, 1)
        
        let j = 0

        let wordsCnt = len(words)
        if wordsCnt == 1
            let words = split(line, s:headerDelimiter, 1)
            let wordsCnt = len(words)
            
            if wordsCnt == 1
                continue
            endif

            let isHeader = 1
        endif

        let newLine = s:vertDelimiter
        while j < wordsCnt
            let word = substitute(words[j], "^\\s\\+\\|\\s\\+$", '', 'g') 
            
            let cell = <SID>MakeCell(word, columnWidths[j])
            let newLine .= cell . s:vertDelimiter

            let j += 1
        endwhile

        call setline(i, newLine)

        let i += 1
    endwhile

    let saveCursor = getpos(".")
    if s:noInnerRows
        call append(a:firstline - 1, delimiterRow)
        call append(a:lastline + 1, delimiterRow)
    else
        let diff = a:lastline - a:firstline
        let i = diff

        if isHeader == 1
            call append(a:firstline - 1, delimiterHeaderRow)
        else
            call append(a:firstline - 1, delimiterRow)
        endif

        let start = 1
        while i > 0
            if isHeader == 1 && start <= 2
                call append(a:firstline + start, delimiterHeaderRow)
            else
                call append(a:firstline + start, delimiterRow)
            endif

            if start == 3
                let isHeader = 0
            endif

            let i -= 1
            let start += 2
        endwhile

        let gotoLine = a:firstline + ((a:lastline - a:firstline) * 2) + 1
        call append(gotoLine, delimiterRow)
    endif
    call setpos('.', saveCursor)
endfunction

function! <SID>Untablify() range
    if a:firstline == a:lastline
        return
    endif

    let i = a:firstline
    let isHeader = 0
    let headerLine = 0
    while i <= a:lastline
        let line = getline(i)
        let words = split(line, s:vertDelimiter)
       
        if line == repeat(s:horHeaderDelimiter, strwidth(line)) && headerLine == 0
            let isHeader = 1
            let headerLine = i + 1
        endif

        if words[0][0] == s:divideDelimiter && len(words) == 1
            let i += 1
            continue
        endif

        let j = 0
        let wordsCnt = len(words)
        let wordsList = []
        while j < wordsCnt
            let word = substitute(words[j], "^\\s\\+\\|\\s\\+$", '', 'g') 
            call add(wordsList, word)

            let j += 1
        endwhile

        if isHeader == 1 && headerLine == i
            call setline(i, join(wordsList, s:headerDelimiter))
            let isHeader = 0
        else
            call setline(i, join(wordsList, s:delimiter))
        endif

        let i += 1
    endwhile

    let saveCursor = getpos(".")
    if s:noInnerRows
        execute "normal " . a:firstline . "Gdd"
        execute "normal " . (a:lastline - 1) . "Gdd"
    else
        execute "normal " . a:firstline . "G"

        let i = 0
        let lastRow = ((a:lastline - a:firstline) / 2) + 1
        while i < lastRow
            execute "normal dd\<Down>"

            let i += 1
        endwhile
    endif
    call setpos('.', saveCursor)
endfunction

function! <SID>MakeCell(word, width)
    let res = a:word
    let wordLength = strwidth(a:word)
    if a:width > wordLength
        if s:align == 'right'
            let res = repeat(' ', a:width - wordLength) . res
        elseif s:align == 'center'
            let diff = float2nr(floor((a:width - wordLength) / 2.0))
            let res = repeat(' ', diff) . res . repeat(' ', a:width - wordLength - diff)
        else
            let res = res . repeat(' ', a:width - wordLength)
        endif
    endif

    if s:cellLeftPadding > 0
        let res = repeat(' ', s:cellLeftPadding) . res
    endif
    if s:cellRightPadding > 0
        let res = res . repeat(' ', s:cellRightPadding)
    endif

    return res
endfunction

function! <SID>GetColumnWidths(fline, lline)
    let linenum = a:fline
    let maxColumnWidth = []

    call <SID>DebugEcho('Counting ' . ((a:lline - a:fline) + 1) . ' lines for tablification')

    while linenum <= a:lline
        let line = getline(linenum)
        let words = split(line, s:delimiter, 1)
        if len(words) == 1
            let words = split(line, s:headerDelimiter, 1)
        endif

        call <SID>DebugEcho('Line #' . linenum . ': ' . line)

        if linenum == a:fline
            let wordCount = len(words)
        elseif wordCount != len(words)
            return []
        endif

        let lineWords = []
        let j = 0
        while j < wordCount
            let word = substitute(words[j], "^\\s\\+\\|\\s\\+$", '', 'g') 
            let wordLen = strwidth(word)
            if len(maxColumnWidth) < wordCount
                call insert(maxColumnWidth, wordLen, j)
            else
                if maxColumnWidth[j] < wordLen
                    let maxColumnWidth[j] = wordLen
                endif
            endif
            
            let j += 1
        endwhile

        let linenum += 1
    endwhile

    return maxColumnWidth
endfunction
