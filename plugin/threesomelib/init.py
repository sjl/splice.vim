import modes
from util import buffers, keys, windows


CONFLICT_MARKER_START = '<<<<<<<'
CONFLICT_MARKER_MARK = '======='
CONFLICT_MARKER_END = '>>>>>>>'

def process_result():
    windows.close_all()
    buffers.result.open()

    lines = []
    in_conflict = False
    for line in buffers.result.lines:
        if in_conflict:
            if CONFLICT_MARKER_MARK in line:
                lines.append(line)
            if CONFLICT_MARKER_END in line:
                in_conflict = False
            continue

        if CONFLICT_MARKER_START in line:
            in_conflict = True
            continue

        lines.append(line)

    buffers.result.set_lines(lines)

def bind_global_keys():
    keys.bind('g', ':ThreesomeGrid<cr>')
    keys.bind('l', ':ThreesomeLoupe<cr>')

    keys.bind('o', ':ThreesomeOriginal<cr>')
    keys.bind('1', ':ThreesomeOne<cr>')
    keys.bind('2', ':ThreesomeTwo<cr>')
    keys.bind('r', ':ThreesomeResult<cr>')

    keys.bind('d', ':ThreesomeDiff<cr>')

def init():
    process_result()
    bind_global_keys()
    modes.current_mode = modes.grid
    modes.current_mode.activate()


