# Vim - HoverH*[igh]*l*[ight]*

Hover highlight (or hoverhl) is a vim plugin that automatically highlights the word under your cursor and lets you navigate though other instances of the highlighted word. After installing the plugin, whenever you stop moving the cursor for `&updatetime` milliseconds, the word underneath the cursor will be highlighted throughout the document. You can then navigate to other instances of the word by using `<leader>n` and `<leader>N` as you would normally use `n` and `N` on a search. You can enable/disable the plugin on the fly by using `<leader>K`.

## Installation

Using vim 8+:

- `git clone https://wesrupert.github.com/vim-hoverhl.git ~/.vim/pack/hoverhl`

Using pathogen:

- `git clone https://wesrupert.github.com/vim-hoverhl.git {temp dir of choice}`
- Move the `hoverhl/start/hoverhl` directory into your `bundle` directory

## Configuration

By default, this plugin is enabled for all filetypes. You can set a list of filetypes to have it only highlight in those files by setting `g:hoverHlEnabledFiletypes`:

```vim
let g:hoverHlEnabledFiletypes = [ 'c', 'cpp', 'cs', 'sh', 'vim', '...' ]
```

By default, the mappings `<leader>n` `<leader>N` and `<leader>K` are defined for you. If you would prefer your own mappings, you can set `g:hoverHlStandardMappings = 0`, then define mappings to any of the following functions:

```vim
function HoverHlDisable()  " Disables the plugin until HoverHlEnable is called
function HoverHlEnable()   " Enables the plugin again
function HoverHlToggle()   " Enables/Disabled the plugin
function HoverHlForward()  " Moves to the next instance of the highlighted word
function HoverHlBackward() " Moves to the previous instance of the highlighted word
```

These functions are also available in `<plug>` form.

The plugin uses the current colorscheme's `CursorLine` highlight colors by default. If you'd prefer colors from a different highlight group, or different colors altogether, you can set the following in your vimrc:

```vim
" Different highlight group
let g:hoverHlMatchGroup = 'Search'

" Custom colors
let g:hoverHlCustomFg = '#RRGGBB'
let g:hoverHlCustomBg = '#RRGGBB'

" Alternatively, to leave the foreground/background color untouched when hovering:
let g:hoverHlCustomFg = ''
let g:hoverHlCustomBg = ''
```

Finally, you can also use custom case sensitivity by setting `g:hoverHlCaseSensitive`.

```vim
let g:hoverHlCaseSensitive = 1
```

## Author

[@wesrupert](https://github.com/wesrupert)

Inspired by [@lfv89](http://twitter.com/lfv89)'s vim plugin [InterestingWords](https://github.com/lfv89/vim-interestingwords).
