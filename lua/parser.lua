local utils = require 'utils'
local set = require 'Set'

---@class queryPair
---@field public inverted boolean
---@field public field string
---@field public operation string
---@field public value string

local compareNumber = function(self, oracleObject)
  local oracleObjectValue = utils.evaluatePT(oracleObject[self.field])

  if self.operation == "=" or self.operation == ":" then
    return oracleObjectValue == self.value
  elseif self.operation == "<=" then
    return oracleObjectValue <= self.value
  elseif self.operation == ">=" then
    return oracleObjectValue >= self.value
  elseif self.operation == "<" then
    return oracleObjectValue < self.value
  elseif self.operation == ">" then
    return oracleObjectValue > self.value
  end
end

local compareText = function(self, oracleObject)
  if not oracleObject[self.field] then
    return false
  end

  local queryValue = tostring(self.value):lower()

  local fieldValue = oracleObject[self.field]:lower()

  if self.operation == "=" then
    return fieldValue == queryValue
  elseif self.operation == ":" then
    if fieldValue:find(queryValue, 1, true) then
      return true
    else
      return false
    end
  elseif self.operation == "<=" or self.operation == "<" then
    return true
  elseif self.operation == ">=" then
    if fieldValue:find(queryValue, 1, true) then
      return true
    else
      return false
    end
  elseif self.operation == ">" then
    if fieldValue ~= queryValue and fieldValue:find(queryValue, 1, true) then
      return true
    else
      return false
    end
  end
end

local compareManaCost = function(self, oracleObject)

end

local colorNames = {
  azorius = { "W", "U" },
  dimir = { "B", "U" },
  rakdos = { "R", "B" },
  gruul = { "R", "G" },
  selesnya = { "W", "G" },
  orzhov = { "W", "B" },
  izzet = { "U", "R" },
  golgari = { "B", "G" },
  boros = { "W", "R" },
  simic = { "U", "G" },

  lorehold = { "R", "W" },
  prismari = { "R", "U" },
  quandrix = { "G", "U" },
  silverquil = { "W", "B" },
  witherbloom = { "G", "B" },

  bant = { "W", "G", "U" },
  esper = { "U", "W", "B" },
  grixis = { "B", "R", "U" },
  jund = { "R", "B", "G" },
  naya = { "G", "R", "W" },
  abzan = { "W", "B", "G" },
  jeskai = { "U", "R", "W" },
  sultai = { "B", "G", "U" },
  mardu = { "R", "W", "B" },
  temur = { "G", "R", "U" },

  obscura = { "U", "W", "B" },
  maestros = { "B", "R", "U" },
  riveteers = { "R", "G", "B" },
  cabaretti = { "G", "R", "W" },
  brokers = { "W", "G", "U" },

  glint = { "U", "B", "R", "G" },
  dune = { "B", "R", "G", "W" },
  ink = { "R", "G", "W", "U" },
  witch = { "G", "W", "U", "B" },
  yore = { "W", "U", "B", "R" },

  chaos = { "B", "R", "G", "U" },
  aggression = { "B", "R", "G", "W" },
  altruism = { "G", "W", "U", "R" },
  growth = { "G", "W", "U", "B" },
  artifice = { "W", "U", "B", "R" },

  c = {},
  colorless = {},
}

local _compareColors = {
  colors = {},
  color_identity = {}
}

_compareColors.colors["="] = function(self, oracleObject)
  return (self.value.symmetric_difference(oracleObject.colors).size == 0)
end

_compareColors.color_identity["="] = function(self, oracleObject)
  return (self.value.symmetric_difference(oracleObject.color_identity).size == 0)
end

_compareColors.colors[":"] = function(self, oracleObject)
  if self.value.size == 0 then
    return oracleObject.colors.size == 0
  else
    return self.value.is_superset(oracleObject.colors)
  end
end

_compareColors.color_identity[":"] = function(self, oracleObject)
  return (oracleObject.color_identity.is_superset(self.value))
