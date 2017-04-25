# Vim - HoverH[*igh*]l[*ight*]

Hover highlight (hoverhl) is a vim plugin that automatically highlights the word under your cursor and lets you navigate though other instances of the highlighted word. After installing the plugin, whenever you stop moving the cursor for `&updatetime` milliseconds, the word underneath the cursor will be highlighted throughout the document. You can then navigate to other instances of the word by using <kbd>&lt;leader&gt;n</kbd> and <kbd>&lt;leader&gt;N</kbd> as you would normally use <kbd>n</kbd> and <kbd>N</kbd> on a search. You can enable/disable the plugin on the fly by using <kbd>&lt;leader&gt;//</kbd> (or <kbd>&lt;leader>/e&gt;</kbd>/<kbd>&lt;leader&gt;/d</kbd> to just enable/disable the plugin, respectively).

## Installation

Using vim 8+:

- `git clone https://wesrupert.github.com/vim-hoverhl.git ~/.vim/pack/hoverhl`

Using pathogen:

- `git clone https://wesrupert.github.com/vim-hoverhl.git {temp dir of choice}`
- Map or move the `hoverhl/start/hoverhl` directory into your `bundle` directory

## Configuration

### Activation

By default, this plugin is enabled for all filetypes. You can set a list of filetypes to have it only highlight in those files by setting `g:hoverHlEnabledFiletypes`:

```vim
let g:hoverHlEnabledFiletypes = [ 'c', 'cpp', 'cs', 'sh', 'vim', '...' ]
```

### Mappings

By default, the aforementioned mappings are defined for you. If you would prefer your own mappings, you can map to any of the following functions:

```vim
HoverHlToggle()    " Enables/disables the plugin
HoverHlEnable()    " Enables the plugin
HoverHlDisable()   " Disables the plugin
HoverHlForward(n)  " Moves to the nth next instance of the highlighted word
HoverHlBackward(n) " Moves to the nth previous instance of the highlighted word
```

These functions are also available in `command` and `map <plug>` forms. Alternatively, you can set `g:hoverHlStandardMappings = 0` if you would like to remove the default bindings entirely.

### Colors

The plugin uses the current colorscheme's `CursorLine` highlight colors by default. If you'd prefer colors from a different highlight group, or different colors altogether, you can set the following in your vimrc:

```vim
" Different highlight group
let g:hoverHlMatchGroup = 'Search'

" Custom colors.
" If these are set, they take precedence over the highlight group!
let g:hoverHlCustomFg = '#RRGGBB'
let g:hoverHlCustomBg = '#RRGGBB'

" Alternatively, to leave the foreground/background color untouched when hovering:
let g:hoverHlCustomFg = ''
let g:hoverHlCustomBg = ''
```
### Miscellaneous

If you would like to only ever manually enable this plugin, you can set `g:hoverHlEnabledDefault = 0`, and only enable on a per-buffer basis. Finally, you can also use custom case sensitivity by setting `g:hoverHlCaseSensitive = 0 or 1`.


## Author

[@wesrupert](https://twitter.com/wesrupert)

Inspired by [@lfv89](http://twitter.com/lfv89)'s vim plugin [InterestingWords](https://github.com/lfv89/vim-interestingwords).

