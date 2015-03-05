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
    let s:splice_pyfile = 'pyfile'
    command! -nargs=1 SplicePython python <args>
elseif has('python3')
    let s:has_supported_python = 3
    let s:splice_pyfile = 'py3file'
    command! -nargs=1 SplicePython python3 <args>
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
    exe s:splice_pyfile . ' ' . python_module
    SplicePython SpliceInit()
endfunction "}}}

function! splice#SpliceGrid() "{{{
    SplicePython SpliceGrid()
endfunction "}}}
function! splice#SpliceLoupe() "{{{
    SplicePython SpliceLoupe()
endfunction "}}}
function! splice#SpliceCompare() "{{{
    SplicePython SpliceCompare()
endfunction "}}}
function! splice#SplicePath() "{{{
    SplicePython SplicePath()
endfunction "}}}

function! splice#SpliceOriginal() "{{{
    SplicePython SpliceOriginal()
endfunction "}}}
function! splice#SpliceOne() "{{{
    SplicePython SpliceOne()
endfunction "}}}
function! splice#SpliceTwo() "{{{
    SplicePython SpliceTwo()
endfunction "}}}
function! splice#SpliceResult() "{{{
    SplicePython SpliceResult()
endfunction "}}}

function! splice#SpliceDiff() "{{{
    SplicePython SpliceDiff()
endfunction "}}}
function! splice#SpliceDiffoff() "{{{
    SplicePython SpliceDiffoff()
endfunction "}}}
function! splice#SpliceScroll() "{{{
    SplicePython SpliceScroll()
endfunction "}}}
function! splice#SpliceLayout() "{{{
    SplicePython SpliceLayout()
endfunction "}}}
function! splice#SpliceNext() "{{{
    SplicePython SpliceNext()
endfunction "}}}
function! splice#SplicePrev() "{{{
    SplicePython SplicePrev()
endfunction "}}}
function! splice#SpliceUse() "{{{
    SplicePython SpliceUse()
endfunction "}}}
function! splice#SpliceUse1() "{{{
    SplicePython SpliceUse1()
endfunction "}}}
function! splice#SpliceUse2() "{{{
    SplicePython SpliceUse2()
endfunction "}}}

" }}}
