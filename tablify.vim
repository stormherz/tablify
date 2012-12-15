" Vim tablification plugin - turns data into nice-looking tables
" Last Change:	2012 Dec 14
" Maintainer:	Vladimir Shvets <stormherz@gmail.com>

" to debug or not to debug (messages, info, etc)
let s:debug = 0

if exists("g:loaded_tablify") && s:debug == 0
    finish
endif
let g:loaded_tablify = 1

" delimiter used for tablification/untablification process
let s:delimiter = '|'

" fillers for the result table
let s:vertDelimiter = '|'
let s:horDelimiter = '-'
let s:divideDelimiter = '+'

" use row delimiters
let s:noInnerRows = 0

" space paddings for table cell content
let s:cellLeftPadding = 1
let s:cellRightPadding = 1

" alignment
let s:align = 'left'

noremap <script> <silent> <Leader>tt :call Tablify('left')<CR>
noremap <script> <silent> <Leader>tr :call Tablify('right')<CR>
noremap <script> <silent> <Leader>tc :call Tablify('center')<CR>

if !hasmapto('Untablify')
    noremap <script> <silent> <Leader>tu :call Untablify()<CR>
endif

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

    let columnWidths = GetColumnWidths(a:firstline, a:lastline)
    let columnCnt = len(columnWidths)
    if columnCnt == 0
        return
    endif

    let i = 0
    let delimiterRow = s:divideDelimiter
    while i < columnCnt
        if s:cellLeftPadding > 0
            let spacer = repeat(s:horDelimiter, s:cellLeftPadding) 
            let delimiterRow = delimiterRow . spacer
        endif
        if s:cellRightPadding > 0
            let spacer = repeat(s:horDelimiter, s:cellRightPadding) 
            let delimiterRow = delimiterRow . spacer
        endif
    
        let delimiterRow .= repeat(s:horDelimiter, columnWidths[i]) . s:divideDelimiter
        let i += 1    
    endwhile

    let i = a:firstline
    while i <= a:lastline
        let line = getline(i)
        let words = split(line, s:delimiter)
        
        let j = 0
        let wordsCnt = len(words)
        let newLine = s:vertDelimiter
        while j < wordsCnt
            let word = substitute(words[j], "^\\s\\+\\|\\s\\+$", '', 'g') 
            
            let cell = MakeCell(word, columnWidths[j])
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
        let i = a:lastline - a:firstline
        call append(a:firstline - 1, delimiterRow)

        let start = 1
        while i > 0
            call append(a:firstline + start, delimiterRow)
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
    while i <= a:lastline
        let line = getline(i)
        let words = split(line, s:vertDelimiter)

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

        call setline(i, join(wordsList, s:delimiter))

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
    let wordLength = len(a:word)
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

    call DebugEcho('Counting ' . ((a:lline - a:fline) + 1) . ' lines for tablification')

    while linenum <= a:lline
        let line = getline(linenum)
        let words = split(line, s:delimiter)

        call DebugEcho('Line #' . linenum . ': ' . line)

        if linenum == a:fline
            let wordCount = len(words)
        elseif wordCount != len(words)
            return []
        endif

        let lineWords = []
        let j = 0
        while j < wordCount
            let word = substitute(words[j], "^\\s\\+\\|\\s\\+$", '', 'g') 
            let wordLen = len(word)
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
