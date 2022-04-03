import re

import vim

# Invoked as either Log(msg) or Log(category, msg).
# Check to see if category should be logged.
#
# TODO: pass in lambda to build the msg, then can lower cost of invocation
# NOTE: need to encode the category
#
def log(arg1, arg2=None):
    if not arg2:
        vim.command('call log.Log("PY: ' + arg1 + '")')
        return
    if not arg1.encode('utf-8') in vim.vars['splice_logging_exclude']:
        vim.command('call log.Log("PY: ' + arg2 + '")')

def log_stack(s):
    for i in s:
        i = i.replace('"', '')
        i = re.sub(r'File.*splice.vim/autoload/', '', i)
        i = re.sub(r'File.*splice.vim/plugin/', '', i)
        log(i)
