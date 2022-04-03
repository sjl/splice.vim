import vim, os, sys


# Add the library to the Python path.
for p in vim.eval("&runtimepath").split(','):
    plugin_dir = os.path.join(p, "autoload")
    if os.path.exists(os.path.join(plugin_dir, "splicelib")):
       if plugin_dir not in sys.path:
          sys.path.append(plugin_dir)
       break


import splicelib.init as splice
from splicelib.util.log import log


# Wrapper functions ----------------------------------------------------------------

# Note: :SpliceQuit, :SpliceCancel defined in keys.vim
# also  SpliceActivateGridBindings, SpliceDeactivateGridBindings
# TODO: ?category: 'wrapper'?

def SpliceInit():
    log('SpliceInit')
    splice.init()


def SpliceOriginal():
    log('SpliceOriginal')
    splice.modes.current_mode.key_original()

def SpliceOne():
    log('SpliceOne')
    splice.modes.current_mode.key_one()

def SpliceTwo():
    log('SpliceTwo')
    splice.modes.current_mode.key_two()

def SpliceResult():
    log('SpliceResult')
    splice.modes.current_mode.key_result()


def SpliceGrid():
    log('SpliceGrid')
    splice.modes.key_grid()

def SpliceLoupe():
    log('SpliceLoupe')
    splice.modes.key_loupe()

def SpliceCompare():
    log('SpliceCompare')
    splice.modes.key_compare()

def SplicePath():
    log('SplicePath')
    splice.modes.key_path()


def SpliceDiff():
    log('SpliceDiff')
    splice.modes.current_mode.key_diff()

def SpliceDiffOff():
    log('SpliceDiffOff')
    splice.modes.current_mode.key_diffoff()

def SpliceScroll():
    log('SpliceScroll')
    splice.modes.current_mode.key_scrollbind()

def SpliceLayout():
    log('SpliceLayout')
    splice.modes.current_mode.key_layout()

def SpliceNext():
    log('SpliceNext')
    splice.modes.current_mode.key_next()

def SplicePrev():
    log('SplicePrev')
    splice.modes.current_mode.key_prev()

def SpliceUse():
    log('SpliceUse')
    splice.modes.current_mode.key_use()

def SpliceUse1():
    log('SpliceUse1')
    splice.modes.current_mode.key_use1()

def SpliceUse2():
    log('SpliceUse2')
    splice.modes.current_mode.key_use2()

