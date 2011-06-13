import vim
from util import buffers, windows


current_mode = None

class Mode(object):
    def __init__(self):
        self._current_diff_mode = 0
        return super(Mode, self).__init__()


    def diff(self, diffmode):
        getattr(self, '_diff_%d' % diffmode)()

    def key_diff(self, diffmode=None):
        next_diff_mode = self._current_diff_mode + 1
        if next_diff_mode >= self._number_of_diff_modes:
            next_diff_mode = 0
        self.diff(next_diff_mode)


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
        vim.command('diffoff!')
        self._current_diff_mode = 0

    def _diff_1(self):
        vim.command('diffoff!')
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

class LoupeMode(Mode):
    def __init__(self):
        self._number_of_diff_modes = 1
        return super(LoupeMode, self).__init__()


    def _init_layout(self):
        # Open the layout
        windows.close_all()

        # Put the buffers in the appropriate windows
        windows.focus(1)
        buffers.original.open()


    def _diff_0(self):
        vim.command('diffoff!')
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


grid = GridMode()
loupe = LoupeMode()


def key_grid():
    global current_mode
    current_mode = grid
    grid.activate()

def key_loupe():
    global current_mode
    current_mode = loupe
    loupe.activate()
