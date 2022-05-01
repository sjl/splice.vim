vim9script

# NOTE: simplification/rewrite when vim9 classes. "class Mode"

var testing = false

var hl_label: string
var hl_sep: string
var hl_command: string
var hl_rollover: string
var hl_active: string
# TODO: use hl_active for current mode, diff on, scrollbind on

var Log: func

if ! testing
    import autoload './util/log.vim'
    import autoload './util/vim_assist.vim'
    import autoload '../splice.vim'

    hl_label = splice.hl_label
    hl_sep = splice.hl_sep
    hl_command = splice.hl_command
    hl_rollover = splice.hl_rollover
    hl_active = splice.hl_active

    Log = log.Log
else
    import './vim_assist.vim'
    import './hud_sub.vim'
    import './log.vim-splice' as log

    const DumpDia = hud_sub.DumpDia
    const DisplayHuds = hud_sub.DisplayHuds
    def TLog(s: string)
        echomsg s
    enddef
    #Log = TLog
    Log = log.Log
    log.LogInit('/home/err/play/SPLICE_LOG')

    hl_label = 'SpliceLabel'
    hl_sep = 'SpliceLabel'
    hl_command = 'SpliceCommand'
    hl_rollover = 'Pmenu'
    hl_active = 'Keyword'

    highlight SpliceCommand term=bold cterm=bold gui=bold
    highlight SpliceLabel term=underline ctermfg=6 guifg=DarkCyan

endif

if exists('&mousemoveevent')
    &mousemoveevent = true
endif

const Pad = vim_assist.Pad
const Replace = vim_assist.Replace

#
# TODO: define settings for highlights
#


# The HUD is made up of 3 lines and 3 sections: modes, layout, commands.
# Each section is 3 lines high. Each section is a fixed width.

# use vertical double bar if possible
const sepchar = &encoding == 'utf-8' && &ambiwidth == 'single'
    ? nr2char(0x2551) : '|'
const sep_pad = '  '
const sep = sep_pad .. sepchar .. sep_pad

var diagram_width: number
var layout_offset: number
var actions_offset: number

var actions: dict<list<number>>

const label_modes = 'Splice Modes:'
const label_layout = 'Layout:'
const label_commands = 'Splice Commands:'

#
# Track last window position.
# Use it to go back to the prev window before executing a command.
#
var last_win = null_list

def ClearWinPos()
    last_win = null_list
enddef

def RestoreWinPos()
    if last_win != null
        # copy before it's change by win_gotoid
        var lw = last_win->deepcopy()
        if win_gotoid(lw[0])
            setpos('.', lw[1])
        endif
        last_win = null_list
    endif
enddef

# only save positions for our magic merge windows
def SaveWinPos()
    var bnr = bufnr()
    last_win = bnr >= 1 && bnr <= 4
                ? [ win_getid(), getcurpos() ] : null_list
enddef

augroup hud
    autocmd!
    autocmd WinLeave * SaveWinPos()
augroup END


def ExecuteCommand(cmd: string)
    if testing
        RestoreWinPos()
        echo 'Execute: ' .. cmd
    else
        RestoreWinPos()
        var splice_cmd = 'Splice' .. cmd
        Log('Execute: ' .. splice_cmd)
        execute splice_cmd
    endif
enddef

#
# Diagrams from modes.py
#

# Grid
#   Layout 0                 Layout 1                        Layout 2
#   +-------------------+    +--------------------------+    +---------------+
#   |     Original      |    | One    | Result | Two    |    |      One      |
#   |2                  |    |        |        |        |    |2              |
#   +-------------------+    |        |        |        |    +---------------+
#   |  One    |    Two  |    |        |        |        |    |     Result    |
#   |3        |4        |    |        |        |        |    |3              |
#   +-------------------+    |        |        |        |    +---------------+
#   |      Result       |    |        |        |        |    |      Two      |
#   |5                  |    |2       |3       |4       |    |4              |
#   +-------------------+    +--------------------------+    +---------------+





#
# modes_diagram
#
var modes_diagram =<< EOF
 [g]rid    [c]ompare
 XXXXXX    YYYYYYYYY
 [l]oupe   [p]ath
 XXXXXXX   YYYYYY
EOF
# TODO: get rid of mode_markers, NOT USED
var mode_markers = [ modes_diagram->remove(1) ]->add(modes_diagram->remove(2))
modes_diagram->insert(label_modes)->Pad()
lockvar! modes_diagram

#
# commands
#
# The commands 
var commands =<< EOF
d: cycle diffs   n: next conflict   space: cycle layouts   u : use hunk   o: original   1: one   q: save and quit
AAAAAAAAAAAAAA   BBBBBBBBBBBBBBBB   CCCCCCCCCCCCCCCCCCCC   DDDDDDDDDDDD   EEEEEEEEEEE   FFFFFF   GGGGGGGGGGGGGGGG
D: diffs off     N: prev conflict   s: toggle scrollbind                  r: result     2: two   CC: exit with error
AAAAAAAAAAAA     BBBBBBBBBBBBBBBB   CCCCCCCCCCCCCCCCCCCC                  EEEEEEEEE     FFFFFF   GGGGGGGGGGGGGGGGGGG
EOF
#D: diffs off     N: prev conflict   s: toggle scrollbind   u2:  hunk2     r: result     2: two   CC: exit with error
#AAAAAAAAAAAA     BBBBBBBBBBBBBBBB   CCCCCCCCCCCCCCCCCCCC   DDDDDDDDDDDD   EEEEEEEEE     FFFFFF   GGGGGGGGGGGGGGGGGGG

#var command_markers = [ commands->remove(3) ]->insert(commands->remove(1))
var command_markers = [ commands->remove(1) ]->add(commands->remove(2))
commands->insert(label_commands)->Pad()
lockvar! commands

# TODO: maybe incorporate the hunk info into something indexed by mode
#       and grey out 'u2:  hunk2'
const hunks = [ ' u: use hunk', 'u1: use hunk', 'u2:  hunk2  ' ]

# TODO: o, r, 1, 2 are not always valid, maybe grey when not valid
# TODO: other items might be subject to greying out,
# TODO: for example, diffs may not be valid in loupe mode.


#echo commands
#echo commands_marker

#
#       Each HUD section annotated: Splice Modes:, Layout:, Splice Commands:.
#
#       The vim9 implementation allows:
#               Layout:
#                  Original  XXX  Result
#
#               Layout:    Original
#                          One  Two
#                           Result
#               
#               Layout:
#                          XXXXXXXX
#                          YYYYYY
#       which reduces max width of HUD

var grid_diagram_0 =<< EOF
Original
One  Two
Result
EOF

var grid_diagram_1 =<< EOF

One Result Two

EOF


var grid_diagram_2 =<< EOF
One
Result
Two
EOF

# XXXXXXXX One,Two,Result,Original
var loupe_diagram_0 =<< END

XXXXXXXX

END

# XXXXXXXX is Original,One,Two
# YYYYYY is Result,One,Two
var compare_diagram_0 =<< END

XXXXXXXX YYYYYY

END

# XXXXXXXX is Original,One,Two
# YYYYYY is Result,One,Two
var compare_diagram_1 =<< END

XXXXXXXX
YYYYYY
END

# XXX is One,Two
var path_diagram_0 =<< END

Original XXX Result

END

var path_diagram_1 =<< END
Original
XXX
Result
END

# TODO: Don't need need extra level of nesting.
const diagrams_2: list<list<any>> = [
    [
        [ grid_diagram_0, ],
        [ grid_diagram_1, ],
        [ grid_diagram_2, ],
    ], [
        [ loupe_diagram_0, ],
    ], [
        [ compare_diagram_0, ],
        [ compare_diagram_1, ],
    ], [
        [ path_diagram_0, ],
        [ path_diagram_1, ],
    ]]

# each modes value:  dict of
#   m_line:     hud line, 1 based
#   m_col:      hud col, 0 based, of activate '*'
#   m_idx:      index into diagrams_2
#   m_nfile:    number of files for X,Y substitution
#   m_len:      chars on screen, "[g]rid" == 6
const modes = {
    grid:       { m_line: 2, m_col: 0,   m_idx: 0, m_nfile: 0, m_len: 6 },
    loupe:      { m_line: 3, m_col: 0,   m_idx: 1, m_nfile: 1, m_len: 7 },
    compare:    { m_line: 2, m_col: 10,  m_idx: 2, m_nfile: 2, m_len: 9 },
    path:       { m_line: 3, m_col: 10,  m_idx: 3, m_nfile: 1, m_len: 6 }
}

def FindMaxDiagramWidth()
    # find the width of the longest possible diagram string
    var n = 0
    for s in diagrams_2->flattennew(3)
        if len(s) > n
            n = len(s)
        endif
    endfor
    # "+ 2" for a little space around the longest line
    diagram_width = n + 2

    lockvar diagram_width
enddef


# 
# This list/method only used to populate actions,
# action_by_index corresponds to left/right, top/bottom
# presentation of the commands. The command_markers
# are used to determine the boundaries
#
# TODO: action_by_index needs to be dynamic.
# For example, 'u: use hunk' vs 'u1: use hunk 1'
#                               'u2: use hunk 2'
#
# and then there's the modes...
# 
var action_by_index = [
    'Diff',
    'Next',
    'Layout',
    'UseHunk',
    ##### 'UseHunk1',
    'Original',
    'One',
    'Quit',

    'DiffOff',
    'Previous',
    'Scroll',
    ##### 'UseHunk2',
    'Result',
    'Two',
    'Cancel',

#    'UseHunk',
#
#    'Grid',
#    'Loupe',
#    'Compare',
#    'Path',
    ]

# actions['Action'] = [line, start, end]. Action like 'Next'/'Quit'
# line/start/end is in buffer, starts at 1. end exclusive
def BuildActions()
    # action_by_index is the order the commands appear left to right,
    # top to bottom. And the order that items in command_markers are found.
    var cmds = copy(action_by_index)
    var t_actions: dict<list<number>>
    var start: number
    var line = 2
    for m in command_markers
        start = 0
        while true
            var result = matchstrpos(m,
                '\v(A+)|(B+)|(C+)|(D+)|(E+)|(F+)|(G+)', start)
            if result[1] == -1 | break | endif
            # Add one to make the column values 1 based.
            t_actions[cmds->remove(0)] = [ line,
                actions_offset + result[1] + 1,
                actions_offset + result[2] + 1]
            start = result[2]
        endwhile
        line += 1
    endfor

    # From modes add in the Grid, Loupe, ... actions
    for [ k, v ] in modes->items()
        # make key Grid, not grid, to correspond to command name
        var name = k[0]->toupper() .. k[1 : ]
        var [lino, col] = [ v.m_line, v.m_col ]
        # +1 makes it 1 based, +1 to skip activation position
        col += 2
        t_actions[name] = [ lino, col, col + v.m_len ]
    endfor

    actions = t_actions
    command_markers = null_list
    # TODO: null out action_by_index ?
    lockvar! actions
enddef

#
# Various textprops for the hud.
#

const prop_action = 'prop_action'
const prop_rollover = 'prop_rollover'
const prop_label = 'prop_label'
const prop_sep = 'prop_sep'
const prop_active = 'prop_active'

# NOTE: arg dict has bnr, assumed constant for duration
var did_action_props = false
def AddHeaderProps(d: dict<any> = null_dict)
    # Assuming bnr doesn't change
    if did_action_props | return | endif

    var props_com = {
        highlight: hl_command,
        priority: 100,
        combine: false,
        }
    var props_roll = {
        highlight: hl_rollover,
        priority: 110,
        combine: false,
        }
    var props_lab = {
        highlight: hl_label,
        priority: 100,
        combine: false,
        }
    var props_sep = {
        highlight: hl_sep,
        priority: 100,
        combine: false,
        }
    var props_act = {
        highlight: hl_active,
        priority: 100,
        combine: false,
        }
    props_com->extend(d)
    props_roll->extend(d)
    props_lab->extend(d)
    props_sep->extend(d)
    props_act->extend(d)

    prop_type_add(prop_action, props_com)
    prop_type_add(prop_rollover, props_roll)
    prop_type_add(prop_label, props_lab)
    prop_type_add(prop_sep, props_sep)
    prop_type_add(prop_active, props_act)

    did_action_props = true
enddef

# Add the action textprop to each command in HUD.
def HighlightActions(bnr: number)
    var props = {type: prop_action, bufnr: bnr, all: true}
    prop_remove(props)

    for [ line, start, end ] in actions->values()
        props.end_col = end
        prop_add(line, start, props)
    endfor
enddef

def HighlightMode(mode: string, bnr: number)
    var props = {type: prop_active, bufnr: bnr, all: true}
    prop_remove({type: prop_active, bufnr: bnr, all: true})
    var v = modes->get(mode)
    # increase length to include the '*'
    props.length = v.m_len + 1
    prop_add(v.m_line, v.m_col + 1, props)
enddef

# Labels and seperators. The labels are on the first line of the buffer
def HighlightLabels(bnr: number)
    var props = {type: prop_label, bufnr: bnr, all: true}
    prop_remove(props)

    props.length = len(label_modes)
    prop_add(1, 1, props)
    props.length = len(label_layout)
    prop_add(1, layout_offset + 1, props)
    props.length = len(label_commands)
    prop_add(1, actions_offset + 1, props)

    # and the separators
    props.type = prop_sep
    props.length = len(sepchar)
    prop_remove(props)
    setpos('.', [bnr, 1, 1, 0])
    while searchpos(sepchar, 'W') != [0, 0]
        var [ _, lino, col; x ] = getcurpos()
        prop_add(lino, col, props)
    endwhile
    setpos('.', [bnr, 1, 1, 0])
enddef


# return the diagram
def BuildDiagram(mode: string, layout: number,
        vari_files: list<string>): list<string>
    var num_vari_files =  modes->get(mode).m_nfile
    if len(vari_files) != num_vari_files
        throw 'Wrong number of file names for '
            .. mode .. ': ' .. string(vari_files)
    endif

    var diagram_data = diagrams_2[modes[mode].m_idx][layout]
    var diagram = diagram_data[0]->deepcopy()

    # substite X* Y* with vari_files
    if !!num_vari_files
        diagram->map((_, s) => {
            var t = substitute(s, '\v\CX+', vari_files[0], '')
            if num_vari_files == 2
                t = substitute(t, '\v\CY+', vari_files[1], '')
            endif
            return t
            })
    endif

    # get the width after subsitution
    diagram->Pad('c')
    var width = diagram[0]->len()

    # Shift a centered diagram right when it still fit in diagram_width.
    if width + 5 <= diagram_width
        diagram->Pad('c', diagram_width - 5)
        diagram->map((_, s) => '     ' .. s)
    else
        diagram->Pad('r', diagram_width)
    endif
        
    # overlay "Layout:" upper-left of the diagram
    diagram[0] = diagram[0]->Replace(0, len(label_layout) - 1, label_layout)
    return diagram
enddef

def BuildHud(mode: string, layout: number,
        vari_files: list<string>): list<string>
    var diagram = BuildDiagram(mode, layout, vari_files)
    var result = []
    var modes_dia = modes_diagram->deepcopy()
    var v = modes->get(mode)
    var [ active_line, active_col ] = [ v.m_line, v.m_col ]
    # get line 0 based
    active_line -= 1
    modes_dia[active_line] = modes_dia[active_line]
                \->Replace(active_col, active_col, '*')

    var j = 0
    while j < 3
        result->add(modes_dia[j] .. sep
            .. diagram[j] .. sep
            .. commands[j] ..  sep)
        j += 1
    endwhile
    return result
enddef

# An actions item.
var current_hud_rollover = null_list

# NOTE: if return needs to differentiate wrong window
#       then could return null vs []
# NOTE: <buffer> <LeftRelease> works, but <buffer> <MouseMove>
#        doesn't work, so must do bnr != hudbufnr

# Return null or item from actions dictionary
def GetHudItemUnderMouse(mpos: dict<number>): list<any>
    if winbufnr(mpos.winid) != hudbufnr
        return null_list
    endif

    var mpos_line = mpos.line
    var mpos_col = mpos.column

    # check if mouse in current rollover
    if current_hud_rollover != null
        var [ i_line, i_start, i_end ] = current_hud_rollover[1]
        if mpos_line == i_line && mpos_col >= i_start && mpos_col < i_end
            return current_hud_rollover
        endif
    endif

    # search for action containing mouse pos
    for item in actions->items()
        var [ i_line, i_start, i_end ] = item[1]
        if mpos_line == i_line && mpos_col >= i_start && mpos_col < i_end
            return item
        endif
    endfor
    return null_list
enddef

# Mouse button, look for command action.
def Release()
    var item = getmousepos()->GetHudItemUnderMouse()
    if item != null
        ExecuteCommand(item[0])
    else
        # Click in hud that's not a command. Forget last position
        ClearWinPos()
    endif
enddef

# Mouse move, handle command button rollover
def Move()
    var item = getmousepos()->GetHudItemUnderMouse()
    if current_hud_rollover != null
        if current_hud_rollover is item
            # echo 'cache hit:' item
            return
        else
            prop_remove({type: prop_rollover, bufnr: hudbufnr, all: true},
                current_hud_rollover[1][0])
            current_hud_rollover = null_list
        endif
    endif
    if item != null
        var [ line, start, end ] = item[1]
        prop_add(line, start,
            {end_col: end, type: prop_rollover, bufnr: hudbufnr, all: true})
        current_hud_rollover = item
    endif
enddef

# This is only for after replacing the hud lines with new hud lines
def RefreshMouseCache()
    current_hud_rollover = null_list
    Move()
enddef

#
# Main
#

var created_hud: list<number>

var hudbufnr: number = -1

def InitHudBuffer()
    &swapfile = false
    &modifiable = false
    &buflisted = false
    &buftype = 'nofile'
    &undofile = false
    &list = false
    &filetype = 'splice'
    &wrap = false
    resize 3
    &winfixheight = true
    wincmd =
enddef


# vari_files replace X+, Y+ in layout diagram
def InstallHUD(mode: string, layout: number, bnr: number,
        vari_files: list<string>)
    DoInit_1()

    InitHudBuffer()
    var hud = BuildHud(mode, layout, vari_files)

    #...

    # NOTE: set[buf]line looses text properties, so might as
    #       well rebuild the whole thing every time.
    #       TODO: And get rid of prop_delete when adding props.

    &modifiable = true
    deletebufline('', 1, '$')
    setline(1, hud)
    &modifiable = false

    hudbufnr = bnr
    DoInit_2(mode, bnr)
    RefreshMouseCache()
enddef

if testing
    def LogDrawHUD(mode: string, layout: number,
        vari_files: list<string>, bnr: number)
    enddef
else
    def LogDrawHUD(mode: string, layout: number,
        vari_files: list<string>, bnr: number)
        #Log(printf("DrawHUD: mode: '%s', layout %d, first '%s', second '%s', bnr %d",
        #        mode, layout, first ?? 'null', second ?? 'null', bufnr()))

        Log(printf("DrawHUD: mode: '%s', layout %d, vari_files %s, bnr %d",
            mode, layout, vari_files, bnr))
    enddef
endif

#
# This is invoked from python when the HUD is the current buffer
#
export def DrawHUD(use_vim: bool, mode: string, layout: number,
        ...vari_files: list<string>)
    var b = bufnr()
    LogDrawHUD(mode, layout, vari_files, b)
    if ! use_vim
        Log(printf("DrawHUD: not using vim"))
        return
    endif

    if hudbufnr >= 0 && hudbufnr != b
        throw 'HUD buffer mismatch'
    endif

    InstallHUD(mode, layout, bufnr(), vari_files)
enddef

export def AnyThing()
    Log('THIS IS FROM AnyThing IN HUD.VIM')
enddef

# The init_1 doesn't depend on hudbufnr
var did_init_1 = false
def DoInit_1()
    if did_init_1 | return | endif
    FindMaxDiagramWidth()

    layout_offset = modes_diagram[0]->len()  + sep->len()
    actions_offset = layout_offset + diagram_width + sep->len()
    lockvar layout_offset
    lockvar actions_offset

    BuildActions()

    did_init_1 = true
enddef

def DoInit_2(mode: string, bnr: number)
    AddHeaderProps({bufnr: bnr})
    HighlightActions(bnr)
    HighlightLabels(bnr)
    HighlightMode(mode, bnr)

    # only map click release in hud
    nnoremap <buffer><special> <LeftRelease> <ScriptCmd>Release()<CR>

    # Can not lock <MouseMove> to the buffer, because rollover moves
    # would not be detected when the vim focus is in a different buffer.
    nnoremap <special> <MouseMove> <ScriptCmd>Move()<CR>
enddef

if ! testing
    finish
endif

Log('TESTING, TESTING, 1 2 3 TESTING')


def CreateDebugHud(mode: string, layout: number, xxx: number,
        ...vari_files: list<string>): number
    # xxx is ignored, but same signature and InstallHUD

    #set co=200

    :1wincmd w
    new __Splice_HUD__
    wincmd J
    var n = bufnr()

    InitHudBuffer()
    var hud = BuildHud(mode, layout, vari_files)

    &modifiable = true
    deletebufline('', 1, '$')
    setline(1, hud)
    &modifiable = false

    DoInit_2(mode, n)
    hudbufnr = n

    # handy for debug on HUD
    nnoremap <buffer> q :q<CR>

    if created_hud->index(n) < 0
        created_hud->add(n)
    endif
    return n
enddef

var hud_idx = 0

var hud_cmds = [
    "CreateDebugHud('grid',    0, -1)",
    "CreateDebugHud('grid',    1, -1)",
    "CreateDebugHud('grid',    2, -1)",
    "CreateDebugHud('loupe',   0, -1, 'fn0')",
    "CreateDebugHud('loupe',   0, -1, 'Result')",
    "CreateDebugHud('compare', 0, -1, 'fn1', 'fn2')",
    "CreateDebugHud('compare', 1, -1, 'fn3', 'fn4')",
    "CreateDebugHud('compare', 0, -1, 'Original', 'Result')",
    "CreateDebugHud('compare', 1, -1, 'Original', 'Result')",
    "CreateDebugHud('path',    0, -1, 'fn5')",
    "CreateDebugHud('path',    1, -1, 'fn6')",
    ]

def NextHud(forw: bool = true)
    DoInit_1()

    if !forw
        hud_idx -= 2
        if hud_idx < 0 | hud_idx += len(hud_cmds) | endif
        echom 'hud_idx:' hud_idx
    endif
    var cmd: string
    cmd = hud_cmds[hud_idx]
    #cmd = "CreateDebugHud('path', 1, -1, 'fn1')"
    #cmd = "CreateDebugHud('compare', 0, -1, 'fn1', 'fn2')"
    execute cmd
    if len(created_hud) > 1
        echo 'created_hud MULTIPLE:' created_hud
    endif
    hud_idx += 1
    hud_idx %= len(hud_cmds)
enddef

command! -nargs=0 NN {
    win_gotoid(bufwinid(hudbufnr))
    :close
    NextHud()
    }

command! -nargs=0 BB {
    win_gotoid(bufwinid(hudbufnr))
    :close
    NextHud(false)
    }

defcompile

NextHud()

#DoInit_2(hudbufnr)

finish

vim9script noclear
NextHud()

vim9script noclear
def X()
    var winid = popup_create('Small Popup', {close: 'click'})
    echo winid
enddef

#vim9script noclear
def Y()
    var winid = popup_create('Small Popup move dismiss', {mousemoved: 'any'})
    echo winid
enddef

vim9script noclear
echo popup_hide(1002)

vim9script noclear
echo popup_close(1002)

vim9script noclear
echo popup_list()

vim9script noclear
X()
vim9script noclear
Y()

vim9script noclear
unmap <MouseMove>

vim9script noclear
unmap <LeftRelease>

################################################################################
var ruler0 = '0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16         '
var ruler  = '012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'

if false
    echo ruler0
    echo ruler
    DumpHud(6)

    echo 'layout_offset:' layout_offset  
    echo 'actions_offset:' actions_offset  

    # just the offset
    echo match(modes_diagram[1], '\v \[g\]')
    echo match(modes_diagram[1], '\v \[c\]')
    echo matchstrpos(modes_diagram[1], '\v \[g\]')
    echo matchstrpos(modes_diagram[1], '\v \[c\]')
    #echo searchpos(modes_diagram[1], '\v \[g\]')

    echo command_markers[0]
    echo ruler0
    echo ruler
endif
################################################################################

def DumpProps(props: list<dict<any>>)
    for d in props
        echo d
    endfor
enddef

vim9script noclear
echo ruler0
echo ruler
var cmd_props = prop_list(1, {bufnr: hudbufnr, end_lnum: -1, types: [prop_action]})
DumpProps(cmd_props)

