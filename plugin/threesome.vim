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
if !exists('g:threesome_initial_mode') " {{{
    let g:threesome_initial_mode = 'grid'
endif " }}}
if !exists('g:threesome_initial_layout_grid') " {{{
    let g:threesome_initial_layout_grid = 0
endif " }}}
if !exists('g:threesome_initial_layout_loupe') " {{{
    let g:threesome_initial_layout_loupe = 0
endif " }}}
if !exists('g:threesome_initial_layout_compare') " {{{
    let g:threesome_initial_layout_compare = 0
endif " }}}
if !exists('g:threesome_initial_layout_path') " {{{
    let g:threesome_initial_layout_path = 0
endif " }}}
if !exists('g:threesome_initial_diff_grid') " {{{
    let g:threesome_initial_diff_grid = 0
endif " }}}
if !exists('g:threesome_initial_diff_loupe') " {{{
    let g:threesome_initial_diff_loupe = 0
endif " }}}
if !exists('g:threesome_initial_diff_compare') " {{{
    let g:threesome_initial_diff_compare = 0
endif " }}}
if !exists('g:threesome_initial_diff_path') " {{{
    let g:threesome_initial_diff_path = 0
endif " }}}
if !exists('g:threesome_initial_scrollbind_grid') " {{{
    let g:threesome_initial_scrollbind_grid = 0
endif " }}}
if !exists('g:threesome_initial_scrollbind_loupe') " {{{
    let g:threesome_initial_scrollbind_loupe = 0
endif " }}}
if !exists('g:threesome_initial_scrollbind_compare') " {{{
    let g:threesome_initial_scrollbind_compare = 0
endif " }}}
if !exists('g:threesome_initial_scrollbind_path') " {{{
    let g:threesome_initial_scrollbind_path = 0
endif " }}}

"}}}

"}}}

"{{{ Wrappers

function! s:ThreesomeInit()"{{{
    let python_module = fnameescape(globpath(&runtimepath, 'plugin/threesome.py'))
    exe 'pyfile ' . python_module
    python ThreesomeInit()
endfunction"}}}

function! s:ThreesomeGrid()"{{{
    python ThreesomeGrid()
endfunction"}}}
function! s:ThreesomeLoupe()"{{{
    python ThreesomeLoupe()
endfunction"}}}
function! s:ThreesomeCompare()"{{{
    python ThreesomeCompare()
endfunction"}}}
function! s:ThreesomePath()"{{{
    python ThreesomePath()
endfunction"}}}

function! s:ThreesomeOriginal()"{{{
    python ThreesomeOriginal()
endfunction"}}}
function! s:ThreesomeOne()"{{{
    python ThreesomeOne()
endfunction"}}}
function! s:ThreesomeTwo()"{{{
    python ThreesomeTwo()
endfunction"}}}
function! s:ThreesomeResult()"{{{
    python ThreesomeResult()
endfunction"}}}

function! s:ThreesomeDiff()"{{{
    python ThreesomeDiff()
endfunction"}}}
function! s:ThreesomeDiffoff()"{{{
    python ThreesomeDiffoff()
endfunction"}}}
function! s:ThreesomeScroll()"{{{
    python ThreesomeScroll()
endfunction"}}}
function! s:ThreesomeLayout()"{{{
    python ThreesomeLayout()
endfunction"}}}
function! s:ThreesomeNext()"{{{
    python ThreesomeNext()
endfunction"}}}
function! s:ThreesomePrev()"{{{
    python ThreesomePrev()
endfunction"}}}
function! s:ThreesomeUse()"{{{
    python ThreesomeUse()
endfunction"}}}
function! s:ThreesomeUse1()"{{{
    python ThreesomeUse1()
endfunction"}}}
function! s:ThreesomeUse2()"{{{
    python ThreesomeUse2()
endfunction"}}}

"}}}

"{{{ Commands

command! -nargs=0 ThreesomeInit call s:ThreesomeInit()

command! -nargs=0 ThreesomeGrid call s:ThreesomeGrid()
command! -nargs=0 ThreesomeLoupe call s:ThreesomeLoupe()
command! -nargs=0 ThreesomeCompare call s:ThreesomeCompare()
command! -nargs=0 ThreesomePath call s:ThreesomePath()

command! -nargs=0 ThreesomeOriginal call s:ThreesomeOriginal()
command! -nargs=0 ThreesomeOne call s:ThreesomeOne()
command! -nargs=0 ThreesomeTwo call s:ThreesomeTwo()
command! -nargs=0 ThreesomeResult call s:ThreesomeResult()

command! -nargs=0 ThreesomeDiff call s:ThreesomeDiff()
command! -nargs=0 ThreesomeDiffoff call s:ThreesomeDiffoff()
command! -nargs=0 ThreesomeScroll call s:ThreesomeScroll()
command! -nargs=0 ThreesomeLayout call s:ThreesomeLayout()
command! -nargs=0 ThreesomeNext call s:ThreesomeNext()
command! -nargs=0 ThreesomePrev call s:ThreesomePrev()
command! -nargs=0 ThreesomeUse call s:ThreesomeUse()
command! -nargs=0 ThreesomeUse1 call s:ThreesomeUse1()
command! -nargs=0 ThreesomeUse2 call s:ThreesomeUse2()

"}}}

" vim:se fdm=marker:sw=4:
