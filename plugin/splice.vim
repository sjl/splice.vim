" ============================================================================
" File:        splice.vim
" Description: vim global plugin for resolving three-way merge conflicts
" Maintainer:  Steve Losh <steve@stevelosh.com>
" License:     MIT X11
" ============================================================================

" Init

" Vim version check

vim9script

# call test_override('autoload', 1)
import autoload 'splice.vim'

command! -nargs=0 SpliceInit call splice.SpliceBoot()

var patch = 4589
var longv = 8020000 + patch

if v:versionlong < longv || !has('vim9script')
    splice.RecordBootFailure(
        ["Splice unavailable: requires Vim 8.2." .. patch .. "+/vim9script"])
    finish
endif

# TODO: wonder what this condition is all about, seems to have been optimized away
var loaded_splice: number
if !exists('g:splice_debug') && (exists('g:splice_disable') || loaded_splice > 0 || &cp)
    finish
endif
loaded_splice = 1

