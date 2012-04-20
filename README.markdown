Splice
======

Splice is a Vim plugin for resolving conflicts during three-way merges.

Visit [the site](http://sjl.bitbucket.org/splice.vim/) for more information.

Troubleshooting
---------------

Splice and Fugitive do not play well together.  If you try to use Splice as
a git mergetool while you have Fugitive installed it may segfault Vim, even if
you're not using any Fugitive features.

Fugitive must be doing something behind the scenes even when you don't run any
of its commands, but unfortunately the segfault doesn't give me a useful trace
so I can find the issue.  If you have any ideas on what might be happening
please let me know -- I'd love to fix this.
