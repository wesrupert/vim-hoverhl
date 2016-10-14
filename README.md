# Vim - HoverH*[igh]*l*[ight]*

Hover highlight (or hoverhl) is a vim plugin that automatically highlights the word under your cursor and lets you navigate though other instances of the highlighted word. After installing the plugin, whenever you stop moving the cursor for `&updatetime` milliseconds, the word underneath the cursor will be highlighted throughout the document. You can then navigate to other instances of the word by using `<leader>n` and `<leader>N` as you would normally use `n` and `N` on a search. You can enable/disable the plugin on the fly by using `<leader>K`.

## Installation

Using vim 8+:

- `git clone https://wesrupert.github.com/vim-hoverhl.git ~/.vim/pack/hoverhl`

Using pathogen:

- `git clone https://wesrupert.github.com/vim-hoverhl.git {temp dir of choice}`
- Move the `hoverhl/start/hoverhl` directory into your `bundle` directory


## Configuration

By default, the mappings `<leader>n` `<leader>N` and `<leader>K` are defined for you. If you would prefer your own mappings, you can set `g:hoverHlStandardMappings = 0`, then define mappings to any of the following functions:

```vim
function HoverHlDisable()  " Disables the plugin until HoverHlEnable is called
function HoverHlEnable()   " Enables the plugin again
function HoverHlToggle()   " Enables/Disabled the plugin
function HoverHlForward()  " Moves to the next instance of the highlighted word
function HoverHlBackward() " Moves to the previous instance of the highlighted word
```

These functions are also available in `<plug>` form.

The plugin uses the current colorscheme's search highlight colors by default. If you'd prefer different colors, you can set the following in your vimrc:

```vim
let g:hoverHlCustomBg = '#RRGGBB'
let g:hoverHlCustomFg = '#RRGGBB'

" Alternatively, to leave the foreground color untouched when hovering:
let g:hoverHlCustomFg = ''
```

Finally, you can also use custom case sensitivity by setting `g:hoverHlCaseSensitive = 1`.

## Author

[@wesrupert](https://github.com/wesrupert)

Inspired by [@lfv89](http://twitter.com/lfv89)'s vim plugin [InterestingWords](https://github.com/lfv89/vim-interestingwords).
