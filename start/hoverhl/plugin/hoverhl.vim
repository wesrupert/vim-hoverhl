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

if !exists("g:hoverHlStandardMappings")
    let g:hoverHlStandardMappings = 1
endif

" let g:hoverHlCaseSensitive = 1

" let g:hoverHlCustomFg = #XXXXXX
" let g:hoverHlCustomBg = #XXXXXX
let g:hoverHlFgColor = ''
let g:hoverHlBgColor = ''

" Script Variables {{{

let s:matchId = 101248
let s:enabled = 1

" }}}

" }}}

" Public Methods {{{

function! HoverHlEnable() " {{{
    let s:enabled = 1
endfunction " }}}

function! HoverHlDisable() " {{{
    call s:clearHighlightedWord()
    let s:enabled = 0
endfunction " }}}

function! HoverHlToggle() " {{{
    if s:enabled
        call HoverHlDisable()
    else
        call HoverHlEnable()
    endif
endfunction " }}}

function! HoverHlForward() " {{{
    call s:hoverHlNavigate('f')
endfunction " }}}

function! HoverHlBackward() " {{{
    call s:hoverHlNavigate('b')
endfunction " }}}

" }}}

" Private Methods {{{ {{{

function! s:setHoverHlColor() " {{{
    if exists('g:hoverHlCustomBg') && match(g:hoverHlCustomBg, '#[0-9A-Fa-f]\\{6}')
        let g:hoverHlBgColor = g:hoverHlCustomBg
    else
        " Use 'Search' highlight group color
        let g:hoverHlBgColor = printf('%s', synIDattr(hlID('Search'), 'bg#'))
    endif
    if exists('g:hoverHlCustomFg') && (g:hoverHlCustomFg == '' || match(g:hoverHlCustomBg, '#[0-9A-Fa-f]\\{6}'))
        let g:hoverHlFgColor = g:hoverHlCustomFg
    else
        " Color schemes frequently don't define a foreground color, so this can
        " return ''. This implies that the background color won't interfere with
        " any of the other foreground colors, so it's okay for this to be ''.
        let g:hoverHlFgColor = printf('%s', synIDattr(hlID('Search'), 'fg#'))
    endif
    call s:setHighlight()
endfunction " }}}

function! s:hoverHlNavigate(direction) " {{{
    if a:direction != 'f' && a:direction != 'b'
        echom "'" . a:direction . "' is not a valid direction! Use 'f' or 'b'."
        return
    endif

    if exists('b:hoverHlCurrentWord')
        let searchFlag = a:direction
        if a:direction == 'f'
            let searchFlag = ''
        endif
        call search(s:getPatternForWord(b:hoverHlCurrentWord), l:searchFlag)
    else
        if a:direction == 'f'
            silent! normal! n
        else
            silent! normal! N
        endif
    endif
endfunction " }}}

function! s:highlightHoveredWord() " {{{
    if s:enabled == 0
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

    if g:hoverHlFgColor == ''
        execute 'hi! def HoverHlWord ' . ui . 'bg=' . g:hoverHlBgColor
    else
        execute 'hi! def HoverHlWord ' . ui . 'bg=' . g:hoverHlBgColor . ' ' . ui . 'fg=' . g:hoverHlFgColor
    endif

    let s:highlightSet = 1
endfunction " }}}

" }}} }}}

" Plugin bindings {{{

if g:hoverHlStandardMappings && !hasmapto('HoverHl')
    nnoremap <silent> <leader>K :call HoverHlToggle()<cr>
    nnoremap <silent> <leader>n :call HoverHlForward()<cr>
    nnoremap <silent> <leader>N :call HoverHlBackward()<cr>
endif

try
    nnoremap <silent> <unique> <script> <Plug>HoverHlDisable  :call HoverHlDisable()<cr>
    nnoremap <silent> <unique> <script> <Plug>HoverHlEnable   :call HoverHlEnable()<cr>
    nnoremap <silent> <unique> <script> <Plug>HoverHlToggle   :call HoverHlToggle()<cr>
    nnoremap <silent> <unique> <script> <Plug>HoverHlForward  :call HoverHlForward()<cr>
    nnoremap <silent> <unique> <script> <Plug>HoverHlBackward :call HoverHlBackward()<cr>
catch /E227/
endtry

augroup HoverHl
    au ColorScheme * call s:setHoverHlColor()
    au CursorHold  * call s:highlightHoveredWord()
augroup END

" }}}

" vim: foldmethod=marker foldlevel=1
