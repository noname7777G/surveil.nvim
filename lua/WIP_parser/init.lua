local numbers = require 'numbers'
local colors = require 'colors'
local color_identity = require 'color_identity'

local inverted = function(s)
  return s:len() > 0
end

local default = function(_, _) return true end

local translationTable = {
  o = "oracle_text",
  oracle = "oracle_text",

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
  tou = "evaluatedToughness",
  loy = "evaluatedLoyalty",
  defense = "evaluatedDefense",

  game = "availabilities",
}

translationTable["in"] = "sets" --"in" is a lua keyword and must be added to the table this way.

local functionKey = {
  oracle_text = compareText,
  type_line = compareText,

  keywords = function(self, oracleObject)
    for _, v in pairs(oracleObject[self.field]) do
      if v:upper() == self.value:upper() then
        return true
      end
    end
    return false
  end,

  availabilities = function(self, oracleObject)
    return oracleObject.availabilities[self.value]
  end,

  sets = function(self, oracleObject)
    for _, v in ipairs(oracleObject.sets) do
      if v == self.value:lower() then
        return true
      end
    end
    return false
  end,

  legalities = function(self, oracleObject)
    local v = oracleObject.legalities[self.value]
    return (v == "legal" or v == "restricted")
  end,

  mana_cost = compareManaCost,

  cmc = numbers[self.field][self.operation],
  power = numbers[self.field][self.operation],
  toughness = numbers[self.field][self.operation],
  loyalty = numbers[self.field][self.operation],
  defense = numbers[self.field][self.operation],
}

local colorsToTable = function(s)
  local t = {}
  s:upper():gsub(".", function(c) table.insert(t, c) end) --convert user string to table
  return t
end

local attachFunction = function(t)
  t.field = translationTable[t.field] or t.field

  t.fullQuery = t.field .. t.operation .. t.value

  if t.inverted then
    t.fullQuery = "-" .. t.fullQuery
  end

  t.value = tonumber(t.value) or t.value

  if t.field == "colors" or t.field == "color_identity" then
    if type(t.value) == "string" then
      t.value = set(colorNames[string.lower(t.value or "")] or colorsToTable(t.value) or {})
      t.compare = _compareColors[t.field][t.operation]
    else
      t.compare = compareColorCount
    end
  end

  t.compare = t.compare or functionKey[t.field] or default

  return t
end

local deps = {
  attachFunction = attachFunction,
  inverted = inverted,
}

return vim.re.compile([[
  query <- {| branch (or branch)* |}

  --balanced <- "(" ([^()] / balanced)* ")"

  branch <- (!or queryPart)+ -> {}
  or <- ("or" space)+

  queryPart <- space (namePart / operationPair)
  namePart <- value space !operation

  operationPair <- {| {:inverted: "-"? -> inverted:} {:field: word :} {:operation: operation :} {:value: value :} space |} -> attachFunction

  operation <- ":" / "=" / "<=" / ">=" / "<" / ">"

  value <- {word} / quote
  quote <- '"' {~ ((word space)* / '""' -> '"') ~} '"'
  word <- [_%w-~.]+
  space <- %s*
]], deps)
