local utils = require 'utils'
local set = require 'Set'

---@class queryPair
---@field public inverted boolean
---@field public field string
---@field public operation string
---@field public value string

local compareNumber = function(self, oracleObject)
  local oracleObjectValue = utils.evaluatePT(oracleObject[self.field])

  local result
  if self.operation == "=" or self.operation == ":" then
    result = oracleObjectValue == self.value
  elseif self.operation == "<=" then
    result = oracleObjectValue <= self.value
  elseif self.operation == ">=" then
    result = oracleObjectValue >= self.value
  elseif self.operation == "<" then
    result = oracleObjectValue < self.value
  elseif self.operation == ">" then
    result = oracleObjectValue > self.value
  end

  if self.inverted then
    return not result
  else
    return result
  end
end

local compareText = function(self, oracleObject)
  local queryValue

  if type(self.value) == "string" then
    queryValue = self.value:lower()
  elseif type(self.value) == "number" then
    queryValue = self.value
  end

  local fieldValue = string.lower(oracleObject[self.field] or "")

  local result

  if self.operation == "=" then
    result = fieldValue == queryValue
  elseif self.operation == ":" then
    result = fieldValue:find(queryValue, 1, true)
  elseif self.operation == "<=" or self.operation == "<" then
    return true
  elseif self.operation == ">=" then
    result = fieldValue:find(queryValue, 1, true)
  elseif self.operation == ">" then
    result = fieldValue ~= queryValue and fieldValue:find(queryValue, 1, true)
  end

  if self.inverted then
    return not result
  else
    return result
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
  artiface = { "W", "U", "B", "R" },

  c = {},
  colorless = {},
}

local compareColors = function(self, oracleObject)
  local operation = self.operation
  local field = self.field
  local value = self.value

  local oracleObjectColors = oracleObject[field]

  local result

  if operation == "=" then
    result = value.symmetric_difference(oracleObjectColors).size == 0
  elseif operation == ":" then
    if field == "colors" then
      if value.size == 0 then
        result = oracleObjectColors.size == 0
      else
        if oracleObjectColors then
          result = value.is_superset(oracleObjectColors)
        else
          result = false
        end
      end
    else --self.field == "color_identity"
      result = oracleObjectColors.is_superset(value)
    end
  elseif operation == "<=" then
    result = value.is_superset(oracleObjectColors)
  elseif operation == ">=" then
    result = oracleObjectColors.is_superset(value)
  elseif operation == "<" then
    if value.symmetric_difference(oracleObjectColors).size > 0 then
      result = oracleObjectColors.is_superset(value)
    else
      result = false
    end
  else --operation == ">"
    if value.symmetric_difference(oracleObjectColors).size > 0 then
      result = value.is_superset(oracleObjectColors)
    else
      result = false
    end
  end

  if self.inverted then
    return not result
  else
    return result
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

  e = "set",
  edition = "set",
  s = "set",

  f = "legalities",
  format = "legalities",

  pow = "power",
  tou = "toughness",
  loy = "loyalty",

  game = "availabilities",
}

local functionKey = {
  oracle_text = compareText,
  set = compareText,
  type_line = compareText,

  keywords = function(self, oracleObject)
    for _, v in pairs(oracleObject[self.field]) do
      if v:upper() == self.value:upper() then
        return true ~= self.inverted
      end
    end
    return false ~= self.inverted
  end,

  availabilities = function(self, oracleObject)
    return oracleObject.availabilities[self.value]
  end,

  legalities = function(self, oracleObject)
    local v = oracleObject["legalities"][self.value]
    return (v == "legal" or v == "restricted") ~= self.inverted
  end,

  mana_cost = compareManaCost,

  cmc = compareNumber,
  power = compareNumber,
  toughness = compareNumber,
  loyalty = compareNumber,
  defense = compareNumber,
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
      t.compare = compareColors
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
  subQuery <- {| (namePart / operationPair)* |}

  namePart <- (value space !operation)

  operationPair <- {| {:inverted: "-"? -> inverted:} {:field: word :} {:operation: operation :} {:value: value :} space|} -> attachFunction

  operation <- (":" / "=" / "<=" / ">=" / "<" / ">")

  value <- {word} / quote
  quote <- '"' {~ ((word space)* / '""' -> '"') ~} '"'
  word <- [_%w-~.][_%w-~.]*
  space <- %s*
]], deps)
