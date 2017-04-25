" --------------------------------------------------------------------
" This plugin was inspired and based on Luis Vasconcellos' interesting
" words plugin (https://github.com/lfv89/vim-interestingwords).
"
" Author: Wes Rupert (wesr@outlook.com)
" --------------------------------------------------------------------

if !has('autocmd')
    " No use enabling this plugin when you can't detect cursor hover!
    finish
endif

" Variables {{{

let g:hoverHlEnabledDefault = 1

if !exists("g:hoverHlStandardMappings")
    let g:hoverHlStandardMappings = 1
endif

if !exists("g:hoverHlMatchGroup")
    let g:hoverHlMatchGroup = 'CursorLine'
endif

" let g:hoverHlCaseSensitive = 1

" let g:hoverHlCustomFg = #XXXXXX
" let g:hoverHlCustomBg = #XXXXXX
let g:hoverHlFgColor = ''
let g:hoverHlBgColor = ''

" Script Variables {{{

let s:matchId = 101248

" }}}

" }}}

" Public Methods {{{

function! HoverHlEnable() " {{{
    let b:hoverHlEnabled = 1
endfunction " }}}

function! HoverHlDisable() " {{{
    call s:clearHighlightedWord()
    let b:hoverHlEnabled = 0
endfunction " }}}

function! HoverHlToggle() " {{{
    if s:isEnabled()
        call HoverHlDisable()
    else
        call HoverHlEnable()
    endif
endfunction " }}}

function! HoverHlForward(count) " {{{
    call s:hoverHlNavigate('', a:count)
endfunction " }}}

function! HoverHlBackward(count) " {{{
    call s:hoverHlNavigate('b', a:count)
endfunction " }}}

" }}}

" Private Methods {{{ {{{

function! s:setHoverHlColor() " {{{
    if exists('g:hoverHlCustomBg') && (g:hoverHlCustomBg == '' || match(g:hoverHlCustomBg, '#[0-9A-Fa-f]\\{6}'))
        let g:hoverHlBgColor = g:hoverHlCustomBg
    else
        let g:hoverHlBgColor = printf('%s', synIDattr(hlID(g:hoverHlMatchGroup), 'bg#'))
    endif
    if exists('g:hoverHlCustomFg') && (g:hoverHlCustomFg == '' || match(g:hoverHlCustomBg, '#[0-9A-Fa-f]\\{6}'))
        let g:hoverHlFgColor = g:hoverHlCustomFg
    else
        let g:hoverHlFgColor = printf('%s', synIDattr(hlID(g:hoverHlMatchGroup), 'fg#'))
    endif
    call s:setHighlight()
endfunction " }}}

function! s:hoverHlNavigate(direction, count) " {{{
    if a:direction != '' && a:direction != 'b'
        echom "'" . a:direction . "' is not a valid direction! Use '' or 'b'."
        return
    endif

    if exists('b:hoverHlCurrentWord')
        for i in range(1, a:count)
            call search(s:getPatternForWord(b:hoverHlCurrentWord), a:direction)
        endfor
    else
        if a:direction == ''
            execute 'normal '.a:count.'n'
        else
            execute 'normal '.a:count.'N'
        endif
    endif
endfunction " }}}

function! s:highlightHoveredWord() " {{{
    if !s:isEnabled()
        return
    endif
    call s:ensureSetHighlight()

    let currentWord = expand('<cword>') . ''
    if !len(l:currentWord)
        call s:clearHighlightedWord()
        return
    endif

    if exists('w:hoverHlMatchDefined')
        call s:clearHighlightedWord()
    endif

    call matchadd('HoverHlWord', s:getPatternForWord(l:currentWord), 1, s:matchId)
    let w:hoverHlMatchDefined = 1
    let b:hoverHlCurrentWord = l:currentWord
endfunction " }}}

function! s:clearHighlightedWord() " {{{
    silent! call matchdelete(s:matchId)
    silent! unlet b:hoverHlCurrentWord
    silent! unlet w:hoverHlMatchDefined
