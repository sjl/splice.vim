import sys
import vim


def error(m):
    sys.stderr.write(str(m) + '\n')

def echomsg(m):
    vim.command('echomsg "%s"' % m)
