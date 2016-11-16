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
let s:enabledDefault = 1

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

function! HoverHlForward() " {{{
    call s:hoverHlNavigate('f')
endfunction " }}}

function! HoverHlBackward() " {{{
    call s:hoverHlNavigate('b')
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
        return s:enabledDefault
    endif
    return b:hoverHlEnabled
endfunction " }}}

" }}} }}}

" Plugin bindings {{{

if exists('g:hoverHlEnabledFiletypes')
    augroup HoverHlFiletypes
        let s:enabledDefault = 0
        exe 'au FileType '.join(g:hoverHlEnabledFiletypes, ',').' let b:hoverHlEnabled = 1'
    augroup END
endif

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
