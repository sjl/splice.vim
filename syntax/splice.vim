let b:current_syntax = 'splice'

syn match SpliceModes '\v^[^|]+'
syn match SpliceLayout '\v\|[^\|]+\|'
syn match SpliceCommands '\v[^\|]+\|$'
syn match SpliceHeading '\v(Splice Modes|Splice Commands|Layout -\>)' contained containedin=SpliceModes,SpliceLayout,SpliceCommands
syn match SpliceSep '\v\|' contained containedin=SpliceLayout,SpliceCommands
syn match SpliceCurrentMode '\v\*\S+' contained containedin=SpliceModes

hi def link SpliceSep Comment
hi def link SpliceHeading Comment
hi def link SpliceModes Normal
hi def link SpliceCurrentMode Keyword
