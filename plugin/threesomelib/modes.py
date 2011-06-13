import vim
from util import buffers, windows


current_mode = None

class Mode(object):
    def __init__(self):
        self._current_diff_mode = 0
        return super(Mode, self).__init__()


    def diff(self, diffmode):
        curwindow = windows.currentnr()
        getattr(self, '_diff_%d' % diffmode)()
        windows.focus(curwindow)

    def diffoff(self):
        curwindow = windows.currentnr()

        for winnr in range(1, 1 + self._number_of_windows):
            windows.focus(winnr)
            curbuffer = buffers.current

            for buffer in buffers.all:
                buffer.open()
                vim.command('diffoff')

            curbuffer.open()

        windows.focus(curwindow)

    def key_diff(self, diffmode=None):
        next_diff_mode = self._current_diff_mode + 1
        if next_diff_mode >= self._number_of_diff_modes:
            next_diff_mode = 0
        self.diff(next_diff_mode)

    def key_diffoff(self):
        self.diff(0)


    def key_original(self):
        pass

    def key_one(self):
        pass

    def key_two(self):
        pass

    def key_result(self):
        pass


    def activate(self):
        self._diff_0()


    def key_next(self):
        self.goto_result()
        vim.command(r'exe "normal! /\=\=\=\=\=\=\=\<cr>"')

    def key_prev(self):
        self.goto_result()
        vim.command(r'exe "normal! ?\=\=\=\=\=\=\=\<cr>"')


class GridMode(Mode):
    """
    Layout 1                 Layout 2
    +-------------------+    +--------------------------+
    |     Original      |    | One    | Result | Two    |
    |1                  |    |        |        |        |
    +-------------------+    |        |        |        |
    |  One    |    Two  |    |        |        |        |
    |2        |3        |    |        |        |        |
    +-------------------+    |        |        |        |
    |      Result       |    |        |        |        |
    |4                  |    |1       |2       |3       |
    +-------------------+    +--------------------------+
    """

    def __init__(self):
        self._number_of_diff_modes = 2
        self._number_of_windows = 4
        return super(GridMode, self).__init__()


    def _init_layout(self):
        # Open the layout
        windows.close_all()
        windows.split()
        windows.split()
        windows.focus(2)
        windows.vsplit()

        # Put the buffers in the appropriate windows
        windows.focus(1)
        buffers.original.open()

        windows.focus(2)
        buffers.one.open()

        windows.focus(3)
        buffers.two.open()

        windows.focus(4)
        buffers.result.open()


    def _diff_0(self):
        self.diffoff()
        self._current_diff_mode = 0

    def _diff_1(self):
        self.diffoff()
        self._current_diff_mode = 1

        for i in range(1, 5):
            windows.focus(i)
            vim.command('diffthis')


    def activate(self):
        self._init_layout()
        super(GridMode, self).activate()


    def key_original(self):
        windows.focus(1)

    def key_one(self):
        windows.focus(2)

    def key_two(self):
        windows.focus(3)

    def key_result(self):
        windows.focus(4)


    def goto_result(self):
        windows.focus(4)

class LoupeMode(Mode):
    def __init__(self):
        self._number_of_diff_modes = 1
        self._number_of_windows = 1
        return super(LoupeMode, self).__init__()


    def _init_layout(self):
        # Open the layout
        windows.close_all()

        # Put the buffers in the appropriate windows
        windows.focus(1)
        buffers.original.open()


    def _diff_0(self):
        self.diffoff()
        self._current_diff_mode = 0


    def activate(self):
        self._init_layout()
        super(LoupeMode, self).activate()


    def key_original(self):
        windows.focus(1)
        buffers.original.open()

    def key_one(self):
        windows.focus(1)
        buffers.one.open()

    def key_two(self):
        windows.focus(1)
        buffers.two.open()

    def key_result(self):
        windows.focus(1)
        buffers.result.open()


    def goto_result(self):
        self.key_result()

