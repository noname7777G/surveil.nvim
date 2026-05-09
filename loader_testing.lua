local loader = require('loader')

loader.updateCards("skipDownload")

local json = vim.json.encode(loader.chars)

vim.print(json)

local file = io.open("cardChars.json", "a")
if file then
  file:write(json)
end
