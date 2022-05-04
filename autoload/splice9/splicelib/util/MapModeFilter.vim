vim9script
if !has("patch-8.2.4861")
    finish
endif
const debug_test = false

#
# MapModeFilter(modes, pattern, exact = true, field = lhs)
# MapModeFilterFunc(modes, filter_func)
#
# Return mappings used in "modes" that match a pattern.
# Used with outlist()->filter() to return mappings involving argument "modes".
#       - "modes" one or more modes of interest.
#       - "pattern" matched against a field in the mapping-dict
#       - "exact" true means use '==', otherwise '=~',
#         for checking if mapping's "field" matches. Default is 'true'
#       - "field" from mapping-dict to match against defaults to 'lhs'.
#       - "filter_func" takes a mapping-dict as an arugment, returns
#         true if that mapping should be checked for matching modes.
# An exception is thrown if modes contains an unkown/illegal mode.
#
# examples: 
#   Any mapping of 'K' used in '!' or ' ' modes
#   (this is all modes except 'l' and 't')
#       saved_maps = maplist()->filter(MapModeFilter('! ', 'K'))
#   Any mapping of 'K' used in 's' or 'c' modes
#       saved_maps = maplist()->filter(MapModeFilter('sc', 'K'))
#   Mappings that have "MultiMatch" in rhs (command), in "n" mode.
#       saved_maps = maplist()->filter(MapModeFilter(
#                                     'n', 'MultiMatch', false, 'rhs'))
#   Mappings of 'K' and rhs has "MultiMatch", in "n" modes.
#       saved_maps = maplist()->filter(MapModeFilterFunc(
#                       'n', (m) => m.lhs == 'K' && m.rhs =~ 'MultiMatch'))
#
# A MapModeFilter can also be used with a for loop
#       var filt = MapModeFilter('sc', 'K')
#       for m in maplist()
#           if filt(0, m)
#               # do stuff
#           endif
#       endfor
#
# TODO: Perf optim when a particlar map list is re-used,
#       as for running different filters on the same list,
#       save the calculated map_modes bits in the list's dicts
# TODO: Throw an error when modes argument is illegal,
#       rather than depend on
#               Error detected while processing :source buffer=1[256]
#                       ..function <SNR>37_CheckMaps[2]
#                       ..<SNR>37_MapModeFilter: line    4:
#               E716: Key not present in Dictionary: "z"
#               

# use the "C" defines. Might help to see what's going on
const NORMAL       = 0x01
const VISUAL	   = 0x02
const OP_PENDING   = 0x04
const CMDLINE	   = 0x08
const INSERT	   = 0x10
const LANGMAP	   = 0x20
const SELECTMODE   = 0x1000
const TERMINAL     = 0x2000

const mode_bits_table = {
    ' ': NORMAL + VISUAL + SELECTMODE + OP_PENDING,
    'v': VISUAL + SELECTMODE,
    '!': INSERT + CMDLINE,

    'n': NORMAL,
    'x': VISUAL,
    's': SELECTMODE,
    'o': OP_PENDING,
    'i': INSERT,
    'c': CMDLINE,
    't': TERMINAL,
    'l': LANGMAP,
    }

var DumpModeStringInfo: func

# Note in the returned function there is
#           for mm in m.mode
#               map_modes += mode_bits_table[mm]
#           endfor
# This assumes that the mapping-dict field mode
# is well formed and does not have the same base mode twice.
# If it did, "or" would have to be used instead of "+" as in
#               map_modes = or(map_modes, mode_bits_table[mm])
#
# If there were a mode_bits field in mapping-dict, could get rid
# of the loop entirely. The lambda becomes:
#           if m[field] != pattern | return false | endif
#           return and(m.mode_bits, target_modes) != 0
#       