endfunction " }}}

function! s:getPatternForWord(word) " {{{
    let ignoreCase = 0
    if exists('g:hoverHlCaseSensitive')
        let ignoreCase = !g:hoverHlCaseSensitive
    else
        let ignoreCase = &ignorecase && (!&smartcase || (match(a:word, '\u') == -1))
    endif

    if l:ignoreCase
        let currentWord = tolower(a:word)
        let case = '\C'
    else
        let currentWord = a:word
        let case = '\c'
    endif

    return l:case . '\V\<' . escape(l:currentWord, '\') . '\>'
endfunction " }}}

function! s:ensureSetHighlight() " {{{
    if !exists('s:highlightSet')
        call s:setHoverHlColor()
        call s:setHighlight()
    endif
endfunction " }}}

function! s:setHighlight() " {{{
    let ui = 'cterm'
    if has('gui_running')
        let ui = 'gui'
    endif

    let fg = ''
    if g:hoverHlFgColor != ''
        let fg = ' ' . ui . 'fg=' . g:hoverHlFgColor
    endif

    let bg = ''
    if g:hoverHlBgColor != ''
        let bg = ' ' . ui . 'bg=' . g:hoverHlBgColor
    endif

    if (l:bg == '' && l:fg == '')
        let bg = ' ' . ui . 'bg=#000000'
        let fg = ' ' . ui . 'fg=#ffffff'
    endif

    execute 'hi! def HoverHlWord' . l:fg . l:bg
    let s:highlightSet = 1
endfunction " }}}

function s:isEnabled() " {{{
    if !exists('b:hoverHlEnabled')
        return g:hoverHlEnabledDefault
    endif
    return b:hoverHlEnabled
endfunction " }}}

" }}} }}}

" Plugin bindings {{{

if exists('g:hoverHlEnabledFiletypes')
    let g:hoverHlEnabledDefault = 0
    augroup HoverHlFiletypes
        execute 'au FileType '.join(g:hoverHlEnabledFiletypes, ',').' let b:hoverHlEnabled = 1'
    augroup END
endif

command! -nargs=0 HoverHlToggle   call HoverHlToggle()
command! -nargs=0 HoverHlEnable   call HoverHlEnable()
command! -nargs=0 HoverHlDisable  call HoverHlDisable()
command! -nargs=1 HoverHlForward  call HoverHlForward(<args>)
command! -nargs=1 HoverHlBackward call HoverHlBackward(<args>)

if g:hoverHlStandardMappings
    if !hasmapto('HoverHlToggle')
        nnoremap <silent> <leader>// :call HoverHlToggle()<cr>
    endif
    if !hasmapto('HoverHlEnable')
        nnoremap <silent> <leader>/e :call HoverHlEnable()<cr>
    endif
    if !hasmapto('HoverHlDisable')
        nnoremap <silent> <leader>/d :call HoverHlDisable()<cr>
    endif
    if !hasmapto('HoverHlForward')
        nnoremap <silent> <leader>n :<c-u>HoverHlForward(v:count1)<cr>
    endif
    if !hasmapto('HoverHlBackward')
        nnoremap <silent> <leader>N :<c-u>HoverHlBackward(v:count1)<cr>
    endif
endif

try
    nnoremap <unique> <script> <Plug>HoverHlToggle   :HoverHlToggle()<cr>
    nnoremap <unique> <script> <Plug>HoverHlEnable   :HoverHlEnable()<cr>
    nnoremap <unique> <script> <Plug>HoverHlDisable  :HoverHlDisable()<cr>
    nnoremap <unique> <script> <Plug>HoverHlForward  :<c-u>HoverHlForward(v:count1)<cr>
    nnoremap <unique> <script> <Plug>HoverHlBackward :<c-u>HoverHlBackward(v:count1)<cr>
catch /E227/
endtry

augroup HoverHl
    au ColorScheme * call s:setHoverHlColor()
    au CursorHold  * call s:highlightHoveredWord()
augroup END

" }}}

" vim: foldmethod=marker foldlevel=1
