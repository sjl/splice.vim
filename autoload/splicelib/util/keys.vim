vim9script

#
# This replaces keys.py.
#
# It is a higher level interface to the pythong code, no keys.bind,keys.unbind
# The python code also had keys.bind_for_all, keys.unbind_for_all
# but they are not used.
#
# The initialization of the bindings occurs before the first call to python
#       SpliceActivateGridBindings
#       SpliceDeactivateGridBindings
#

# set this to true and source this file for testing
var testing = false

#
# TODO: MOVE THIS TO SEPERATE FILE
#
# Logging
# user can enable/disable, specify log file
# default is no logging, ~/SPLICELOG
#
# NOTE: the log file is never trunctated, persists, grows without limit
#
var logging_enabled = g:->get('splice_log_enable', false)
var fname = g:->get('splice_log_file', $HOME .. '/SPLICE_LOG')

export def Log(line: string)
    if ! logging_enabled
        return
    endif
    writefile([ line ], fname, 'a')
enddef

var log_init = false
def LogInit()
    if ! logging_enabled || log_init
        return
    endif
    writefile([ '=== ' .. strftime('%c') .. ' ===' ], fname, "a")
    log_init = true
enddef

# Init the log, datetag, when this file is sourced
LogInit()

var defaultBindings = {
    Grid:     'g',
    Loupe:    'l',
    Compare:  'c',
    Path:     'p',

    Original: 'o',
    One:      '1',
    Two:      '2',
    Result:   'r',

    Diff:     'd',
    DiffOff:  'D',
    UseHunk:  'u',
    Scroll:   's',
    Layout:   '<space>',
    Next:     'n',
    Previous: 'N',

    Quit:     'q',
    Cancel:   'CC',

    UseHunk1: 'u1',
    UseHunk2: 'u2'
    }

# For uniformity, and to avoid special casing, provide Quit/Cancel commands
def SpliceQuit()
    :wa
    :qa
enddef
def SpliceCancel()
    :cq
enddef

# would like to return null, but string can't be null
def GetMapping(key: string): string
    var mapping = g:->get('splice_bind_' .. key, null)
    if mapping == 'None' || mapping == ''
        return ''
    endif
    if mapping == null
        mapping = g:->get('splice_prefix', '-')
            .. defaultBindings->get(key)
    endif
    return mapping
enddef

# If global setting, use that.
# Otherwise bind-map as usual
def Bind(key: string)
    var mapping = GetMapping(key)
    if mapping == ''
        Log('Bind-Map: SKIP ' .. key)
        return
    endif
    var t = ':Splice' .. key .. '<cr>'
    Log('Bind-Map: ' .. mapping .. ' -> ' .. t)
    execute 'nnoremap' mapping t
enddef

def UnBind(key: string)
    var mapping = GetMapping(key)
    if mapping == ''
        Log('Bind-UnMap: SKIP ' .. key)
        return
    endif
    Log('Bind-UnMap: ' .. mapping)
    execute 'unmap' mapping
enddef

# Initialize all bindings except for UseHunk1/UseHunk2

export def InitializeBindings()
    # The default state is UseHunk; UseHunk?(1|2) are dynamically handled,
    # see ActivateGridBindings, DeactivateGridBindings
    var initBindings = defaultBindings->keys()
    initBindings->filter((i, v) => v != 'UseHunk1' && v != 'UseHunk2')

    # setup the mappings
    for k in initBindings
        Bind(k)
    endfor

    # some commands defined in here
    command! -nargs=0 SpliceQuit SpliceQuit()
    command! -nargs=0 SpliceCancel SpliceCancel()
    command! -nargs=0 SpliceActivateGridBindings ActivateGridBindings()
    command! -nargs=0 SpliceDeactivateGridBindings DeactivateGridBindings()
enddef

export def ActivateGridBindings()
    Log('ActivateGridBindings')
    UnBind('UseHunk')
    Bind('UseHunk1')
    Bind('UseHunk2')
enddef

export def DeactivateGridBindings()
    Log('DectivateGridBindings')
    UnBind('UseHunk1')
    UnBind('UseHunk2')
    Bind('UseHunk')
enddef

if testing
    Log('INIT')
    InitializeBindings()
    Log('ACTIVATE-GRID')
    ActivateGridBindings()
    Log('DE-ACTIVATE-GRID')
    DeactivateGridBindings()
endif

