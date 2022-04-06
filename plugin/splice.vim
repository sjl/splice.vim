" ============================================================================
" File:        splice.vim
" Description: vim global plugin for resolving three-way merge conflicts
" Maintainer:  Steve Losh <steve@stevelosh.com>
" License:     MIT X11
" ============================================================================

" Init

" Vim version check

if ! has('vim9script')
    echomsg 'This version of Splice requires vim9script'
    echomsg ' '
    echomsg 'Since the merge can not be completed, the merge'
    echomsg 'should be aborted so it can be completed later.'
    echomsg ' '
    echomsg 'NOTE: the vim command ":cq" aborts the merge.'
    echomsg ' '
    echomsg ' '

    finish
endif

vim9script

# call test_override('autoload', 1)
import autoload '../autoload/splice.vim'

command! -nargs=0 SpliceInit call splice.SpliceBoot()

var patch = 4676
var longv = 8020000 + patch

if v:versionlong < longv
    splice.RecordBootFailure(
        ["Splice unavailable: requires Vim 8.2." .. patch])
    finish
endif

# TODO: wonder what this condition is all about, seems to have been optimized away
var loaded_splice: number
if !exists('g:splice_debug') && (exists('g:splice_disable') || loaded_splice > 0 || &cp)
    finish
endif
loaded_splice = 1

