vim9script

# export Set, PutIfAbsent, Keys2str,
# Pad, PropRemoveIds
# FindInList, FetchFromList
# EQ, IS
# Replace, ReplaceBuf
# ##### HexString

# just use echo 
#export def HexString(in: string, space: bool = false, quot: bool = false): string
#    var out: string
#    for c in str2list(in)
#        if space
#            if out != '' | out ..= ' ' | endif
#        endif
#        out ..= printf('%2x', c)
#    endfor
#    return quot ? "'" .. out .. "'" : out
#enddef

# Remove the common key/val from each dict.
# Note: the dicts are modified
def DictUnique(d1: dict<any>, d2: dict<any>)
    # TODO: use items() from the smallest dict
    for [k2, v2] in d2->items()
        if d1->has_key(k2) && d1[k2] == d2[k2]
            d1->remove(k2)
            d2-> remove(k2)
        endif
    endfor
enddef

# return list of dicts with unique elements,
# returned dicts start as shallow copies
def DictUniqueCopy(d1: dict<any>, d2: dict<any>): list<dict<any>>
    var d1_copy = d1->copy()
    var d2_copy = d2->copy()
    DictUnique(d1_copy, d2_copy)
    return [ d1_copy, d2_copy ]
enddef

export def Replace(s: string,
        pos1: number, pos2: number, newtext: string): string
    return pos1 != 0
        ? s[ : pos1 - 1] .. newtext .. s[pos2 + 1 : ]
        : newtext .. s[pos2 + 1 : ]
enddef

# NOTE: setbufline looses text properties.
export def ReplaceBuf(bnr: number, lino: number,
        pos1: number, pos2: number, newtext: string)
    getbufline(bnr, lino)[0]
        ->Replace(pos1, pos2, newtext)->setbufline(bnr, lino)
enddef

# https://github.com/vim/vim/issues/10022
export def EQ(lhs: any, rhs: any): bool
    return type(lhs) == type(rhs) && lhs == rhs
enddef
export def IS(lhs: any, rhs: any): bool
    return type(lhs) == type(rhs) && lhs is rhs
enddef

# FindInList: find target in list using '==', return false if not found
# Each target found is identified by a list of indexes into the search list,
# and that is added to path (if path is provided).
export def FindInList(target: any, l: list<any>, path: list<list<number>> = null_list): bool
    var path_so_far: list<number> = []
    var found = false
    def FindInternal(lin: list<any>)
        var i = 0
        var this_one: any
        while i < len(lin)
            this_one = lin[i]
            if EQ(this_one, target)
                if path != null
                    path->add(path_so_far + [i])
                endif
                found = true
            elseif type(this_one) == v:t_list
                path_so_far->add(i)
                FindInternal(this_one)
                path_so_far->remove(-1)
            endif
            i += 1
        endwhile
    enddef
    if EQ(l, target)
        path->add([])
        return true
    endif
    FindInternal(l)
    return found
enddef

export def FetchFromList(path: list<number>, l: list<any>): any
    var result: any = l
    for idx in path
        result = result[idx]
    endfor
    return result
enddef

# flattennew fixed #10012
# I think this preserves items that are brought up to the top level,
# so that "is" comparison return true
# https://github.com/vim/vim/issues/10012
def Flatten(l: list<any>, maxdepth: number = 999999): list<any>
    function FlattenInternal(il, id)
        return flatten(a:il,a:id)
    endfu
    return FlattenInternal(copy(l), maxdepth)
enddef

# flattennew fixed #10012
# builtin flatten,flattennew: a mess
# https://github.com/vim/vim/issues/10020
# Not Needed 10020 fixed, use Flatten.
# Keep it around just in case
def FlattenVim9(l: list<any>, maxdepth: number = 999999): list<any>
    var result = []
    def FInternal(l2: list<any>, curdepth: number)
        var i = 0
        while i < len(l2)
            if type(l2[i]) == v:t_list && curdepth < maxdepth
                FInternal(l2[i], curdepth + 1)
            else
                result->add(l2[i])
            endif
            i += 1
        endwhile
    enddef
    FInternal(l, 0)
    return result
