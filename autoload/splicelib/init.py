import vim
from . import modes
from .settings import setting
from .util import buffers, windows


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

def setlocal_buffers():
    buffers.result.open()
    filetype = vim.eval('&filetype')

    buffers.original.open()
    vim.command('setlocal noswapfile')
    vim.command('setlocal nomodifiable')
    vim.command('set filetype=%s' % filetype)
    if setting('wrap'):
        vim.command('setlocal ' + setting('wrap'))

    buffers.one.open()
    vim.command('setlocal noswapfile')
    vim.command('setlocal nomodifiable')
    vim.command('set filetype=%s' % filetype)
    if setting('wrap'):
        vim.command('setlocal ' + setting('wrap'))

    buffers.two.open()
    vim.command('setlocal noswapfile')
    vim.command('setlocal nomodifiable')
    vim.command('set filetype=%s' % filetype)
    if setting('wrap'):
        vim.command('setlocal ' + setting('wrap'))

    buffers.result.open()
    vim.command('set filetype=%s' % filetype)
    if setting('wrap'):
        vim.command('setlocal ' + setting('wrap'))

    buffers.hud.open()
    vim.command('setlocal noswapfile')
    vim.command('setlocal nomodifiable')
    vim.command('setlocal nobuflisted')
    vim.command('setlocal buftype=nofile')
    vim.command('setlocal noundofile')
    vim.command('setlocal nolist')
    vim.command('setlocal ft=splice')
    vim.command('setlocal nowrap')
    vim.command('resize ' + setting('hud_size', '3'))

def create_hud():
    vim.command('new __Splice_HUD__')


def init():
    process_result()
    create_hud()
    setlocal_buffers()
    # key binding done on vim side before init

    vim.command('set hidden')

    initial_mode = setting('initial_mode', 'grid').lower()
    if initial_mode not in ['grid', 'loupe', 'compare', 'path']:
        initial_mode = 'grid'

    modes.current_mode = getattr(modes, initial_mode)
    modes.current_mode.activate()


