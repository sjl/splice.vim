This plugin is still under active development.
==============================================

It is not even remotely ready yet.
==================================

Lots of things are unimplemented.
=================================

It will probably eat your data.
===============================

Seriously. If you use it and complain about it eating your data I am going to make fun of you on Twitter.
=========================================================================================================

Threesome
=========

Threesome is a Vim plugin for resolving conflicts during three-way merges.
It's designed to be used as a merge tool for version control systems like
Mercurial and Git.

* **Source (Mercurial):** <http://bitbucket.org/sjl/threesome.vim>
* **Source (Git):** <http://github.com/sjl/threesome.vim>
* **Issues:** <http://github.com/sjl/threesome.vim/issues>
* **License:** MIT X11
* **Full Documentation:** `:help threesome`

Requirements
------------

Vim 7.3+ compiled with Python 2.5+ support.

Yes, that's some (relatively) new stuff.  No, I'm not going to support anything less
than that.

Threesome is a merge tool which means you'll be working with it on your development
machine, not over SSH on your servers.

If you can't be bothered to run up-to-date versions of your tools on your main
development machine, I can't be bothered to clutter the codebase to support you.
Feels bad, man.

Installation
------------

Use Pathogen to install the plugin.

Build the docs:

    :call pathogen#helptags()

Add it as a merge tool for your VCS of choice.

### Mercurial

Add the following lines to `~/.hgrc`:

    [merge-tools]
    threesome.executable = mvim
    threesome.args = -f $base $local $other $output -c 'ThreesomeInit'
    threesome.premerge = keep
    threesome.priority = 1

**Note:** replace `mvim` with `gvim` if you're on Linux, or just plain `vim` if you prefer to keep the editor in the console.

### Git

Add the following lines to `~/.gitconfig`:

    [merge]
    tool = threesome

    [mergetool "threesome"]
    cmd = "mvim -f $BASE $LOCAL $REMOTE $MERGED -c 'ThreesomeInit'"
    trustExitCode = true

**Note:** replace `mvim` with `gvim` if you're on Linux, or just plain `vim` if you prefer to keep the editor in the console.

More Information
----------------

Read the full documentation to learn more `:help threesome`

TODO for v1.0.0
---------------

* Add a basic test suite.
* Remove the eat-your-data warnings in the docs.
