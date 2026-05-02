local parser = require 'parser'

local query = parser:match("foo bar or foo baz or lightning")

vim.print(query)

query = parser:match("foo bar")

vim.print(query)

query = parser:match("for or or bar")


vim.print(query)

query = parser:match("t:dwarf or kw:changeling")

vim.print(query)

query = parser:match("f")

vim.print(query)

query = parser:match("-pow:3 t:creature")

vim.print(query)