enddef

# 8.2.4589 can now do g:[key] = val
export def Set(d: dict<any>, k: string, v: any)
    d[k] = v
enddef

export def PutIfAbsent(d: dict<any>, k: string, v: any)
    if ! d->has_key(k)
        d[k] = v
    endif
enddef

# not correctly implememnted, if it should be...
#export def DeleteHighlightType(type: string, d: dict<any> = null_dict)
#    prop_remove({type: prop_command, bufnr: hudbufnr, all: true})
#enddef

export def PropRemoveIds(ids: list<number>, d: dict<any> = null_dict)
    var props: dict<any> = { all: true }
    props->extend(d)
    ids->filter( (_, v) => {
        props['id'] = v
        prop_remove(props)
        return false
        })
enddef

#
# if a character is > 0xff, this will probably fail
# There's experiment/vim/Keys2Str.vim with tests to play
#
def StripCtrlV(k: string): list<number>
    var result: list<number>
    var i = 0
    var l = str2list(k)
    while i < len(l)
        var n = l[i]
        if false
            var c = k[i]
            var l = str2list(c)
            echo 'c: ' c 'list:' l 'hex:' printf("%x", l[0])
                        \'n:' n 'char:' nr2char(l[0])
        endif
        if n == 0x16
            # Skip ^v. If it's the last char, then keep it
            if i + 1 < len(l)
                i += 1
                n = l[i]
            endif
        endif
        result->add(n)
        i += 1
    endwhile
    return result
enddef

export def Keys2Str(k: string): string
    def OneChar(x: number): string
        if x == 0x20
            return '<Space>'
        elseif x == char2nr('^')
            return '\^'
        elseif x == char2nr('\')
            return '\\'
        elseif x < 0x20
            return '^' .. nr2char(x + 0x40)
        endif
        return nr2char(x)
    enddef

    var result: string
    var l = StripCtrlV(k)
    for n in l
        if n < 0x80
            result = result .. OneChar(n)
        else
            result = result .. '<M-' .. OneChar(n - 0x80) .. '>'
        endif
    endfor
    return result
enddef

#export def MaxW(l: list<string>): number
#    return max(l->mapnew((_, v) => len(v)))
#enddef

# The list is transformed, do a copy first if you want the original
# a - alignment (first char), 'l' - left (default), 'r' - right, 'c' - center
# w - width, default 0 means width of longest string
# ret_off - only centering, if not null, the calculated offsets returned
# can be used with chaining
export def Pad(l: list<string>, a: string = 'l',
        _w: number = 0,
        ret_off: list<number> = null_list): list<string>
    # TODO: only need one map statement, could conditionalize calculation
    var w = !!_w ? _w : max(l->mapnew((_, v) => len(v)))
    if a[0] != 'c'
        var justify = a[0] == 'r' ? '' : '-'
        return l->map((_, v) => printf("%" .. justify .. w .. "s", v))
    else
        return l->map((_, v) => {
            if len(v) > w
                throw "Pad: string '" .. v .. "' larger that width '" .. w .. "' "
            endif
            var _w1 = (w - len(v)) / 2
            var _w2 = w - len(v) - _w1
            if ret_off != null | ret_off->add(_w1) | endif
            #like: printf("%-15s%5s", str, '')
            return printf("%" .. (_w1 + len(v)) .. "s%" .. _w2 .. "s", v, '')
            })
    endif
enddef
#for l1 in Pad(['x', 'dd', 'sss', 'eeee', 'fffff', 'gggggg'], 'c', 12)
#    echo l1
#endfor
#for l1 in Pad(['x', 'dd', 'sss', 'eeee', 'fffff', 'gggggg', 'ccccccc'], 'c', 12)
#    echo l1
#endfor
#finish

