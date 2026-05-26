local parser = {}

local deps = {
  attachFunction = require 'attachFunction',

  makeName = function(t)
    t.field = "name"
    t.operation = ":"
    return t
  end,

  boolize = function(s)
    if s then
      return true
    else
      return false
    end
  end,
}

parser.re = vim.re.compile([[
  query <- space {| branch (or branch)* |}

  branch <- (!or queryPart)+ -> {}
  or <- ("or" space)+

  queryPart <- (namePart / operationPair)
  namePart <- {| {:inverted: inv :} {:exact: "!"? space -> boolize :} {:value: value :} |} !operation -> makeName -> attachFunction

  operationPair <- {| {:inverted: inv :} {:field: word :} {:operation: operation :} {:value: value :} |} -> attachFunction

  operation <- ":" / "=" / "<=" / ">=" / "<" / ">" / "!=" space

  -- vimPattern <- "v/"
  -- luaPattern <- "l/"

  inv <- "-"? space -> boolize
  value <- {word} / quote
  quote <- '"' {~ ((word / nonWord )* / '""' -> '"') ~} '"' space
  word <- [_%d%w~.-]+ space
  nonWord <- [][)(}{:|+!]+ space
  space <- %s*
]], deps)

return parser.re.match
