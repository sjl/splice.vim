" ============================================================================
" File:        splice.vim
" Description: vim global plugin for resolving three-way merge conflicts
" Maintainer:  Steve Losh <steve@stevelosh.com>
" License:     MIT X11
" ============================================================================

" Init {{{

if !exists('g:splice_debug') && (exists('g:splice_disable') || exists('loaded_splice') || &cp)
    finish
endif
let loaded_splice = 1

" }}}
" Commands {{{

command! -nargs=0 SpliceInit call splice#SpliceInit()

command! -nargs=0 SpliceGrid call splice#SpliceGrid()
command! -nargs=0 SpliceLoupe call splice#SpliceLoupe()
command! -nargs=0 SpliceCompare call splice#SpliceCompare()
command! -nargs=0 SplicePath call splice#SplicePath()

command! -nargs=0 SpliceOriginal call splice#SpliceOriginal()
command! -nargs=0 SpliceOne call splice#SpliceOne()
command! -nargs=0 SpliceTwo call splice#SpliceTwo()
command! -nargs=0 SpliceResult call splice#SpliceResult()

command! -nargs=0 SpliceDiff call splice#SpliceDiff()
command! -nargs=0 SpliceDiffoff call splice#SpliceDiffoff()
command! -nargs=0 SpliceScroll call splice#SpliceScroll()
command! -nargs=0 SpliceLayout call splice#SpliceLayout()
command! -nargs=0 SpliceNext call splice#SpliceNext()
command! -nargs=0 SplicePrev call splice#SplicePrev()
command! -nargs=0 SpliceUse call splice#SpliceUse()
command! -nargs=0 SpliceUse1 call splice#SpliceUse1()
command! -nargs=0 SpliceUse2 call splice#SpliceUse2()

" }}}
