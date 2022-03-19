vim9script

import autoload 'splicelib/util/log.vim'

var debug = false

var use_props = true

const CONFLICT_MARKER_MARK = '======='

# highlighting
highlight link SpliceConflict CursorColumn
highlight link SpliceCurrentConflict Todo

var hl_conflict = 'SpliceConflict'
var hl_cur_conflict = 'SpliceCurrentConflict'

const pri_hl_conflict = 100
const pri_hl_cur_conflict = 110

var prop_conflict = 'prop_conflict'
var prop_cur_conflict = 'prop_cur_conflict'

const CONFLICT_PATTERN = '\m^=======*$'

def DeleteHighlights(ids: list<number>)
    if use_props
        ids->filter( (_, v) => {
            prop_remove({ id: v, all: true })
            return false
            })
    else
        ids->filter( (_, v) => {
            matchdelete(v)
            return false
            })
    endif
enddef

# only if use_props
# to give each prop its own id
var id_prop: number

# return something suitable for setting text properties
# TODO don't add the same line more than once (not an issue with conflict)
def FindLines(pat: string, flags: string = ''): list<number>
    var result: list<number> = []
    var tpos = getcurpos()
    cursor(1, 1)
    while search(pat, flags .. 'W') != 0
        result->add(line('.'))
    endwhile
    setpos('.', tpos)
    return result
enddef

var id_conflict: list<number>

export def HighlightConflict()
    #log.Log('conf ids before:' .. string(id_conflict))
    if use_props
        id_conflict->DeleteHighlights()
        var lines = FindLines(CONFLICT_PATTERN)
        #log.Log('FindLines: ' .. string(lines))
        id_prop += 1
        prop_add_list({ type: prop_conflict, id: id_prop },
            lines->mapnew((_, l) => [ l, 1, l, col([l, '$']) ] ))
        id_conflict->add(id_prop)
    else
        id_conflict->DeleteHighlights()
        # {} can contain window
        id_conflict->add(matchadd(hl_conflict, CONFLICT_PATTERN, pri_hl_conflict))
    endif
    #log.Log('conf ids after:' .. string(id_conflict))
enddef

var id_cur_conflict: list<number>

export def MoveToConflict(forw: bool = true)
    var flags = forw ? '' : 'b'

    ###
    ### could just do HighlightConflict only once after spliceinit
    ###
    HighlightConflict()

    # the next/prev conflict
    var lino = search(CONFLICT_PATTERN, flags)
    #log.Log('cur_conf ids before:' .. string(id_cur_conflict))
    if use_props
        id_cur_conflict->DeleteHighlights()
        var col = col([lino, '$'])
        id_prop += 1
        prop_add(lino, 1, { type: prop_cur_conflict, length: col, id: id_prop })
        id_cur_conflict->add(id_prop)
    else
        id_cur_conflict->DeleteHighlights()
        var t = matchaddpos(hl_cur_conflict, [ lino ], pri_hl_cur_conflict)
        id_cur_conflict->add(t)
    endif
    #log.Log('cur_conf ids after:' .. string(id_cur_conflict))
enddef

# make them global properties
def AddConflictProps()
    var prop_con = {
        highlight: hl_conflict,
        priority: pri_hl_conflict,
        combine: false
        }
    var prop_cur_con = {
        highlight: hl_cur_conflict,
        priority: pri_hl_cur_conflict,
        combine: false
        }
    if ! debug
        prop_conflict->prop_type_add(prop_con)
        prop_cur_conflict->prop_type_add(prop_cur_con)
    else
        if prop_conflict->prop_type_get() == {}
            prop_conflict->prop_type_add(prop_con)
        else
            # for testing, always do a change
            prop_conflict->prop_type_change(prop_con)
        endif
        if prop_cur_conflict->prop_type_get() == {}
            prop_cur_conflict->prop_type_add(prop_cur_con)
        else
            # for testing, always do a change
            prop_cur_conflict->prop_type_change(prop_cur_con)
        endif
    endif
enddef

# add the props when this file is loaded
AddConflictProps()

if debug
    command! -nargs=? M1 MoveToConflict(<f-args>)
    command! -nargs=0 M2 HighlightConflict()

    def Clear()
        clearmatches()
        #prop_remove({ id: v, all: true })
        prop_remove({ type: prop_conflict })
        prop_remove({ type: prop_cur_conflict })
        id_conflict = []
        id_cur_conflict = []
    enddef
    command! -nargs=0 Clear Clear()
endif
