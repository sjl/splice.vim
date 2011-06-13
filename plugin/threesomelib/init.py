import vim
from modes import Grid
from util import windows
from util.buffers import buffers


CONFLICT_MARKER_START = '<<<<<<<'
CONFLICT_MARKER_MARK = '======='
CONFLICT_MARKER_END = '>>>>>>>'

current_mode = Grid

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


def init():
    process_result()
    current_mode.activate()


