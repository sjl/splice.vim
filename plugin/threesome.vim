" ============================================================================
" File:        threesome.vim
" Description: vim global plugin for resolving three-way merge conflicts
" Maintainer:  Steve Losh <steve@stevelosh.com>
" License:     MIT X11
" Notes:       Alpha.  Not ready for real use yet.
"
" ============================================================================


"{{{ Init

" Loading check {{{

if !exists('g:threesome_debug') && (exists('g:threesome_disable') || exists('loaded_threesome') || &cp)
    finish
endif
let loaded_threesome = 1

"}}}
" Vim version check {{{

if v:version < '703'
    function! s:ThreesomeDidNotLoad()
        echohl WarningMsg|echomsg "Threesome unavailable: requires Vim 7.3+"|echohl None
    endfunction
    command! -nargs=0 ThreesomeInit call s:ThreesomeDidNotLoad()
    finish
endif

"}}}
" Python version check {{{

if has('python')
    let s:has_supported_python = 2
python << ENDPYTHON
import sys, vim
if sys.version_info[:2] < (2, 5):
    vim.command('let s:has_supported_python = 0')
ENDPYTHON
else
    let s:has_supported_python = 0
endif

if !s:has_supported_python
    function! s:ThreesomeDidNotLoad()
        echohl WarningMsg|echomsg "Threesome requires Vim to be compiled with Python 2.5+"|echohl None
    endfunction
    command! -nargs=0 ThreesomeInit call s:ThreesomeDidNotLoad()
    finish
endif

"}}}
" Configuration variables {{{

if !exists('g:threesome_disable') " {{{
    let g:threesome_disable = 0
endif " }}}

"}}}

"}}}

"{{{ Wrappers

function! s:ThreesomeInit()"{{{
    let python_module = fnameescape(globpath(&runtimepath, 'plugin/threesome.py'))
    exe 'pyfile ' . python_module
    python ThreesomeInit()
endfunction"}}}

"}}}

"{{{ Commands

command! -nargs=0 ThreesomeInit call s:ThreesomeInit()

"}}}

" vim:se fdm=marker:sw=4:
