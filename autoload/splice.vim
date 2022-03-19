vim9script
# ============================================================================
# File:        splice.vim
# Description: vim global plugin for resolving three-way merge conflicts
# Maintainer:  Steve Losh <steve@stevelosh.com>
# License:     MIT X11
# ============================================================================

import autoload 'splicelib/util/keys.vim'
import autoload 'splicelib/util/log.vim'
import autoload 'splicelib/util/search.vim'
import autoload 'splicelib/util/vim_assist.vim'

var PutIfAbsent = vim_assist.PutIfAbsent

#export final UNIQ = []

# Some startup peculiarities
#       - The function "SpliceBoot" is caled only to load this file
#         and trigger script (not function) execution for initialization.
#       - during the initial script execution fatal errors may be found
#         and "finish" executed. Errors are recorded in a list, and 
#         the finish prevents most of this file from being executed.
#       - SpliceBoot gets control after the initial script execution,
#         typically from SpliceInit. If there are startup errors,
#         a popup is displayed with instructions to exit.
#         Otherwise the initialization code is executed.
#
# NOTE: if startup_error_msgs is not empty, there has been a fatal error

# assume the worst
var has_supported_python = 0
var splice_pyfile: string

var startup_error_msgs: list<string>

# user can enable/disable, specify log file
# default is no logging, ~/SPLICELOG
# NOTE: the log file is never trunctated, persists, grows without limit
var fname = g:->get('splice_log_file', $HOME .. '/SPLICE_LOG')
if g:->get('splice_log_enable', v:false)
    log.LogInit(fname)
endif

# First define functions that are used during boot.

export def RecordBootFailure(msgs: list<string>)
    # There no insert list at beginning so fiddle about
    var t = msgs
    t->extend(startup_error_msgs)
    startup_error_msgs = t
enddef

def SpliceDidNotLoad()
    var winid = popup_dialog(startup_error_msgs, {
        filter: 'popup_filter_yesno',
        callback: (_, v: number) => {
            if v == 0 | return | endif
            cq
            }
        })
enddef

def SpliceBootError()
    command! -nargs=0 SpliceInit SpliceDidNotLoad()
    var instrs =<< trim END

        Since the merge can not be completed, the merge
        should be aborted so it can be completed later.

        NOTE: the vim command ":cq" aborts the merge.

        Quit now and abort the merge: Yes/No

    END
    startup_error_msgs->extend(instrs)
    for msg in startup_error_msgs
        log.Log('ERROR: ' .. msg)
    endfor
    if has_supported_python != 0
        delcommand SplicePython
    endif
    SpliceDidNotLoad()
enddef

export def SpliceBoot()
    log.Log('SpliceBoot')
    # Check for startup errors.
    # If there are no errors then invoke SpliceInit9.
    if has_supported_python != 0 && startup_error_msgs->empty()
        command! -nargs=0 SpliceInit call splice.SpliceInit9()
        # use execute so this function can be compiled
        execute 'SpliceInit9()'
        return
    endif

    # A FATAL ERROR
    SpliceBootError()
enddef

# Now the boot/startup functions are defined,
# check if we've got a usable python.
# And it's ok to finish

if has('python3')
    has_supported_python = 3
    splice_pyfile = 'py3file'
    command! -nargs=1 SplicePython python3 <args>
elseif has('python')
    has_supported_python = 2
python << trim ENDPYTHON
    import sys, vim
    if sys.version_info[:2] < (2, 5):
        vim.command('has_supported_python = 0')
ENDPYTHON
    splice_pyfile = 'pyfile'
    command! -nargs=1 SplicePython python <args>
endif

if has_supported_python == 0
    startup_error_msgs += [ "Splice requires Vim to be compiled with Python 2.5+" ]
    finish
endif

#
# Examine stuff looking for problems.
# This is invoked just before SpliceInit
#
# These are typically not fatal errors.
# 

# NOTE: reuse startup_error_msgs

def UserConfigError(msg: list<string>)

    var contents =<< trim END
        Problem with vimrc Splice configuration

        Not a fatal problem. You can dismiss popup and
        continue with merge, or abort merge and retry later.
    END

    contents->extend(msg)
    contents->extend([ '', '(Click on popup to dismiss. Drag border.)' ])

    var winid = popup_create(contents, {
        minwidth: 20,
        tabpage: -1,
        zindex: 300,
        drag: 1,
        border: [],
        close: 'click',
        padding: [1, 2, 1, 2],
        })

    var bufnr = winbufnr(winid)
    #echo 'winid:' winid 'bufer:' bufnr
    #setbufline(bufnr, 2, "HOW COOL")
enddef

# Assume VAL already quoted by string() method.
var bad_var_template =<< trim END
    For 'GLOB', value 'VAL' not allowed.
        Must be OKVALS.
END

def BadVarMsg(glob: string, val: string, okvals: string): list<string>
    var s1 = bad_var_template[0]->substitute('\CGLOB', glob, '')
    s1 = s1->substitute('\CVAL', val, '')
    return [ '', s1, bad_var_template[1]->substitute('\COKVALS', okvals, '') ]
enddef

# ToString, call string() on arg, unless arg is string. Avoids extra '.
def TS(a: any): any
    if type(a) == v:t_string | return a | endif
    return string(a)
enddef

# return like: 'a', 'b', 'c'
def QuoteList(slist: list<any>): string
    return slist->mapnew((_, v) => string(v))->join(", ")
enddef

# Return null if ok, otherwise list for problem message.
#
# If a problem, the setting is assigned the default value.
#
# If the call wan't some additional message massaging, One way
# is to use the GetDefault() to put in a tag and edit it.
def CheckOneOfSetting(setting: string, ok: list<any>,
        GetDefault: func): bool
    #log.Log('checking: ' .. string(setting) .. " " .. string(ok) .. " " ..  string(GetDefault))
    var msg = []
    var val = g:->get(setting, null)
    if val != null && ok->index(val) == -1
        msg = BadVarMsg('g:' .. setting, TS(val),
            "one of " .. QuoteList(ok))
        if GetDefault != null
            var default = GetDefault()
            msg->add("    Using: " .. default)
            g:[setting] = default
        endif
        startup_error_msgs->extend(msg)
        return false
    endif
    return true
enddef

def CheckSettings()
    var rc: bool
    var check_info = [
        # [ 'splice_initial_XXX', [ 0, 1 ], () => 0 ]

        [ 'splice_initial_diff_grid',    [ 0, 1 ],          () => 0 ]
        [ 'splice_initial_diff_loupe',   [ 0 ],             () => 0 ]
        [ 'splice_initial_diff_compare', [ 0, 1 ],          () => 0 ]
        [ 'splice_initial_diff_path',    [ 0, 1, 2, 3, 4 ], () => 0 ]

        [ 'splice_initial_layout_grid',    [ 0, 1, 2 ], () => 0 ]
        [ 'splice_initial_layout_loupe',   [ 0 ],       () => 0 ]
        [ 'splice_initial_layout_compare', [ 0, 1 ],    () => 0 ]
        [ 'splice_initial_layout_path',    [ 0, 1 ],    () => 0 ]

        [ 'splice_initial_scrollbind_grid',    [ 0, 1, false, true ], () => false ]
        [ 'splice_initial_scrollbind_loupe',   [ 0, 1, false, true ], () => false ]
        [ 'splice_initial_scrollbind_compare', [ 0, 1, false, true ], () => false ]
        [ 'splice_initial_scrollbind_path',    [ 0, 1, false, true ], () => false ]

        [ 'splice_initial_mode', [ 'grid', 'loupe', 'compare', 'path' ],
            () => "'grid'" ]
        [ 'splice_wrap', [ 'wrap', 'nowrap' ],
            () => &wrap == false ? "'nowrap'" : "'wrap'" ]

        ]

    for [ setting, ok, f ] in check_info
        CheckOneOfSetting(setting, ok, f)
    endfor
enddef

def ReportStartupIssues()
    if startup_error_msgs != []
        UserConfigError(startup_error_msgs)
    endif
enddef

# Configuration variables