class CompareMode(Mode):
    def __init__(self):
        self._number_of_diff_modes = 2
        self._number_of_windows = 2
        return super(CompareMode, self).__init__()


    def _init_layout(self):
        # Open the layout
        windows.close_all()
        windows.vsplit()

        # Put the buffers in the appropriate windows
        windows.focus(1)
        buffers.original.open()

        windows.focus(2)
        buffers.result.open()


    def _diff_0(self):
        self.diffoff()
        self._current_diff_mode = 0

    def _diff_1(self):
        self.diffoff()
        self._current_diff_mode = 1

        for i in range(1, 3):
            windows.focus(i)
            vim.command('diffthis')


    def activate(self):
        self._init_layout()
        super(CompareMode, self).activate()


    def key_original(self):
        windows.focus(1)
        buffers.original.open()
        self.diff(self._current_diff_mode)

    def key_one(self):
        def open_one(winnr):
            buffers.one.open(winnr)
            self.diff(self._current_diff_mode)

        curwindow = windows.currentnr()

        # If file one is showing, go to it.
        windows.focus(1)
        if buffers.current.name == buffers.one.name:
            return

        windows.focus(2)
        if buffers.current.name == buffers.one.name:
            return

        # If both the original and result are showing, open file one in the
        # current window.
        windows.focus(1)
        if buffers.current.name == buffers.original.name:
            windows.focus(2)
            if buffers.current.name == buffers.result.name:
                open_one(curwindow)
                return

        # If file two is in window 1, then we open file one in window 1.
        windows.focus(1)
        if buffers.current.name == buffers.two.name:
            open_one(1)
            return

        # Otherwise, open file one in the current window.
        open_one(curwindow)

    def key_two(self):
        def open_two(winnr):
            buffers.two.open(winnr)
            self.diff(self._current_diff_mode)

        curwindow = windows.currentnr()

        # If file two is showing, go to it.
        windows.focus(1)
        if buffers.current.name == buffers.two.name:
            return

        windows.focus(2)
        if buffers.current.name == buffers.two.name:
            return

        # If both the original and result are showing, open file two in the
        # current window.
        windows.focus(1)
        if buffers.current.name == buffers.original.name:
            windows.focus(2)
            if buffers.current.name == buffers.result.name:
                open_two(curwindow)
                return

        # If file one is in window 2, then we open file two in window 2.
        windows.focus(2)
        if buffers.current.name == buffers.two.name:
            open_two(2)
            return

        # Otherwise, open file two in window 2.
        open_two(curwindow)

    def key_result(self):
        windows.focus(2)
        buffers.result.open()
        self.diff(self._current_diff_mode)


    def goto_result(self):
        self.key_result()

class PathMode(Mode):
    def __init__(self):
        self._number_of_diff_modes = 4
        self._number_of_windows = 3
        return super(PathMode, self).__init__()


    def _init_layout(self):
        # Open the layout
        windows.close_all()
        windows.vsplit()
        windows.vsplit()

        # Put the buffers in the appropriate windows
        windows.focus(1)
        buffers.original.open()

        windows.focus(2)
        buffers.one.open()

        windows.focus(3)
        buffers.result.open()


    def _diff_0(self):
        self.diffoff()
        self._current_diff_mode = 0

    def _diff_1(self):
        self.diffoff()
        self._current_diff_mode = 1

        windows.focus(1)
        vim.command('diffthis')

        windows.focus(3)
        vim.command('diffthis')

    def _diff_2(self):
        self.diffoff()
        self._current_diff_mode = 2

        windows.focus(1)
        vim.command('diffthis')

        windows.focus(2)
        vim.command('diffthis')

    def _diff_3(self):
        self.diffoff()
        self._current_diff_mode = 3

        windows.focus(2)
        vim.command('diffthis')

        windows.focus(3)
        vim.command('diffthis')


    def activate(self):
        self._init_layout()
        super(PathMode, self).activate()


    def key_original(self):
        windows.focus(1)

    def key_one(self):
        windows.focus(2)
        buffers.one.open()
        self.diff(self._current_diff_mode)
        windows.focus(2)

    def key_two(self):
        windows.focus(2)
        buffers.two.open()
        self.diff(self._current_diff_mode)
        windows.focus(2)

    def key_result(self):
        windows.focus(3)


    def goto_result(self):
        windows.focus(3)


grid = GridMode()
loupe = LoupeMode()
compare = CompareMode()
path = PathMode()


def key_grid():
    global current_mode
    current_mode = grid
    grid.activate()

def key_loupe():
    global current_mode
    current_mode = loupe
    loupe.activate()
def key_compare():
    global current_mode
    current_mode = compare
    compare.activate()
def key_path():
    global current_mode
    current_mode = path
    path.activate()
