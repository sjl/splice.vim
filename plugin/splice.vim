" ============================================================================
" File:        splice.vim
" Description: vim global plugin for resolving three-way merge conflicts
" Maintainer:  Steve Losh <steve@stevelosh.com>
" License:     MIT X11
" ============================================================================

" Init {{{

"call test_override('autoload', 1)
"import autoload 'splicelib/util/keys.vim'

if !exists('g:splice_debug') && (exists('g:splice_disable') || exists('loaded_splice') || &cp)
    finish
endif
let loaded_splice = 1

" }}}
" Commands {{{

command! -nargs=0 SpliceInit call splice#SpliceInit()

" }}}
