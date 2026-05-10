local numbers = require 'numbers'
local colors = require 'colors'

local parser = {}

parser.termIgnored = function(_, _) return true end --TODO: make this inform the user of their error.

parser.translationTable = {
  o = "oracleTextSearch",
  oracle = "oracleTextSearch",

  kw = "keywords",
  keyword = "keywords",

  t = "type_line",
  type = "type_line",

  mv = "cmc",
  manavalue = "cmc",
  m = "mana_cost",
  mana = "mana_cost",

  c = "colors",
  color = "colors",
  id = "color_identity",
  identity = "color_identity",

  f = "legalities",
  format = "legalities",

  pow = "evaluatedPower",
  power = "evaluatedPower",
  tou = "evaluatedToughness",
  toughness = "evaluatedToughness",
  loy = "evaluatedLoyalty",
  loyalty = "evaluatedLoyalty",
  defense = "evaluatedDefense",

  game = "availabilities",

  set = "sets"
}

parser.translationTable["in"] = "sets"

parser.colonTranslation = {
  evaluatedPower = "=",
  evaluatedToughness = "=",
  evaluatedLoyalty = "=",
  evaluatedDefense = "=",

  cmc = "=",

}

parser.functionGroupKey = {
  evaluatedPower = numbers,
  evaluatedToughness = numbers,
  evaluatedLoyalty = numbers,
  evaluatedDefense = numbers,

  cmc = numbers,

}

parser.tablizeOperationPairRe = vim.re.compile([[
  ret <- {| {:inverted: "-"? :} {:field: word :} {:operation: operation :} {:value: value :} space |}
  operation <- ":" / "=" / "<=" / ">=" / "<" / ">"

  value <- {word} / quote
  quote <- '"' {~ ((word/nonWord space)* / '""' -> '"') ~} '"'
  word <- [_%w~.-]+
  nonWord <- [][)(}{:|+!]+
  space <- %s*
]])

local attachFunction = function(operationPair)
  local queryPart = parser.tablizeOperationPairRe:match(operationPair)
  queryPart.string = operationPair

  queryPart.field = parser.translationTable[queryPart.field]
  if not queryPart.field then
    queryPart.compare = parser.termIgnored
    return queryPart
  end

  queryPart.operation = parser.colonTranslation[queryPart.field] or queryPart.operation

  queryPart.compare = parser.functionGroupKey[queryPart.field]
  if not queryPart.compare then
    queryPart.compare = parser.termIgnored
    return queryPart
  end

  queryPart.compare = queryPart.compare[queryPart.operation]
  if not queryPart.compare then
    queryPart.compare = parser.termIgnored
    return queryPart
  end

  return queryPart
end

local nameFunction = function(t)
  t.value = t.value:lower()
  t.compare = function(self, oracleObject)
    return oracleObject.nameSearch:find(self.value, 1, true) ~= nil
  end
  return t
end

local deps = {
  attachFunction = attachFunction,
  nameFunction = nameFunction,
}

parser.re = vim.re.compile([[
  query <- {| branch (or branch)* |}

  --balanced <- "(" ([^()] / balanced)* ")"

  branch <- (!or queryPart)+ -> {}
  or <- ("or" space)+

  queryPart <- space (namePart / operationPair)
  namePart <- "-"? value space !operation -> nameFunction

  operationPair <- "-"? word operation value space -> attachFunction

  operation <- ":" / "=" / "<=" / ">=" / "<" / ">"

  value <- {word} / quote
  quote <- '"' {~ ((word/nonWord space)* / '""' -> '"') ~} '"'
  word <- [_%w~.-]+
  nonWord <- [][)(}{:|+!]+
  space <- %s*
]], deps)

parser.match = parser.re.match

return parser