export def MapModeFilter(_modes: string, pattern: string,
               exact: bool = true, field: string = 'lhs'): func
    var modes =  _modes ?? ' '
    var target_modes = 0
    for t in modes
        target_modes = or(target_modes, mode_bits_table[t])
    endfor
    #DumpModeStringInfo('target_modes', modes)

    # Squeeze every little bit out of the returned function (inner loop),
    # so hoist exact out of the function and return one of two lambdas.
    if exact
        return (_, m) => {
            if m[field] != pattern | return false | endif
            var map_modes = 0
            for mm in m.mode
                #map_modes = or(map_modes, mode_bits_table[mm])
                map_modes += mode_bits_table[mm]
            endfor

            #DumpModeStringInfo('map_modes', m.mode)
            return and(map_modes, target_modes) != 0
            #return and(m.mode_bits, target_modes) != 0
            }
    else
        return (_, m) => {
            if m[field] !~ pattern | return false | endif
            var map_modes = 0
            for mm in m.mode
                #map_modes = or(map_modes, mode_bits_table[mm])
                map_modes += mode_bits_table[mm]
            endfor

            #DumpModeStringInfo('map_modes', m.mode)
            return and(map_modes, target_modes) != 0
            #return and(m.mode_bits, target_modes) != 0
            }
    endif
enddef

export def MapModeFilterFunc(_modes: string, PreFilter: func): func
    var modes =  _modes ?? ' '
    var target_modes = 0
    for t in modes
        target_modes = or(target_modes, mode_bits_table[t])
    endfor
    #DumpModeStringInfo('target_modes', modes)

    return (_, m) => {
        if !PreFilter(m) | return false | endif
        var map_modes = 0
        for mm in m.mode
            #map_modes = or(map_modes, mode_bits_table[mm])
            map_modes += mode_bits_table[mm]
        endfor

        #DumpModeStringInfo('map_modes', m.mode)
        return and(map_modes, target_modes) != 0
        #return and(m.mode_bits, target_modes) != 0
        }
enddef

if !debug_test
    finish
endif

##########################
# Following is for testing


# The three composite chars must be first
# and ' ' must come before 'v'
var mode_chars = ' v!nxsoictl'

def Bits2Ascii(_bits: number): string
    var bits = _bits
    var result: string

    # Note: the big guys are checked first     
    for mode_char in mode_chars
        if bits == 0 | break | endif
        var mode_bits = mode_bits_table[mode_char]
        if and(bits, mode_bits) == mode_bits
            result ..= mode_char
            bits = and(bits, invert(mode_bits))
        endif
    endfor
    return result
enddef

def Mode2Bits(modes: string): number
    var target_modes = 0
    for t in modes
        target_modes = or(target_modes, mode_bits_table[t])
    endfor
    return target_modes
enddef

def Dprintf(...l: list<any>)
    echo call('printf', l)
enddef

def DumpModeStringInfoReal(tag: string, mstring: string)
    var mode_bits = 0
    for t in mstring
        mode_bits = or(mode_bits, mode_bits_table[t])
    endfor
    Dprintf("%12s: %8s --> '%016b'    '%s'", tag,
                printf("'%s'", mstring),
                mode_bits, Bits2Ascii(mode_bits))
enddef

DumpModeStringInfo = DumpModeStringInfoReal

var lhs = 'ZX'

# def FilterLhs(m: dict<any>): bool
#     return m.lhs == 'ZX'
# enddef
# var FF = (m: dict<any>) => m.lhs == 'ZX'
# defcompile
# #execute 'disassemble' matchlist(printf("%s", FF), '\v''(.*)''')[1]
# #var F = MapModeFilterFunc('c', FF)
#var F = MapModeFilter('c', lhs)
## grab name from something like: "function('<lamda>99')"
#var funcid = matchlist(printf("%s", F), '\v''(.*)''')[1]
#execute 'disassemble' funcid
#finish

def CheckResults(find_modes: string, expected: list<string>, result: list<string>)
    # enable this to see results of each test
    #echo printf("result find modes: '%s' mappings: %s", find_modes, result)

    var expected_bits = expected->mapnew((_, s) => Mode2Bits(s))->sort()
    var result_bits = result->mapnew((_, s) => Mode2Bits(s))->sort()
    ### echo result_bits->mapnew((_, b) => printf("%016b", b))
    ### echo expected_bits result_bits     
    if expected_bits != result_bits
        echo printf("result find modes: '%s' mappings: %s", find_modes, result)
        #echo printf('    ERROR: expect: %s, got %s', expected_bits, result_bits)
        echo printf('    ERROR: expect: %s, got %s', expected->sort(), result->sort())
    endif
enddef

var count_tests = 0

