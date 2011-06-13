import vim


class Buffer(object):
    def __init__(self, i):
        self.number = i + 1
        self._buffer = vim.buffers[i]
        self.name = self._buffer.name

    def open(self):
        vim.command('%dbuffer' % self.number)

    def set_lines(self, lines):
        self._buffer[:] = lines

    @property
    def lines(self):
        for line in self._buffer:
            yield line


class _BufferList(object):
    @property
    def base(self):
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

buffers = _BufferList()
