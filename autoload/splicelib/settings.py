import vim
from .util.log import log

def as_utf(s):
    return s if type(s) is not bytes else s.decode('utf-8')

#
# Cache the wrap value, it is used all the time.
# Assumes the global in 'g:' doesn't change once splice starts.
#
_wrap_cached = False
_wrap = None

#
# default to None if not a valid value.
# NOTE: expect a popup was displayed if crazy value.
# TODO: might as well fix it, to None, when problem found.
# TODO: return True or False
# The docs said that the setting for splice_wrap had to be either
# 'wrap' or 'nowrap'; but there was no checking and Splice executed
#       setlocal <whatever>
# Which is wacked. So added some checking.
#
def _wrap_setting():
    global _wrap_cached, _wrap

    if not _wrap_cached:
        w = as_utf(vim.vars.get('splice_wrap', None))
        if w == 'wrap':
            _wrap = 'wrap'
        elif w == 'nowrap':
            _wrap = 'nowrap'
        else:
            _wrap = None
        log('setting', f'SETTING: CACHEING wrap {_wrap}')
        _wrap_cached = True
    #log('setting', f'SETTING: wrap {_wrap}')
    return _wrap

#
#
def init_cur_window_wrap():
    wrap = _wrap_setting()
    if wrap:
        vim.current.window.options['wrap'] = True if wrap == 'wrap' else False

#
# READ COMMENT IN splice.vim about default settings.
# DO NOT NEED defaults here, they are pre-set in g: during startup
# should not be provided in two places.
# But, is everything given a default in splice.vim?
#

def setting(name, default=None):
    if name == 'wrap':
        t = "InternalError: use 'settings.init_cur_window_wrap()'"
        raise Exception(t)
    t = vim.vars.get('splice_' + name, None)
    #log('setting', f'SETTING: get {name}: {t}, default: {default}')
    if t and type(t) is bytes:
        t = t.decode('utf-8')
    if t == None: t = default
    #log('setting', f'SETTING: return: {t}')
    return t

def boolsetting(name):
    #if vim.vars.get('splice_' + name, 0)
    if int(setting(name, 0)):
        return True
    else:
        return False
