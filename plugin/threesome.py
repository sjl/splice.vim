import vim, os, sys

# Add the library to the Python path.
for p in vim.eval("&runtimepath").split(','):
   plugin_dir = os.path.join(p, "plugin")
   if os.path.exists(os.path.join(plugin_dir, "threesomelib")):
      if plugin_dir not in sys.path:
         sys.path.append(plugin_dir)
      break

def ThreesomeInit():
    from threesomelib.init import init
    init()
