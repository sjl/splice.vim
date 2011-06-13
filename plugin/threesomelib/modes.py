import vim
from util import buffers, windows
from settings import setting


current_mode = None

class Mode(object):
    def __init__(self):
        return super(Mode, self).__init__()


    def diff(self, diffmode):
        curwindow = windows.currentnr()
        getattr(self, '_diff_%d' % diffmode)()
        windows.focus(curwindow)

    def key_diff(self, diffmode=None):
        next_diff_mode = self._current_diff_mode + 1
        if next_diff_mode >= self._number_of_diff_modes:
            next_diff_mode = 0
        self.diff(next_diff_mode)


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

    def key_diffoff(self):
        self.diff(0)


    def layout(self, layoutnr):
        getattr(self, '_layout_%d' % layoutnr)()
        self.diff(self._current_diff_mode)

    def key_layout(self, diffmode=None):
        next_layout = self._current_layout + 1
        if next_layout >= self._number_of_layouts:
            next_layout = 0
        self.layout(next_layout)


    def key_original(self):
        pass

    def key_one(self):
        pass

    def key_two(self):
        pass

    def key_result(self):
        pass


    def activate(self):
        self.layout(self._current_layout)
        self.diff(self._current_diff_mode)


    def key_next(self):
        self.goto_result()
        vim.command(r'exe "normal! /\=\=\=\=\=\=\=\<cr>"')

    def key_prev(self):
        self.goto_result()
        vim.command(r'exe "normal! ?\=\=\=\=\=\=\=\<cr>"')


class GridMode(Mode):
    """
    Layout 0                 Layout 1                        Layout 2
    +-------------------+    +--------------------------+    +---------------+
    |     Original      |    | One    | Result | Two    |    |      One      |
    |1                  |    |        |        |        |    |1              |
    +-------------------+    |        |        |        |    +---------------+
    |  One    |    Two  |    |        |        |        |    |     Result    |
    |2        |3        |    |        |        |        |    |2              |
    +-------------------+    |        |        |        |    +---------------+
    |      Result       |    |        |        |        |    |      Two      |
    |4                  |    |1       |2       |3       |    |3              |
    +-------------------+    +--------------------------+    +---------------+
    """

    def __init__(self):
        self._current_layout = int(setting('initial_layout_grid', 0))
        self._current_diff_mode = int(setting('initial_diff_grid', 0))

        self._number_of_diff_modes = 2
        self._number_of_layouts = 3

        return super(GridMode, self).__init__()


    def _layout_0(self):
        self._number_of_windows = 4
        self._current_layout = 0

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

    def _layout_1(self):
        self._number_of_windows = 3
        self._current_layout = 1

        # Open the layout
        windows.close_all()
        windows.vsplit()
        windows.vsplit()

        # Put the buffers in the appropriate windows
        windows.focus(1)
        buffers.one.open()

        windows.focus(2)
        buffers.result.open()

        windows.focus(3)
        buffers.two.open()

    def _layout_2(self):
        self._number_of_windows = 4
        self._current_layout = 2

        # Open the layout
        windows.close_all()
        windows.split()
        windows.split()

        # Put the buffers in the appropriate windows
        windows.focus(1)
        buffers.one.open()

        windows.focus(2)
        buffers.result.open()

        windows.focus(3)
        buffers.two.open()


    def _diff_0(self):
        self.diffoff()
        self._current_diff_mode = 0

    def _diff_1(self):
        self.diffoff()
        self._current_diff_mode = 1

        for i in range(1, self._number_of_windows + 1):
            windows.focus(i)
            vim.command('diffthis')


    def key_original(self):
        if self._current_layout == 0:
            windows.focus(1)
        elif self._current_layout == 1:
            return
        elif self._current_layout == 2:
            return

    def key_one(self):
        if self._current_layout == 0:
            windows.focus(2)
        elif self._current_layout == 1:
            windows.focus(1)
        elif self._current_layout == 2:
            windows.focus(1)

    def key_two(self):
        if self._current_layout == 0:
            windows.focus(3)
        elif self._current_layout == 1:
            windows.focus(3)
        elif self._current_layout == 2:
            windows.focus(3)

    def key_result(self):
        if self._current_layout == 0:
            windows.focus(4)
        elif self._current_layout == 1:
            windows.focus(2)
        elif self._current_layout == 2:
            windows.focus(2)


    def goto_result(self):
        if self._current_layout == 0:
            windows.focus(4)
        elif self._current_layout == 1:
            windows.focus(2)
        elif self._current_layout == 2:
            windows.focus(2)

