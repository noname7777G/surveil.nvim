local parser = require('parser')

local queries = {
  "lightning",
  "-lightning",
  'o:":"',
  '-o:":"',
  "lightning or o:3",
  "-lightning or -o:3",
  "o:~",
}

for _, query in pairs(queries) do
  vim.print(parser:match(query))
end
