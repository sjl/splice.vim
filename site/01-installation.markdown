Installation
============

[TOC]

## Vim Plugin

Use [Pathogen][] to install the plugin from your choice of repositories:

    hg clone https://hg.stevelosh.com/splice.vim ~/.vim/bundle/splice
    git clone https://github.com/sjl/splice.vim.git ~/.vim/bundle/splice

[Pathogen]: http://www.vim.org/scripts/script.php?script_id=2332

Build the docs:

    :call pathogen#helptags()

## VCS Support

Once you've installed Splice you'll need to configure your version control
system to use it as a merge tool.

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

