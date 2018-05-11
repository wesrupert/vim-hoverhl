# Vim - HoverH[*igh*]l[*ight*]

Hover highlight (hoverhl) is a vim plugin that automatically highlights the word under your cursor and lets you navigate though other instances of the highlighted word. After installing the plugin, whenever you stop moving the cursor for `&updatetime` milliseconds, the word underneath the cursor will be highlighted throughout the document. You can then navigate to other instances of the word by using <kbd>&lt;leader&gt;n</kbd> and <kbd>&lt;leader&gt;N</kbd> as you would normally use <kbd>n</kbd> and <kbd>N</kbd> on a search. You can also lock the hovered word with <kbd>&lt;leader&gt;//</kbd> to keep it as the current highlight until it is unlocked via <kbd>&lt;leader&gt;//</kbd> again. You can enable/disable the plugin on the fly by using <kbd>&lt;leader&gt;/t</kbd> (or <kbd>&lt;leader>/e&gt;</kbd>/<kbd>&lt;leader&gt;/d</kbd> to just enable/disable the plugin, respectively).

## Installation

Using vim 8+:

- `git clone https://wesrupert.github.com/vim-hoverhl.git ~/.vim/pack/hoverhl/start/hoverhl`

Using package managers:

- Using pathogen: `git clone https://wesrupert.github.com/vim-hoverhl.git bundle/hoverhl`
- Using vim-plug: `Plug 'wesrupert/vim-hoverhl'`

## Configuration

### Activation

By default, this plugin is enabled for all filetypes. You can set a list of filetypes to have it only highlight in those files by setting `g:hoverhl#enabled_filetypes`:

```vim
let g:hoverhl#enabled_filetypes = [ 'c', 'cpp', 'cs', 'sh', 'vim', '...' ]
```

### Mappings

By default, the aforementioned mappings are defined for you. If you would prefer your own mappings, you can map to any of the following functions:

```vim
HoverHlToggle()    " Enables/disables the plugin
HoverHlEnable()    " Enables the plugin
HoverHlDisable()   " Disables the plugin
HoverHlLock()      " Locks/unlocks the highlighted word
HoverHlForward(n)  " Moves to the nth next instance of the highlighted word
HoverHlBackward(n) " Moves to the nth previous instance of the highlighted word
```

These functions are also available in `command` and `map <plug>` forms. Alternatively, you can set `g:hoverhl#standard_mappings = 0` if you would like to remove the default bindings entirely.

### Colors

The plugin uses the current colorscheme's `CursorLine` highlight colors by default. If you'd prefer colors from a different highlight group, or different colors altogether, you can set the following in your vimrc:

```vim
" Different highlight group
let g:hoverhl#match_group = 'Search'

" Custom colors
" If these are set, they take precedence over the highlight group!

" Agnostic: Colorname
let g:hoverhl#custom_fg = 'LightBlue'
let g:hoverhl#custom_bg = 'LightBlue'
" GUI: Colorname, #RRGGBB
let g:hoverhl#custom_guifg = 'LightBlue'
let g:hoverhl#custom_guibg = '#ADD8E6'
let g:hoverhl#custom_guisp = '#0088FF'
" CTERM: Colorname, Colorindex
let g:hoverhl#custom_ctermfg = 'LightBlue'
let g:hoverhl#custom_ctermbg = 9

" Alternatively, to leave that color unchanged when hovering, set it to '':
let g:hoverhl#custom_fg = ''

" Custom decorations, separated by commas
let g:hoverhl#custom_dc = 'underline'
let g:hoverhl#custom_guidc = 'bold,italics'
let g:hoverhl#custom_guidc = ''
```

### Miscellaneous

- If you would like to disable automatic loading, you can set `g:hoverhl#enabled_default = 0`.
- If you want to only show highlights in the current buffer, you can set `g:hoverhl#clear_on_leave = 1`.
- If you want case sensitivity that doesn't follow smartcase/ignorecase, set `g:hoverhl#case_sensitive = 0 or 1`.


## Author

[@wesrupert](https://twitter.com/wesrupert)

Inspired by [@lfv89](http://twitter.com/lfv89)'s vim plugin [InterestingWords](https://github.com/lfv89/vim-interestingwords).

