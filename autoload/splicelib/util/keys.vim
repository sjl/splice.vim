vim9script

# set 'testing' to true and source this file for testing
var testing = false

if ! testing
    import autoload 'splicelib/util/log.vim'
else
    import './log.vim'
    log.LogInit($HOME .. '/play/SPLICE_LOG')
    log.Log('=== ' .. strftime('%c') .. ' ===')
    log.Log('=== Unit Testing ===')
endif

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
export def SpliceQuit()
    :wa
    :qa
enddef
export def SpliceCancel()
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
        log.Log("Bind-Map: SKIP '" .. key .. "'")
        return
    endif
    var t = ':Splice' .. key .. '<cr>'
    log.Log("Bind-Map: '" .. mapping .. "' -> '" .. t .. "'")
    execute 'nnoremap' mapping t
enddef

def UnBind(key: string)
    var mapping = GetMapping(key)
    if mapping == ''
        log.Log("Bind-UnMap: SKIP '" .. key .. "'")
        return
    endif
    log.Log("Bind-UnMap: '" .. mapping .. "'")
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
enddef

export def ActivateGridBindings()
    log.Log('ActivateGridBindings')
    UnBind('UseHunk')
    Bind('UseHunk1')
    Bind('UseHunk2')
enddef

export def DeactivateGridBindings()
    log.Log('DectivateGridBindings')
    UnBind('UseHunk1')
    UnBind('UseHunk2')
    Bind('UseHunk')
enddef

if testing
    log.Log('INIT')
    InitializeBindings()
    log.Log('ACTIVATE-GRID')
    ActivateGridBindings()
    log.Log('DE-ACTIVATE-GRID')
    DeactivateGridBindings()
endif

