" Vim tablification plugin - turns data into nice-looking tables
" Last Change:	2012 Dec 18
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

    " use row delimiters
    let b:tablify_noInnerRows = exists('b:tablify_noInnerRows') ? b:tablify_noInnerRows : 0

    " number of spaces for left and right table cell padding
    let b:tablify_cellLeftPadding = exists('b:tablify_cellLeftPadding') ? b:tablify_cellLeftPadding : 1
    let b:tablify_cellRightPadding = exists('b:tablify_cellRightPadding') ? b:tablify_cellRightPadding : 1
endfunction

function! <SID>Tablify(align) range
    if a:firstline == a:lastline
        return
    endif

    let b:align = a:align
    call <SID>Reconfigure()

    let columnWidths = <SID>GetColumnWidths(a:firstline, a:lastline)
    let columnCnt = len(columnWidths)
    if columnCnt == 0
        return
    endif

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

    let prefix = <SID>GetCommonPrefix(a:firstline, a:lastline)
    let delimiterRow = prefix . delimiterRow
    let delimiterHeaderRow = prefix . delimiterHeaderRow

    let i = a:firstline
    let isHeader = 0
    while i <= a:lastline
        let line = getline(i)
        if prefix != ''
            let line = strpart(line, strwidth(prefix))
        endif

        let words = split(line, escape(b:tablify_delimiter, '$^'), 1)
        
        let j = 0

        let wordsCnt = len(words)
        if wordsCnt == 1
            let words = split(line, escape(b:tablify_headerDelimiter, '$^'), 1)
            let wordsCnt = len(words)
            
            if wordsCnt == 1
                continue
            endif

            let isHeader = 1
        endif

        let newLine = b:tablify_vertDelimiter
        while j < wordsCnt
            let word = substitute(words[j], "^\\s\\+\\|\\s\\+$", '', 'g') 
            
            let cell = <SID>MakeCell(word, columnWidths[j])
            let newLine .= cell . b:tablify_vertDelimiter

            let j += 1
        endwhile

        call setline(i, prefix . newLine)

        let i += 1
    endwhile

    let saveCursor = getpos(".")
    if b:tablify_noInnerRows
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

    call <SID>Reconfigure()

    let prefix = <SID>GetCommonPrefix(a:firstline, a:lastline)

    let i = a:firstline
    let isHeader = 0
    let headerLine = 0
    while i <= a:lastline
        let line = getline(i)
        if prefix != ''
            let line = strpart(line, strwidth(prefix))
        endif

        let words = split(line, b:tablify_vertDelimiter)
       
        if line == repeat(b:tablify_horHeaderDelimiter, strwidth(line)) && headerLine == 0
            let isHeader = 1
            let headerLine = i + 1
        endif

        if words[0][0] == b:tablify_divideDelimiter && len(words) == 1
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
            call setline(i, prefix . join(wordsList, b:tablify_headerDelimiter))
            let isHeader = 0
        else
            call setline(i, prefix . join(wordsList, b:tablify_delimiter))
        endif

        let i += 1
    endwhile

    let saveCursor = getpos(".")
    if b:tablify_noInnerRows
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

function! <SID>GetRowMaxLines(words)
    let i = 0
    let wordsCnt = len(a:words)
    
    let maxLines = 1

    while i < wordsCnt
        let word = a:words[i]
        let index = stridx(word, '\n')
        let start = 0

        let matchCnt = 0
        while stridx(word, '\n', start) != -1
            let start = stridx(word, '\n', start) + 2
            let matchCnt += 1
            if matchCnt > maxLines
                let maxLines = matchCnt
            endif
        endwhile
        
        let i += 1
    endwhile

    return maxLines
endfunction

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

            if prefix == ''
                return ''
            endif
        endif

        let linenum += 1
    endwhile

    return prefix
endfunction

function! <SID>GetColumnWidths(fline, lline)
    let linenum = a:fline
    let maxColumnWidth = []

    call <SID>DebugEcho('Counting ' . ((a:lline - a:fline) + 1) . ' lines for tablification')

    while linenum <= a:lline
        let line = getline(linenum)
        let words = split(line, escape(b:tablify_delimiter, '$^'), 1)
        if len(words) == 1
            let words = split(line, escape(b:tablify_headerDelimiter, '$^'), 1)
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