def CheckMapsLhs(find_modes: string, expected: list<string>,
        pattern: string): list<string>
    count_tests += 1
    var save_mappings = maplist()
        ->filter(MapModeFilter(find_modes, pattern))
    var result = save_mappings->mapnew((_, m) => m.mode)

    CheckResults(find_modes, expected, result)

    return result
enddef

def CheckMapsFunc(find_modes: string, expected: list<string>,
        Func: func): list<string>
    count_tests += 1
    var save_mappings = maplist()
        ->filter(MapModeFilterFunc(find_modes, Func))
    var result = save_mappings->mapnew((_, m) => m.mode)

    CheckResults(find_modes, expected, result)

    return result
enddef

def CheckMapsOptions(find_modes: string, expected: list<string>,
        pattern: string, exact: bool = true, field: string = 'lhs'
        ): list<string>
    count_tests += 1
    var save_mappings = maplist()
        ->filter(MapModeFilter(find_modes, pattern, exact, field))
    var result = save_mappings->mapnew((_, m) => m.mode)

    CheckResults(find_modes, expected, result)

    return result
enddef

### def CheckMapsOptions(find_modes: string, expected: list<string>): list<string>
###     count_tests += 1
###     var save_mappings = maplist()
###         ->filter(MapModeFilter(find_modes, lhs))
###         # ->filter(MapModeFilterFunc(find_modes, (m) => m.lhs == lhs))
###     var result = save_mappings->mapnew((_, m) => m.mode)
### 
###     CheckResults(find_modes, expected, result)
### 
###     return result
### enddef

const unmap_cmds = [ 'unmap', 'unmap!', 'tunmap', 'lunmap' ]
def UnmapAny(_lhs: string)
    for cmd in unmap_cmds
        try | execute(cmd .. ' ' .. _lhs) | catch /E31/ | endtry
    endfor
enddef

def AllModes(): list<string>
    return maplist()->filter((_, m) => m.lhs =~ '\C^' .. lhs .. '$')
                                                ->mapnew((_, m) => m.mode)
enddef


# n,x,s,o

map ZX xyzzy
vmap ZX xyzzy
map! ZX xyzzy
lmap ZX zzz
# starting with ['v', 'no', 'l', '!']

echo printf("TESTING: starting mappings for %s have modes: %s", lhs, AllModes())
echo ' '
echo printf("TEST: MapModeFilter(various_modes, %s)", string(lhs))
count_tests = 0
CheckMapsLhs(' ',   ['v', 'no'], lhs)
CheckMapsLhs('x',   ['v'],       lhs)
CheckMapsLhs('c',   ['!'],       lhs)
CheckMapsLhs('l',   ['l'],       lhs)
CheckMapsLhs('t',   [],          lhs)
CheckMapsLhs('li',  ['l', '!'],  lhs)
CheckMapsLhs('lt',  ['l'],       lhs)
CheckMapsLhs('x',   ['v'],       lhs)
CheckMapsLhs('s',   ['v'],       lhs)
CheckMapsLhs('o',   ['no'],      lhs)
CheckMapsLhs('v',   ['v'],       lhs)
CheckMapsLhs(' ',   ['v', 'no'], lhs)
CheckMapsLhs('n',   ['no'],      lhs)
CheckMapsLhs('i',   ['!'],       lhs)
CheckMapsLhs('sxn', ['v', 'no'], lhs)
CheckMapsLhs(' !lt', ['!', 'v', 'no', 'l'], lhs)
echo printf("         %d tests executed", count_tests)

echo ' '
echo printf("TEST: MapModeFilterFunc(various_modes, (m) => m.lhs == %s, )", string(lhs))
count_tests = 0
var LhsFunc = (m) => m.lhs == lhs
CheckMapsFunc(' ',   ['v', 'no'], LhsFunc)
CheckMapsFunc('x',   ['v'],       LhsFunc)
CheckMapsFunc('c',   ['!'],       LhsFunc)
CheckMapsFunc('l',   ['l'],       LhsFunc)
CheckMapsFunc('t',   [],          LhsFunc)
CheckMapsFunc('li',  ['l', '!'],  LhsFunc)
CheckMapsFunc('lt',  ['l'],       LhsFunc)
CheckMapsFunc('x',   ['v'],       LhsFunc)
CheckMapsFunc('s',   ['v'],       LhsFunc)
CheckMapsFunc('o',   ['no'],      LhsFunc)
CheckMapsFunc('v',   ['v'],       LhsFunc)
CheckMapsFunc(' ',   ['v', 'no'], LhsFunc)
CheckMapsFunc('n',   ['no'],      LhsFunc)
CheckMapsFunc('i',   ['!'],       LhsFunc)
CheckMapsFunc('sxn', ['v', 'no'], LhsFunc)
CheckMapsFunc(' !lt', ['!', 'v', 'no', 'l'], LhsFunc)
echo printf("         %d tests executed", count_tests)

