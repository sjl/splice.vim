Splice - a Vim plugin for resolving three-way merges-

Demo
----

[Watch the demo screencast][screencast] in HD on Vimeo.

[screencast]: http://vimeo.com/25764692

Requirements
------------

Vim 7.3+ compiled with Python 2.5+ support.

Yes, that's some (relatively) new stuff.  No, I'm not going to support anything less
than that.

Splice is a merge tool which means you'll be working with it on your development
machine, not over SSH on your servers.

If you can't be bothered to run up-to-date versions of your tools on your main
development machine, I can't be bothered to clutter the codebase to support you.
Feels bad, man.

Installation
------------

Use [Pathogen][] to install the plugin from your choice of repositories:

    hg clone https://bitbucket.org/sjl/splice.vim ~/.vim/bundle/splice
    git clone https://github.com/sjl/splice.vim.git ~/.vim/bundle/splice

[Pathogen]: http://www.vim.org/scripts/script.php?script_id=2332

Build the docs:

    :call pathogen#helptags()

Add it as a merge tool for your VCS of choice.

### Mercurial

Add the following lines to `~/.hgrc`:

    [merge-tools]
    splice.executable = mvim
    splice.args = -f $base $local $other $output -c 'SpliceInit'
    splice.premerge = keep
    splice.priority = 1

**Note:** replace `mvim` with `gvim` if you're on Linux, or just plain `vim` if you prefer to keep the editor in the console.

### Git

Add the following lines to `~/.gitconfig`:

    [merge]
    tool = splice

    [mergetool "splice"]
    cmd = "mvim -f $BASE $LOCAL $REMOTE $MERGED -c 'SpliceInit'"
    trustExitCode = true

**Note:** replace `mvim` with `gvim` if you're on Linux, or just plain `vim` if you prefer to keep the editor in the console.

### Bazaar

For Bazaar 2.4 or greater, add the following line to bazaar.conf:

    bzr.mergetool.splice = mvim {base} {this} {other} {result} -c 'SpliceInit'

Optionally, change the default merge tool by setting:

    bzr.default_mergetool = splice

For earlier versions of Bazaar, set the following entry in bazaar.conf:

    external_merge = mvim %b %t %o %r -c 'SpliceInit'

**Note:** replace `mvim` with `gvim` if you're on Linux, or just plain `vim` if you prefer to keep the editor in the console.

More Information
----------------

**Full Documentation:** `:help splice`  
**Source (Mercurial):** <http://bitbucket.org/sjl/splice.vim>  
**Source (Git):** <http://github.com/sjl/splice.vim>  
**Issues:** <http://github.com/sjl/splice.vim/issues>  
**License:** [MIT/X11][license]

[license]: http://www.opensource.org/licenses/mit-license.php
