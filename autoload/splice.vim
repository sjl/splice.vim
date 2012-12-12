" ============================================================================
" File:        splice.vim
" Description: vim global plugin for resolving three-way merge conflicts
" Maintainer:  Steve Losh <steve@stevelosh.com>
" License:     MIT X11
" ============================================================================

" Init {{{

" Vim version check {{{

if v:version < '703'
    function! s:SpliceDidNotLoad()
        echohl WarningMsg|echomsg "Splice unavailable: requires Vim 7.3+"|echohl None
    endfunction
    command! -nargs=0 SpliceInit call s:SpliceDidNotLoad()
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
    function! s:SpliceDidNotLoad()
        echohl WarningMsg|echomsg "Splice requires Vim to be compiled with Python 2.5+"|echohl None
    endfunction
    command! -nargs=0 SpliceInit call s:SpliceDidNotLoad()
    finish
endif

"}}}
" Configuration variables {{{

if !exists('g:splice_disable') "{{{
    let g:splice_disable = 0
endif " }}}
if !exists('g:splice_initial_mode') "{{{
    let g:splice_initial_mode = 'grid'
endif "}}}
if !exists('g:splice_initial_layout_grid') "{{{
    let g:splice_initial_layout_grid = 0
endif "}}}
if !exists('g:splice_initial_layout_loupe') "{{{
    let g:splice_initial_layout_loupe = 0
endif "}}}
if !exists('g:splice_initial_layout_compare') "{{{
    let g:splice_initial_layout_compare = 0
endif "}}}
if !exists('g:splice_initial_layout_path') "{{{
    let g:splice_initial_layout_path = 0
endif "}}}
if !exists('g:splice_initial_diff_grid') "{{{
    let g:splice_initial_diff_grid = 0
endif "}}}
if !exists('g:splice_initial_diff_loupe') "{{{
    let g:splice_initial_diff_loupe = 0
endif "}}}
if !exists('g:splice_initial_diff_compare') "{{{
    let g:splice_initial_diff_compare = 0
endif "}}}
if !exists('g:splice_initial_diff_path') "{{{
    let g:splice_initial_diff_path = 0
endif "}}}
if !exists('g:splice_initial_scrollbind_grid') "{{{
    let g:splice_initial_scrollbind_grid = 0
endif "}}}
if !exists('g:splice_initial_scrollbind_loupe') "{{{
    let g:splice_initial_scrollbind_loupe = 0
endif "}}}
if !exists('g:splice_initial_scrollbind_compare') "{{{
    let g:splice_initial_scrollbind_compare = 0
endif "}}}
if !exists('g:splice_initial_scrollbind_path') "{{{
    let g:splice_initial_scrollbind_path = 0
endif "}}}
if !exists('g:splice_prefix') "{{{
    if exists('g:splice_leader')
        let g:splice_prefix = g:splice_leader
    else
        let g:splice_prefix = '-'
    endif
endif "}}}

" }}}

" }}}
" Wrappers {{{

function! splice#SpliceInit() "{{{
    let python_module = fnameescape(globpath(&runtimepath, 'autoload/splice.py'))
    exe 'pyfile ' . python_module
    python SpliceInit()
endfunction "}}}

function! splice#SpliceGrid() "{{{
    python SpliceGrid()
endfunction "}}}
function! splice#SpliceLoupe() "{{{
    python SpliceLoupe()
endfunction "}}}
function! splice#SpliceCompare() "{{{
    python SpliceCompare()
endfunction "}}}
function! splice#SplicePath() "{{{
    python SplicePath()
endfunction "}}}

function! splice#SpliceOriginal() "{{{
    python SpliceOriginal()
endfunction "}}}
function! splice#SpliceOne() "{{{
    python SpliceOne()
endfunction "}}}
function! splice#SpliceTwo() "{{{
    python SpliceTwo()
endfunction "}}}
function! splice#SpliceResult() "{{{
    python SpliceResult()
endfunction "}}}

function! splice#SpliceDiff() "{{{
    python SpliceDiff()
endfunction "}}}
function! splice#SpliceDiffoff() "{{{
    python SpliceDiffoff()
endfunction "}}}
function! splice#SpliceScroll() "{{{
    python SpliceScroll()
endfunction "}}}
function! splice#SpliceLayout() "{{{
    python SpliceLayout()
endfunction "}}}
function! splice#SpliceNext() "{{{
    python SpliceNext()
endfunction "}}}
function! splice#SplicePrev() "{{{
    python SplicePrev()
endfunction "}}}
function! splice#SpliceUse() "{{{
    python SpliceUse()
endfunction "}}}
function! splice#SpliceUse1() "{{{
    python SpliceUse1()
endfunction "}}}
function! splice#SpliceUse2() "{{{
    python SpliceUse2()
endfunction "}}}

" }}}
