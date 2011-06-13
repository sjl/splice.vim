import vim


def bind(key, to, options='', mode=None, leader='<localleader>'):
    vim.command('nnoremap %s %s%s %s' % (options, leader, key, to))
