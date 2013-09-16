import os
import vim
import windows

ap = os.path.abspath

class Buffer(object):
    def __init__(self, i):
        self.number = i
        for b in vim.buffers:
            if b.number == self.number:
                self._buffer = b
                break
        self.name = self._buffer.name

    def open(self, winnr=None):
        if winnr is not None:
            windows.focus(winnr)
        vim.command('%dbuffer' % self.number)

    def set_lines(self, lines):
        self._buffer[:] = lines

    @property
    def lines(self):
        for line in self._buffer:
            yield line


    def __eq__(self, other):
        return self.name == other.name

    def __ne__(self, other):
        return self.name != other.name


class _BufferList(object):
    @property
    def original(self):
        return Buffer(1)

    @property
    def one(self):
        return Buffer(2)

    @property
    def two(self):
        return Buffer(3)

    @property
    def result(self):
        return Buffer(4)

    @property
    def hud(self):
        return Buffer(int(vim.eval("bufnr('__Splice_HUD__')")))


    @property
    def current(self):
        bufname = ap(vim.eval('bufname("%")'))

        if bufname == ap(self.original.name):
            return self.original
        elif bufname == ap(self.one.name):
            return self.one
        elif bufname == ap(self.two.name):
            return self.two
        elif bufname == ap(self.result.name):
            return self.result

    @property
    def all(self):
        return [self.original, self.one, self.two, self.result]


    @property
    def labels(self):
        return { buffers.original.name: 'Original',
                 buffers.one.name: 'One',
                 buffers.two.name: 'Two',
                 buffers.result.name: 'Result' }

    class remain:
        def __enter__(self):
            self.curbuf = int(vim.eval('bufnr(bufname("%"))'))
            self.pos = windows.pos()

        def __exit__(self, type, value, traceback):
            vim.command('%dbuffer' % self.curbuf)
            vim.current.window.cursor = self.pos

buffers = _BufferList()

