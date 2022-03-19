vim9script

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

