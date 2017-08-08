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

let g:hoverhl#enabled_default   = 1
let g:hoverhl#standard_mappings = get(g:, 'hoverhl#standard_mappings', 1)
let g:hoverhl#match_group       = get(g:, 'hoverhl#match_group', 'CursorLine')

" Unset: g:hoverhl#case_sensitive {Values: 0,1}
" Unset: g:hoverhl#clear_on_leave {Values: 0,1}
" Unset: g:hoverhl#custom_fg      {Format: #XXXXXX}
" Unset: g:hoverhl#custom_bg      {Format: #XXXXXX}

" Script Variables {{{

let s:match_id = 607261
let s:fg_color = ''
let s:bg_color = ''

" }}}

" }}}

" Public Methods {{{

function! HoverHlEnable() " {{{
    let b:hoverhl_enabled = 1
    echom '[hoverhl enabled]'
endfunction " }}}

function! HoverHlDisable() " {{{
    call s:ClearHighlightedWord()
    let b:hoverhl_enabled = 0
    echom '[hoverhl disabled]'
endfunction " }}}

function! HoverHlToggle() " {{{
    if s:IsEnabled()
        call HoverHlDisable()
    else
        call HoverHlEnable()
    endif
endfunction " }}}

function! HoverHlForward(count) " {{{
    call s:Navigate('', a:count)
endfunction " }}}

function! HoverHlBackward(count) " {{{
    call s:Navigate('b', a:count)
endfunction " }}}

" }}}

" Private Methods {{{ {{{

function! s:SetColor() " {{{
    if exists('g:hoverhl#custom_bg') && (g:hoverhl#custom_bg == '' || match(g:hoverhl#custom_bg, '#[0-9A-Fa-f]\\{6}'))
        let s:bg_color = g:hoverhl#custom_bg
    else
        let s:bg_color = printf('%s', synIDattr(hlID(g:hoverhl#match_group), 'bg#'))
    endif
    if exists('g:hoverhl#custom_fg') && (g:hoverhl#custom_fg == '' || match(g:hoverhl#custom_bg, '#[0-9A-Fa-f]\\{6}'))
        let s:fg_color = g:hoverhl#custom_fg
    else
        let s:fg_color = printf('%s', synIDattr(hlID(g:hoverhl#match_group), 'fg#'))
    endif
    call s:SetHighlight()
endfunction " }}}

function! s:Navigate(direction, count) " {{{
    if a:direction != '' && a:direction != 'b'
        echom "'".a:direction."' is not a valid direction! Use '' or 'b'."
        return
    endif

    if exists('b:hoverhl_current_word')
        for i in range(1, a:count)
            call search(s:GetPatternForWord(b:hoverhl_current_word), a:direction)
        endfor
    else
        try
            if a:direction == ''
                execute 'normal '.a:count.'n'
            else
                execute 'normal '.a:count.'N'
            endif
        catch /E486/
            " Strip callstack from the search error message
            echohl ErrorMsg | echom matchstr(v:exception, '.486.*$') | echohl None
        endtry

    endif
endfunction " }}}

function! s:HighlightHoveredWord() " {{{
    if !s:IsEnabled()
        return
    endif
    call s:EnsureSetHighlight()

    " Only highlight when on a valid word character
    let currentWord = expand('<cword>') . ''
    if !len(currentWord) || matchstr(getline('.'), '\%'.col('.').'c.') !~? '\w'
        call s:ClearHighlightedWord()
        return
    endif

    if exists('w:hoverhl_match_defined')
        call s:ClearHighlightedWord()
    endif

    call matchadd('HoverHlWord', s:GetPatternForWord(currentWord), 1, s:match_id)
    let w:hoverhl_match_defined = 1
    let b:hoverhl_current_word = currentWord
endfunction " }}}

function! s:ClearHighlightedWord() " {{{
    silent! call matchdelete(s:match_id)
    silent! unlet b:hoverhl_current_word
    silent! unlet w:hoverhl_match_defined
endfunction " }}}

function! s:GetPatternForWord(word) " {{{
    let ignoreCase = 0
    if exists('g:hoverhl#case_sensitive')
        let ignoreCase = !g:hoverhl#case_sensitive
    else
        let ignoreCase = &ignorecase && (!&smartcase || (match(a:word, '\u') == -1))
    endif

    if ignoreCase
        let currentWord = tolower(a:word)
        let case = '\C'
    else
        let currentWord = a:word
        let case = '\c'
    endif

    return case . '\V\<' . escape(currentWord, '\') . '\>'
endfunction " }}}

function! s:EnsureSetHighlight() " {{{
    if !exists('s:highlight_set')
        call s:SetColor()
        call s:SetHighlight()
    endif
endfunction " }}}

function! s:SetHighlight() " {{{
    let ui = has('nvim') || has('gui') || has('gui_running') ? 'gui' : 'cterm'

    let fg = s:fg_color != '' ? ' '.ui.'fg='.s:fg_color : ''
    let bg = s:bg_color != '' ? ' '.ui.'bg='.s:bg_color : ''
    if (bg == '' && fg == '')
        let bg = ' '.ui.'bg=#000000'
        let fg = ' '.ui.'fg=#ffffff'
    endif

    execute 'hi! def HoverHlWord'.fg.bg
    let s:highlight_set = 1
endfunction " }}}


function! s:OnBufLeave() " {{{
    if get(g:, 'hoverhl#clear_on_leave', 0)
        call s:ClearHighlightedWord()
    endif
endfunction " }}}

function s:IsEnabled() " {{{
    if !exists('b:hoverhl_enabled')
        return g:hoverhl#enabled_default
    endif
    return b:hoverhl_enabled
endfunction " }}}

" }}} }}}

" Plugin bindings {{{

if exists('g:hoverhl#enabled_filetypes')
    let g:hoverhl#enabled_default = 0
    augroup HoverHlFiletypes
        execute 'autocmd FileType '.join(g:hoverhl#enabled_filetypes, ',').' let b:hoverhl_enabled = 1'
    augroup END
endif

command! -nargs=0 HoverHlToggle   call HoverHlToggle()
command! -nargs=0 HoverHlEnable   call HoverHlEnable()
command! -nargs=0 HoverHlDisable  call HoverHlDisable()
command! -nargs=1 HoverHlForward  call HoverHlForward(<args>)
command! -nargs=1 HoverHlBackward call HoverHlBackward(<args>)

if g:hoverhl#standard_mappings
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
    autocmd ColorScheme * call s:SetColor()
    autocmd CursorHold  * call s:HighlightHoveredWord()
    autocmd BufLeave    * call s:OnBufLeave()
augroup END

" }}}

" vim: foldmethod=marker foldlevel=1