end

_compareColors.colors[">="] = function(self, oracleObject)
  return (self.value.is_superset(oracleObject.colors))
end

_compareColors.color_identity[">="] = function(self, oracleObject)
  return (self.value.is_superset(oracleObject.color_identity))
end

_compareColors.colors["<="] = function(self, oracleObject)
  return (oracleObject.colors.is_superset(self.value))
end

_compareColors.color_identity["<="] = function(self, oracleObject)
  return (oracleObject.color_identity.is_superset(self.value))
end

_compareColors.colors["<"] = function(self, oracleObject)
  if self.value.symmetric_difference(oracleObject.colors).size > 0 then
    return oracleObject.colors.is_superset(self.value)
  else
    return false
  end
end

_compareColors.color_identity["<"] = function(self, oracleObject)
  if self.value.symmetric_difference(oracleObject.color_identity).size > 0 then
    return oracleObject.color_identity.is_superset(self.value)
  else
    return false
  end
end

_compareColors.colors[">"] = function(self, oracleObject)
  if self.value.symmetric_difference(oracleObject.colors).size > 0 then
    return self.value.is_superset(oracleObject.colors)
  else
    return false
  end
end

_compareColors.color_identity[">"] = function(self, oracleObject)
  if self.value.symmetric_difference(oracleObject.color_identity).size > 0 then
    return self.value.is_superset(oracleObject.color_identity)
  else
    return false
  end
end

local compareColorCount = function(self, oracleObject)
  local objectColorCount = oracleObject[self.field].size

  if self.operation == "=" or self.operation == ":" then
    return self.value == objectColorCount
  elseif self.operation == "<=" then
    return self.value >= objectColorCount
  elseif self.operation == ">=" then
    return self.value <= objectColorCount
  elseif self.operation == "<" then
    return self.value > objectColorCount
  else -- self.operation == ">"
    return self.value < objectColorCount
  end
end

local inverted = function(s)
  return s:len() > 0
end

local default = function(_, _) return true end

local translationTable = {
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

  power = "evaluatedPower",
  pow = "evaluatedPower",
  toughness = "evaluatedToughness",
  tou = "evaluatedToughness",
  loyalty = "evaluatedLoyalty",
  loy = "evaluatedLoyalty",

  game = "availabilities",
}

translationTable["in"] = "sets" --"in" is a lua keyword and must be added to the table this way.

local functionKey = {
  oracleTextSearch = compareText,
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
    return oracleObject.sets[self.value]
  end,

  legalities = function(self, oracleObject)
    local v = oracleObject.legalities[self.value]
    return (v == "legal" or v == "restricted")
  end,

  mana_cost = compareManaCost,

  cmc = compareNumber,
  evaluatedPower = compareNumber,
  evaluatedToughness = compareNumber,
  evaluatedLoyalty = compareNumber,
  evaluatedDefense = compareNumber,
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
  nameFunction = function(t)
    t.value = t.value:lower()
    t.compare = function(self, oracleObject)
      return not not oracleObject.nameSearch:find(self.value, 1, true)
    end
    return t
  end
}

return vim.re.compile([[
  query <- {| branch (or branch)* |}

  --balanced <- "(" ([^()] / balanced)* ")"

  branch <- (!or queryPart)+ -> {}
  or <- ("or" space)+

  queryPart <- space (namePart / operationPair)
  namePart <- {| {:inverted: "-"? -> inverted:} {:value: value:} space !operation |} -> nameFunction

  operationPair <- {| {:inverted: "-"? -> inverted:} {:field: word :} {:operation: operation :} {:value: value :} space |} -> attachFunction

  operation <- ":" / "=" / "<=" / ">=" / "<" / ">"

  value <- {word} / quote
  quote <- '"' {~ ((word/nonWord space)* / '""' -> '"') ~} '"'
  word <- [_%w~.-]+
  nonWord <- [][)(}{:|+!]+
  space <- %s*
]], deps)
