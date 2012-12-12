import vim, os, sys


# Add the library to the Python path.
for p in vim.eval("&runtimepath").split(','):
    plugin_dir = os.path.join(p, "autoload")
    if os.path.exists(os.path.join(plugin_dir, "splicelib")):
       if plugin_dir not in sys.path:
          sys.path.append(plugin_dir)
       break


import splicelib.init as splice


# Wrapper functions ----------------------------------------------------------------

def SpliceInit():
    splice.init()


def SpliceOriginal():
    splice.modes.current_mode.key_original()

def SpliceOne():
    splice.modes.current_mode.key_one()

def SpliceTwo():
    splice.modes.current_mode.key_two()

def SpliceResult():
    splice.modes.current_mode.key_result()


def SpliceGrid():
    splice.modes.key_grid()

def SpliceLoupe():
    splice.modes.key_loupe()

def SpliceCompare():
    splice.modes.key_compare()

def SplicePath():
    splice.modes.key_path()


def SpliceDiff():
    splice.modes.current_mode.key_diff()

def SpliceDiffoff():
    splice.modes.current_mode.key_diffoff()

def SpliceScroll():
    splice.modes.current_mode.key_scrollbind()

def SpliceLayout():
    splice.modes.current_mode.key_layout()

def SpliceNext():
    splice.modes.current_mode.key_next()

def SplicePrev():
    splice.modes.current_mode.key_prev()

def SpliceUse():
    splice.modes.current_mode.key_use()

def SpliceUse1():
    splice.modes.current_mode.key_use1()

def SpliceUse2():
    splice.modes.current_mode.key_use2()

