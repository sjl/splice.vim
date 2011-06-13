import os
import vim
import windows

ap = os.path.abspath

class Buffer(object):
    def __init__(self, i):
        self.number = i + 1
        self._buffer = vim.buffers[i]
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


class _BufferList(object):
    @property
    def original(self):
        return Buffer(0)

    @property
    def one(self):
        return Buffer(1)

    @property
    def two(self):
        return Buffer(2)

    @property
    def result(self):
        return Buffer(3)


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


buffers = _BufferList()
