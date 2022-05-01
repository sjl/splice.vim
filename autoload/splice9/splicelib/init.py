CONFLICT_MARKER_START = '<<<<<<<'
CONFLICT_MARKER_MARK = '======='
CONFLICT_MARKER_END = '>>>>>>>'

import vim
from . import modes
from .settings import setting, init_cur_window_wrap
from .util import buffers, windows
from .util.log import log

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

def setlocal_fixed_buffer(b, filetype):
    b.options['swapfile'] = False
    b.options['modifiable'] = False
    b.options['filetype'] = filetype
    init_cur_window_wrap()

def setlocal_buffers():
    b = buffers.result.open()
    filetype = b.options['filetype']

    setlocal_fixed_buffer(buffers.original.open(), filetype)
    setlocal_fixed_buffer(buffers.one.open(), filetype)
    setlocal_fixed_buffer(buffers.two.open(), filetype)

    buffers.result.open()
    init_cur_window_wrap()

    b = buffers.hud.open()
    w = vim.current.window
    b.options['swapfile'] = False
    b.options['modifiable'] = False
    b.options['buflisted'] = False
    b.options['buftype'] = 'nofile'
    b.options['undofile'] = False
    w.options['list'] = False
    # following needs to be done with a vim command otherwise syntax not on
    #b.options['filetype'] = 'splice'
    vim.command('setlocal filetype=splice')
    w.options['wrap'] = False
    vim.command('resize ' + setting('hud_size', '3'))

def create_hud():
    vim.command('new __Splice_HUD__')


def init():
    process_result()
    create_hud()
    setlocal_buffers()

    vim.options['hidden'] = True

    initial_mode = setting('initial_mode', 'grid').lower()
    log("INIT: inital mode " + initial_mode)
    if initial_mode not in ['grid', 'loupe', 'compare', 'path']:
        initial_mode = 'grid'

    modes.current_mode = getattr(modes, initial_mode)
    modes.current_mode.activate()

