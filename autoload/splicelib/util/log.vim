vim9script

import autoload './vim_assist.vim'
import autoload '../../splice.vim'

# export Log, LogInit

#
# Logging
#
# LogInit(fname) - enables logging, if first call output time stamp
# Log(string) - append string to Log if logging enabled
#
# NOTE: the log file is never trunctated, persists, grows without limit
#

#
# global for simple access from python
# TODO: AddExclude/AddInclude methods then these can forward to python
#       and won't need global
#
g:splice_logging_exclude = [ 'focus' ]

var fname: string
var logging_enabled: bool = false
#
# Invoked as either Log(msg) or Log(category, msg).
# Check to see if category should be logged.
#
export def Log(arg1: string, arg2: string = null_string)
    if ! logging_enabled
        return
    endif
    # typical case one arg; arg1 is msg
    var msg = arg1
    var category: string = null_string
    if arg2 != null
        category = arg1
        msg = arg2
    endif

    writefile([ msg ], fname, 'a')
enddef

var log_init = false
export def LogInit(_fname: string)
    if !log_init
        fname = _fname
        logging_enabled = true
        writefile([ '', '', '=== ' .. strftime('%c') .. ' ===' ], fname, "a")
        log_init = true
    endif
enddef

const E = {
    ENOTFILE: ["Current buffer, '%s', doesn't support '%s'", 'Command Issue'],
}

def FilterFalse(winid: number, key: string): bool
    return false
enddef

def PopupError(msg: list<string>, other: list<any> = [])

    var options = {
        minwidth: 20,
        tabpage: -1,
        zindex: 300,
        border: [],
        padding: [1, 2, 1, 2],
        highlight: splice.hl_alert_popup,
        close: 'click',
        mousemoved: 'any', moved: 'any',
        mapping: false, filter: FilterFalse
        }
    if len(other) > 0
        options.title = ' ' .. other[0] .. ' '
    endif

    popup_create(msg, options)
enddef


export def SplicePopup(e_idx: string, ...extra: list<any>)
    var err = E[e_idx]
    var msg = call('printf', [ err[0] ] + extra)
    Log(msg)
    PopupError([msg], err[ 1 : ])
enddef

#defcompile
