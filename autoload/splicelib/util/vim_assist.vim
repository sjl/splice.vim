vim9script

# 8.2.4589 can now do g:[key] = val
export def Set(d: dict<any>, k: string, v: any)
    d[k] = v
enddef

export def PutIfAbsent(d: dict<any>, k: string, v: any)
    if ! d->has_key(k)
        d[k] = v
    endif
enddef

