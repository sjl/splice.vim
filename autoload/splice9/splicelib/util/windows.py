import vim
from .log import log

def focus(winnr):
    log('focus', 'WIN: focus ' + str(winnr)
            + (' ERROR' if winnr > len(vim.windows) or winnr < 1 else ''))
    if winnr <= len(vim.windows) and winnr > 0:
        vim.current.window = vim.windows[winnr-1]
    #vim.command('%dwincmd w' % winnr)

def close_all():
    focus(1)
    vim.command('wincmd o')

def split():
    vim.command('wincmd s')

def vsplit():
    vim.command('wincmd v')

def currentnr():
    return vim.current.window.number
    #return int(vim.eval('winnr()'))

def pos():
    return vim.current.window.cursor


class remain:
    def __enter__(self):
        self.curwindow = currentnr()
        self.pos = pos()

    def __exit__(self, type, value, traceback):
        focus(self.curwindow)
        vim.current.window.cursor = self.pos

