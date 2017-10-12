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

" Global scope
let g:hoverhl#enabled_default   = get(g:, 'hoverhl#enabled_default', 1)
let g:hoverhl#standard_mappings = get(g:, 'hoverhl#standard_mappings', 1)
" Unset: g:hoverhl#case_sensitive {Values: 0,1}
" Unset: g:hoverhl#clear_on_leave {Values: 0,1}
" Unset: g:hoverhl#match_group    {Values: '{highlightgroup}'}
" Unset: g:hoverhl#custom_dc      {Values: '', '[underline|bold|italic],...'}
" Unset: g:hoverhl#custom_fg      {Values: '', '{colorname}'}
" Unset: g:hoverhl#custom_bg      {Values: '', '{colorname}'}
" Unset: g:hoverhl#custom_guidc   {Values: '', '[underline|bold|italic],...'}
" Unset: g:hoverhl#custom_guifg   {Values: '', '#RRGGBB', '{colorname}'}
" Unset: g:hoverhl#custom_guibg   {Values: '', '#RRGGBB', '{colorname}'}
" Unset: g:hoverhl#custom_guisp   {Values: '', '#RRGGBB', '{colorname}'}
" Unset: g:hoverhl#custom_ctermdc {Values: '', '[underline|bold|italic],...'}
" Unset: g:hoverhl#custom_ctermfg {Values: '', 0-15, '{colorname}'}
" Unset: g:hoverhl#custom_ctermbg {Values: '', 0-15, '{colorname}'}
" Unset: g:hoverhl#debug          {Values: 0,1}

" Script scope
let s:match_id = 0124314

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
    if get(b:, 'hoverhl_enabled', g:hoverhl#enabled_default)
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

function! s:Navigate(direction, count) " {{{
    if a:direction != '' && a:direction != 'b'
        return
    endif

    if exists('b:hoverhl_current_word')
        for i in range(1, a:count)
            call search(s:GetPatternForWord(b:hoverhl_current_word), a:direction)
        endfor
    else
        try
            execute 'normal '.a:count.(a:direction == '' ? 'n' : 'N')
        catch /E486/
            " Strip the callstack from the search error message
            echohl ErrorMsg | echom matchstr(v:exception, '.486.*$') | echohl None
        endtry
    endif
endfunction " }}}

function! s:HighlightHoveredWord() " {{{
    if !get(b:, 'hoverhl_enabled', g:hoverhl#enabled_default)
        return
    endif
    if !exists('s:highlight_set')
        call s:SetHighlight()
    endif

    " Only highlight when on a valid word character
    let currentWord = expand('<cword>') . ''
    if !len(currentWord) || matchstr(getline('.'), '\%'.col('.').'c.') !~? '\k'
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
    silent! unlet w:hoverhl_match_defined
    silent! unlet b:hoverhl_current_word
endfunction " }}}

function! s:GetPatternForWord(word) " {{{
    if get(g:, 'hoverhl#case_sensitive', !&ignorecase || (&smartcase && (match(a:word, '\u') != -1)))
        let currentWord = a:word
        let case = '\C'
    else
        let currentWord = tolower(a:word)
        let case = '\c'
    endif

    return case.'\V\<'.escape(currentWord, '\').'\>'
endfunction " }}}

function! s:SetHighlight() " {{{
    let l:default_group = 'CursorLine'
    let l:match_group   = get(g:, 'hoverhl#match_group', l:default_group)
    if !hlexists(l:match_group)
        let l:match_group = l:default_group
    endif
    let l:synID = synIDtrans(hlID(l:match_group))

    let l:hi = {
        \ 'guidc':   get(g:, 'hoverhl#custom_guidc',   get(g:, 'hoverhl#custom_dc', GetDecorations(        l:synID,       'gui'  ))),
        \ 'guifg':   get(g:, 'hoverhl#custom_guifg',   get(g:, 'hoverhl#custom_fg', printf('%s', synIDattr(l:synID, 'fg', 'gui'  )))),
        \ 'guibg':   get(g:, 'hoverhl#custom_guibg',   get(g:, 'hoverhl#custom_bg', printf('%s', synIDattr(l:synID, 'bg', 'gui'  )))),
        \ 'guisp':   get(g:, 'hoverhl#custom_guisp',   get(g:, 'hoverhl#custom_sp', printf('%s', synIDattr(l:synID, 'sp', 'gui'  )))),
        \ 'ctermdc': get(g:, 'hoverhl#custom_ctermdc', get(g:, 'hoverhl#custom_dc', GetDecorations(        l:synID,       'cterm'))),
        \ 'ctermfg': get(g:, 'hoverhl#custom_ctermfg', get(g:, 'hoverhl#custom_fg', printf('%s', synIDattr(l:synID, 'fg', 'cterm')))),
        \ 'ctermbg': get(g:, 'hoverhl#custom_ctermbg', get(g:, 'hoverhl#custom_bg', printf('%s', synIDattr(l:synID, 'bg', 'cterm')))),
    \ }

    let l:highlight = (l:hi.guifg   != '' ? ' guifg='.l:hi.guifg     : '').
                    \ (l:hi.guibg   != '' ? ' guibg='.l:hi.guibg     : '').
                    \ (l:hi.guisp   != '' ? ' guisp='.l:hi.guisp     : '').
                    \ (l:hi.guidc   != '' ? ' gui='.l:hi.guidc       : '').
                    \ (l:hi.ctermfg != '' ? ' ctermfg='.l:hi.ctermfg : '').
                    \ (l:hi.ctermbg != '' ? ' ctermbg='.l:hi.ctermbg : '').
                    \ (l:hi.ctermdc != '' ? ' cterm='.l:hi.ctermdc   : '')

    let l:link = ''
    if l:highlight ==# ''
        let l:link = ' link'
        let l:highlight = ' '.l:default_group
    endif
    if get(g:, 'hoverhl#debug', 0)
        echom '[hoverhl: '.l:match_group.' ('.l:synID.') => hi! def'.l:link.' HoverHlWord'.l:highlight.']'
    endif
    execute 'hi! def'.l:link.' HoverHlWord'.l:highlight
    let s:highlight_set = 1
endfunction " }}}

function! GetDecorations(synID, type) " {{{
    let l:decorations = ['bold', 'italic', 'reverse', 'inverse', 'standout', 'underline', 'undercurl']
    let l:decorationsString = ''
    for l:decoration in l:decorations
        if synIDattr(a:synID, l:decoration, a:type)
            if l:decorationsString
                let l:decorationsString .= ','
            endif
            let l:decorationsString .= l:decoration
        endif
    endfor

    return l:decorationsString
endfunction " }}}

function! s:OnBufLeave() " {{{
    if get(g:, 'hoverhl#clear_on_leave', 0)
        call s:ClearHighlightedWord()
    endif
endfunction " }}}

" }}} }}}

" Plugin bindings {{{

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
    autocmd!
    autocmd ColorScheme * call s:SetHighlight()
    autocmd CursorHold  * call s:HighlightHoveredWord()
    autocmd BufLeave    * call s:OnBufLeave()
    if exists('g:hoverhl#enabled_filetypes')
        let g:hoverhl#enabled_default = 0
        execute 'autocmd FileType '.join(g:hoverhl#enabled_filetypes, ',').' let b:hoverhl_enabled = 1'
    endif
augroup END

" }}}

" vim: foldmethod=marker foldlevel=1