class LoupeMode(Mode):
    def __init__(self):
        self._current_layout = int(setting('initial_layout_loupe', 0))
        self._current_diff_mode = int(setting('initial_diff_loupe', 0))

        self._number_of_diff_modes = 1
        self._number_of_layouts = 1

        self._current_buffer = buffers.result

        return super(LoupeMode, self).__init__()


    def _diff_0(self):
        self.diffoff()
        self._current_diff_mode = 0


    def _layout_0(self):
        self._number_of_windows = 1
        self._current_layout = 0

        # Open the layout
        windows.close_all()

        # Put the buffers in the appropriate windows
        windows.focus(1)
        self._current_buffer.open()


    def key_original(self):
        windows.focus(1)
        buffers.original.open()
        self._current_buffer = buffers.original

    def key_one(self):
        windows.focus(1)
        buffers.one.open()
        self._current_buffer = buffers.one

    def key_two(self):
        windows.focus(1)
        buffers.two.open()
        self._current_buffer = buffers.two

    def key_result(self):
        windows.focus(1)
        buffers.result.open()
        self._current_buffer = buffers.result


    def goto_result(self):
        self.key_result()

class CompareMode(Mode):
    def __init__(self):
        self._current_layout = int(setting('initial_layout_compare', 0))
        self._current_diff_mode = int(setting('initial_diff_compare', 0))

        self._number_of_diff_modes = 2
        self._number_of_layouts = 2

        self._current_buffer_first = buffers.original
        self._current_buffer_second = buffers.result

        return super(CompareMode, self).__init__()


    def _diff_0(self):
        self.diffoff()
        self._current_diff_mode = 0

    def _diff_1(self):
        self.diffoff()
        self._current_diff_mode = 1

        windows.focus(1)
        vim.command('diffthis')

        windows.focus(2)
        vim.command('diffthis')


    def _layout_0(self):
        self._number_of_windows = 2
        self._current_layout = 0

        # Open the layout
        windows.close_all()
        windows.vsplit()

        # Put the buffers in the appropriate windows
        windows.focus(1)
        self._current_buffer_first.open()

        windows.focus(2)
        self._current_buffer_second.open()

    def _layout_1(self):
        self._number_of_windows = 2
        self._current_layout = 1

        # Open the layout
        windows.close_all()
        windows.split()

        # Put the buffers in the appropriate windows
        windows.focus(1)
        self._current_buffer_first.open()

        windows.focus(2)
        self._current_buffer_second.open()


    def key_original(self):
        windows.focus(1)
        buffers.original.open()
        self._current_buffer_first = buffers.original
        self.diff(self._current_diff_mode)

    def key_one(self):
        def open_one(winnr):
            buffers.one.open(winnr)
            if winnr == 1:
                self._current_buffer_first = buffers.one
            else:
                self._current_buffer_second = buffers.one
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
            if winnr == 1:
                self._current_buffer_first = buffers.two
            else:
                self._current_buffer_second = buffers.two
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
        self._current_buffer_second = buffers.result
        self.diff(self._current_diff_mode)


    def goto_result(self):
        self.key_result()

class PathMode(Mode):
    def __init__(self):
        self._current_layout = int(setting('initial_layout_path', 0))
        self._current_diff_mode = int(setting('initial_diff_path', 0))

        self._number_of_diff_modes = 5
        self._number_of_layouts = 2

        self._current_mid_buffer = buffers.one

        return super(PathMode, self).__init__()


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

    def _diff_4(self):
        self.diffoff()
        self._current_diff_mode = 4

        windows.focus(1)
        vim.command('diffthis')

        windows.focus(2)
        vim.command('diffthis')

        windows.focus(3)
        vim.command('diffthis')


    def _layout_0(self):
        self._number_of_windows = 3
        self._current_layout = 0

        # Open the layout
        windows.close_all()
        windows.vsplit()
        windows.vsplit()

        # Put the buffers in the appropriate windows
        windows.focus(1)
        buffers.original.open()

        windows.focus(2)
        self._current_mid_buffer.open()

        windows.focus(3)
        buffers.result.open()

    def _layout_1(self):
        self._number_of_windows = 3
        self._current_layout = 1

        # Open the layout
        windows.close_all()
        windows.split()
        windows.split()

        # Put the buffers in the appropriate windows
        windows.focus(1)
        buffers.original.open()

        windows.focus(2)
        self._current_mid_buffer.open()

        windows.focus(3)
        buffers.result.open()


    def key_original(self):
        windows.focus(1)

    def key_one(self):
        windows.focus(2)
        buffers.one.open()
        self._current_mid_buffer = buffers.one
        self.diff(self._current_diff_mode)
        windows.focus(2)

    def key_two(self):
        windows.focus(2)
        buffers.two.open()
        self._current_mid_buffer = buffers.two
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
