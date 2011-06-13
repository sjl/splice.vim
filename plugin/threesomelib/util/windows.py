import vim


def focus(winnr):
    vim.command('%dwincmd w' % winnr)

def close(winnr):
    focus(winnr)
    vim.command('wincmd c')

def close_all():
    for winnr in range(len(vim.windows) - 1):
        close(winnr)

def split():
    vim.command('wincmd s')

def vsplit():
    vim.command('wincmd v')

def currentnr():
    return int(vim.eval('winnr()'))

