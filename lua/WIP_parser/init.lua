local number = require 'number'
local color = require 'color'

local parser = {}

parser.termIgnored = function(_, _) return true end -- TODO: make this inform the user of their error.
-- How to remove term from query before running it so we don't waste calls?

parser.translationTable = {
  ----- Simple text search

  o = "oracleTextSearch",
  oracle = "oracleTextSearch",

  t = "type_line",
  type = "type_line",

  ----- This needs special handling

  m = "mana_cost",
  mana = "mana_cost",

  ----- These are fields that can just be indexed
  kw = "keywords",
  keyword = "keywords",

  f = "legalities",
  format = "legalities",

  game = "availabilities",

  set = "sets"
}

parser.translationTable["in"] = "sets"

parser.tablizeOperationPairRe = vim.re.compile([[
  ret <- {| {:inverted: "-"? -> inv :} {:field: word :} {:operation: operation :} {:value: value :} space |}
  operation <- ":" / "=" / "<=" / ">=" / "<" / ">"

  value <- {word} / quote
  quote <- '"' {~ ((word/nonWord space)* / '""' -> '"') ~} '"'
  word <- [_%w~.-]+
  nonWord <- [][)(}{:|+!]+
  space <- %s*
]], { inv = function(_) return true end })

local makePair = function(operationPair)
  local queryPart = parser.tablizeOperationPairRe:match(operationPair)
  queryPart.string = operationPair

  return queryPart
end

local makeName = function(t)
  t.value = t.value:lower()
  t.compare = function(self, oracleObject)
    return oracleObject.nameSearch:find(self.value, 1, true) ~= nil
  end
  return t
end

local deps = {
  makePair = makePair,
  makeName = makeName,
}

parser.re = vim.re.compile([[
  query <- {| branch (or branch)* |}

  --balanced <- "(" ([^()] / balanced)* ")"

  branch <- (!or queryPart)+ -> {}
  or <- ("or" space)+

  queryPart <- space (namePart / operationPair)
  namePart <- "-"? value space !operation -> makeName

  operationPair <- "-"? word operation value space -> makePair

  operation <- ":" / "=" / "<=" / ">=" / "<" / ">" / "!="

  value <- {word} / quote
  quote <- '"' {~ ((word/nonWord space)* / '""' -> '"') ~} '"'
  word <- [_%w~.-]+
  nonWord <- [][)(}{:|+!]+
  space <- %s*
]], deps)

parser.match = parser.re.match

return parser