def InitDefaults()

    #
    # This seems to be redundant, and a POSSIBLE SOURCE OF BUGS,
    # because most of the code that gets settings provides a default
    # by doing get('key', default). So the defaults are set in two places
    # 
    # TODO: clean this up, either get rid of these defaults
    #       or get rid of where it provides defaults in the code.
    # NOTE: Just fixed a bug in boolsetting that may have contributed
    #       to pre-setting defaults
    #
    # Rather than put these defaults in vim global space,
    # may want to set up default in one place, then use a
    # separate dictionary just for python. Not worth the bother
    # since Splice *owns* vim when it runs, no problem polluting g:.
    #
    g:->PutIfAbsent('splice_disable',                    0)
    g:->PutIfAbsent('splice_initial_mode',               'grid')
    g:->PutIfAbsent('splice_initial_layout_grid',        0)
    g:->PutIfAbsent('splice_initial_layout_loupe',       0)
    g:->PutIfAbsent('splice_initial_layout_compare',     0)
    g:->PutIfAbsent('splice_initial_layout_path',        0)
    g:->PutIfAbsent('splice_initial_diff_grid',          0)
    g:->PutIfAbsent('splice_initial_diff_loupe',         0)
    g:->PutIfAbsent('splice_initial_diff_compare',       0)
    g:->PutIfAbsent('splice_initial_diff_path',          0)
    g:->PutIfAbsent('splice_initial_scrollbind_grid',    0)
    g:->PutIfAbsent('splice_initial_scrollbind_loupe',   0)
    g:->PutIfAbsent('splice_initial_scrollbind_compare', 0)
    g:->PutIfAbsent('splice_initial_scrollbind_path',    0)

    var t = exists('g:splice_leader') ? g:splice_leader : '-'
    g:->PutIfAbsent('splice_prefix', t)
enddef


def SetupSpliceCommands()
    command! -nargs=0 SpliceGrid     SplicePython SpliceGrid()
    command! -nargs=0 SpliceLoupe    SplicePython SpliceLoupe()
    command! -nargs=0 SpliceCompare  SplicePython SpliceCompare()
    command! -nargs=0 SplicePath     SplicePython SplicePath()

    command! -nargs=0 SpliceOriginal SplicePython SpliceOriginal()
    command! -nargs=0 SpliceOne      SplicePython SpliceOne()
    command! -nargs=0 SpliceTwo      SplicePython SpliceTwo()
    command! -nargs=0 SpliceResult   SplicePython SpliceResult()

    command! -nargs=0 SpliceDiff     SplicePython SpliceDiff()
    command! -nargs=0 SpliceDiffoff  SplicePython SpliceDiffoff()
    command! -nargs=0 SpliceScroll   SplicePython SpliceScroll()
    command! -nargs=0 SpliceLayout   SplicePython SpliceLayout()
    command! -nargs=0 SpliceNext     SplicePython SpliceNext()
    command! -nargs=0 SplicePrevious SplicePython SplicePrev()
    command! -nargs=0 SpliceUseHunk  SplicePython SpliceUse()
    command! -nargs=0 SpliceUseHunk1 SplicePython SpliceUse1()
    command! -nargs=0 SpliceUseHunk2 SplicePython SpliceUse2()

    command! -nargs=0 SpliceQuit keys.SpliceQuit()
    command! -nargs=0 SpliceCancel keys.SpliceCancel()

    # The ISxxx come in from python
    command! -nargs=0 ISpliceActivateGridBindings keys.ActivateGridBindings()
    command! -nargs=0 ISpliceDeactivateGridBindings keys.DeactivateGridBindings()
    command! -nargs=? ISpliceNextConflict search.MoveToConflict(<args>)
    command! -nargs=0 ISpliceAllConflict search.HighlightConflict()
enddef

export def SpliceInit9()
    log.Log('SpliceInit')
    # startup_error_msgs should already be empty
    startup_error_msgs = []
    InitDefaults()
    CheckSettings()
    var python_module = fnameescape(globpath(&runtimepath, 'autoload/splice.py'))
    exe splice_pyfile python_module
    SetupSpliceCommands()
    keys.InitializeBindings()
    ReportStartupIssues()
    log.Log('starting splice')
    SplicePython SpliceInit()
enddef