echo ' '
var exact_lhs = '^' .. lhs .. '$'
echo printf("TEST: MapModeFilter(various_modes, %s, false)", string(exact_lhs))
count_tests = 0
CheckMapsOptions(' ',   ['v', 'no'], exact_lhs, false)
CheckMapsOptions('x',   ['v'],       exact_lhs, false)
CheckMapsOptions('c',   ['!'],       exact_lhs, false)
CheckMapsOptions('l',   ['l'],       exact_lhs, false)
CheckMapsOptions('t',   [],          exact_lhs, false)
CheckMapsOptions('li',  ['l', '!'],  exact_lhs, false)
CheckMapsOptions('lt',  ['l'],       exact_lhs, false)
CheckMapsOptions('x',   ['v'],       exact_lhs, false)
CheckMapsOptions('s',   ['v'],       exact_lhs, false)
CheckMapsOptions('o',   ['no'],      exact_lhs, false)
CheckMapsOptions('v',   ['v'],       exact_lhs, false)
CheckMapsOptions(' ',   ['v', 'no'], exact_lhs, false)
CheckMapsOptions('n',   ['no'],      exact_lhs, false)
CheckMapsOptions('i',   ['!'],       exact_lhs, false)
CheckMapsOptions('sxn', ['v', 'no'], exact_lhs, false)
CheckMapsOptions(' !lt', ['!', 'v', 'no', 'l'], exact_lhs, false)
echo printf("         %d tests executed", count_tests)

echo ' '
var rhs_pat = 'xyzzy'
echo printf("TEST: MapModeFilter(various_modes, %s, v:none, 'rhs')", string(rhs_pat))
count_tests = 0
CheckMapsOptions(' ',   ['v', 'no'], rhs_pat, v:none, 'rhs')
CheckMapsOptions('x',   ['v'],       rhs_pat, v:none, 'rhs')
CheckMapsOptions('c',   ['!'],       rhs_pat, v:none, 'rhs')
CheckMapsOptions('l',   [],          rhs_pat, v:none, 'rhs')
CheckMapsOptions('t',   [],          rhs_pat, v:none, 'rhs')
CheckMapsOptions('li',  ['!'],       rhs_pat, v:none, 'rhs')
CheckMapsOptions('lt',  [],          rhs_pat, v:none, 'rhs')
CheckMapsOptions('x',   ['v'],       rhs_pat, v:none, 'rhs')
CheckMapsOptions('s',   ['v'],       rhs_pat, v:none, 'rhs')
CheckMapsOptions('o',   ['no'],      rhs_pat, v:none, 'rhs')
CheckMapsOptions('v',   ['v'],       rhs_pat, v:none, 'rhs')
CheckMapsOptions(' ',   ['v', 'no'], rhs_pat, v:none, 'rhs')
CheckMapsOptions('n',   ['no'],      rhs_pat, v:none, 'rhs')
CheckMapsOptions('i',   ['!'],       rhs_pat, v:none, 'rhs')
CheckMapsOptions('sxn', ['v', 'no'], rhs_pat, v:none, 'rhs')
CheckMapsOptions(' !lt', ['!', 'v', 'no'], rhs_pat, v:none, 'rhs')
echo printf("         %d tests executed", count_tests)

UnmapAny(lhs)

echo ' '
echo 'TEST: exception if invalid mode'
var got_exception = false
try
    CheckMapsLhs('z', [], lhs)
catch /.*/
    got_exception = true
endtry

if ! got_exception
    echo "ERROR: expected exception: MapModeFilter('z', 'ZX')"
endif
echo ' '

#nmap ZX xz
#xmap ZX xy
#smap ZX xw

finish
