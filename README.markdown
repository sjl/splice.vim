This plugin is still under active development.
==============================================

It is not even remotely ready yet.  Lots of things are unimplemented.
=====================================================================

It will probably eat your data.
===============================

Seriously. If you use it and complain about it eating your data I am going to make fun of you on Twitter.
======================

Threesome is a Vim plugin for resolving conflicts during three-way merges.
It's designed to be used as a merge tool for version control systems like
Mercurial and Git.

* Basic Usage
* Key Bindings
* Modes
* Configuration
* Contributing
* Changelog
* License

Installation
============

Use Pathogen to install the plugin, then add it as a merge tool for your VCS of
choice:

**Mercurial:** add the following lines to `~/.hgrc`:

    [merge-tools]
    threesome.executable = mvim
    threesome.args = -f $base $local $other $output -c 'ThreesomeInit'
    threesome.premerge = keep
    threesome.priority = 1

**Git:** add the following lines to `~/.gitconfig`:

    [merge]
    tool = threesome

    [mergetool "threesome"]
    cmd = "mvim -f $BASE $LOCAL $REMOTE $MERGED -c 'ThreesomeInit'"
    trustExitCode = true

**Note:** replace `mvim` with `gvim` if you're on Linux, or just plain `vim` if you
prefer to keep the editor in the console.

Basic Usage
===========

Threesome takes a lot of inspiration for its user interface from Adobe
Lightroom, a photo editing program.

When resolving a merge there are four files you will work with:

* **Original**: the original file, as it appears in the parent revision of the two revisions being merged.
* **One**: the file as it appears in the first revision being merged (usually the "current" revision, or the one you are at when you run 'hg merge REV').
* **Two**: the file as it appears in the second revision being merged (usually the "target" revision, or the one you specify in the 'hg merge REV' command).
* **Result**: the result of merging the two revisions of the file (this is the file that your version control system expects to contain the final result once you're done).

Threesome has four "modes" or "views" for working with these files:

* **Grid**: shows all four files at once, to give you an overview of the merge.
* **Loupe**: shows a single file at a time, for close examination of a single file.
* **Compare**: shows two files at a time, for examining the movement of changes between pairs of files.
* **Path**: shows three files at a time: the original, either one or two, and the result, for examining how a change moves through one "path" or "branch" of the merge.

Your goal is to use these views to resolve all merge conflicts by making the
result file look like it should, saving it to disk, and closing Vim.

Key Bindings
============

Threesome makes use of `<localleader>` for all of its key bindings to avoid
clashing with global mappings. If you've never used `<localleader>` now
would be a good time to read the help and configure a key for it.

All keybindings that are used across all modes.  The behavior of some of them
changes depending on the current mode, but the effects should be fairly
intuitive.

Mode Selection
--------------

All keybindings begin with `<localleader>`.

* `g` - Grid    - Switch to grid view.
* `l` - Loupe   - Switch to loupe view.
* `c` - Compare - Switch to compare view.
* `p` - Path    - Switch to path view.

File Selection
--------------

All keybindings begin with `<localleader>`.

* `o` - Original - Select the original file.
* `1` - One      - Select file one.
* `2` - Two      - Select file two.
* `r` - Result   - Select the result file.

Other
-----

All keybindings begin with `<localleader>`.

* `d`       - Diff     - Cycle through various diff combinations.
* `u`       - Use Hunk - Place a hunk from file one or two into the result file.
* `s`       - Scroll   - Toggle scroll locking on and off.
* `<space>` - Layout   - Cycle through various layouts of the current view.

* `n`       - Next     - Move to the next unresolved conflict.
* `N`       - Previous - Move to the previous unresolved conflict.

* `q`       - Quit     - Save the result file and exit Vim.  Indicates to the VCS that the merge was successful and it should use the current contents of the result file as the result.
* `CC`      - Cancel   - Exits Vim with an error code (like :cq).  Indicates to the VCS that the merge was NOT successful.

Modes
=====

This section describes each mode in detail.

Grid
----

The grid view is used to get an overview of all files at once to get a birds'
eye view of the merge.

### Grid Layouts

    Layout 1                 Layout 2
    +-------------------+    +--------------------------+
    |     Original      |    | One    | Result | Two    |
    |                   |    |        |        |        |
    +-------------------+    |        |        |        |
    |  One    |    Two  |    |        |        |        |
    |         |         |    |        |        |        |
    +-------------------+    |        |        |        |
    |      Result       |    |        |        |        |
    |                   |    |        |        |        |
    +-------------------+    +--------------------------+

### Grid-Specific Key Bindings

All keybindings begin with `<localleader>`.

* `o`  - Original   - Focus the original file (only in layout 1).
* `1`  - One        - Focus file one.
* `2`  - Two        - Focus file two.
* `r`  - Result     - Focus the result file.
* `d`  - Diff       - Cycle through various diff combinations.
* `u1` - Use Hunk 1 - Place a hunk from file one into the result file.
* `u2` - Use Hunk 2 - Place a hunk from file two into the result file.

### Grid Diffs

1. No diff.
2. Diff the original and file one.
3. Diff the original and file two.
4. Diff file one and the result.
5. Diff file two and the result.
6. Diff the original and the result.

Loupe
-----

The loupe view is used to focus on and examine a single file in detail.

### Loupe Layouts

    Layout 1
    +-------------------+
    |  Any Single File  |
    |                   |
    |                   |
    |                   |
    |                   |
    |                   |
    |                   |
    |                   |
    +-------------------+

### Loupe-Specific Key Bindings

All keybindings begin with `<localleader>`.

* `o` - Original - View the original file.
* `1` - One      - View file one.
* `2` - Two      - View file two.
* `r` - Result   - View the result file.
* `d` - Diff     - Disabled.
* `u` - Use Hunk - Disabled.

### Loupe Diffs

No diffs are possible in loupe mode.

Compare
-------

The compare view is used to examine the differences between two files at
a time.

### Compare Layouts

    Layout 1                 Layout 2
    +-------------------+    +-------------------+
    | Orig    | Result  |    | Orig              |
    |         |         |    | or One            |
    |    or   |    or   |    | or Two            |
    |         |         |    |                   |
    | One     | One     |    +-------------------+
    |         |         |    | One               |
    |    or   |    or   |    | or Two            |
    |         |         |    | or Result         |
    | Two     | Two     |    |                   |
    +-------------------+    +-------------------+

### Compare-Specific Key Bindings

All keybindings begin with `<localleader>`.

* `o` - Original - Place the original file in the left/top window.
* `1` - One      - Place file one in the right/bottom window if the original is visible, otherwise place it in the left/top window.
* `2` - Two      - Place file two in the left/top window if the result is visible, otherwise place it in the right/bottom window.
* `r` - Result   - Place the result file in the right/bottom window.
* `d` - Diff     - Cycle through various diff combinations.
* `u` - Use Hunk - If the result file and file one/two are both visible, place a hunk from one/two into the result file.  Otherwise, disabled.

### Compare Diffs

1. No diff.
2. Diff both windows.

Path
----

The path view is used to view the flow of changed through one "path" or
"branch" of the merge.

### Path Layouts

    Layout 1                        Layout 2
    +--------------------------+    +-------------------+
    | Orig   |        | Result |    | Orig              |
    |        |        |        |    |                   |
    |        | One    |        |    |                   |
    |        |        |        |    +-------------------+
    |        |   or   |        |    | One               |
    |        |        |        |    | or Two            |
    |        | Two    |        |    |                   |
    |        |        |        |    +-------------------+
    |        |        |        |    | Result            |
    +--------------------------+    |                   |
                                    |                   |
                                    +-------------------+

### Path-Specific Key Bindings

All keybindings begin with `<localleader>`.

* `o` - Original - Focus the original file.
* `1` - One      - Place file one in the center window and focus it.
* `2` - Two      - Place file two in the center window and focus it.
* `r` - Result   - Focus the result file.
* `d` - Diff     - Cycle through various diff combinations.
* `u` - Use Hunk - Place a hunk from file one or two (whichever is currently in
                 the center window) into the result file.

### Path Diffs

1. No diff.
2. Diff the original and center windows.
3. Diff the center and result windows.
4. Diff the original and result windows.
