local utils = require'utils'
local set = require'Set'

local compareNumber = function (self, oracleObject)
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

local compareText = function (self, oracleObject)
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
  Azorius = {"W", "U"},       azorius = {"W", "U"},
  Dimir = {"B", "U"},         dimir = {"B", "U"},
  Rakdos = {"R", "B"},        rakdos = {"R", "B"},
  Gruul = {"R", "G"},         gruul = {"R", "G"},
  Selesnya = {"W", "G"},      selesnya = {"W", "G"},
  Orzhov = {"W", "B"},        orzhov = {"W", "B"},
  Izzet = {"U", "R"},         izzet = {"U", "R"},
  Golgari = {"B", "G"},       golgari = {"B", "G"},
  Boros = {"W", "R"},         boros = {"W", "R"},
  Simic = {"U", "G"},         simic = {"U", "G"},

  Lorehold = {"R", "W"},      lorehold = {"R", "W"},
  Prismari = {"R", "U"},      prismari = {"R", "U"},
  Quandrix = {"G", "U"},      quandrix = {"G", "U"},
  Silverquil = {"W", "B"},    silverquil = {"W", "B"},
  Witherbloom = {"G", "B"},   witherbloom = {"G", "B"},

  Bant = {"W", "G", "U"},         bant = {"W", "G", "U"},
  Esper = {"U", "W", "B"},        esper = {"U", "W", "B"},
  Grixis = {"B", "R", "U"},       grixis = {"B", "R", "U"},
  Jund = {"R", "B", "G"},         jund = {"R", "B", "G"},
  Naya = {"G", "R", "W"},         naya = {"G", "R", "W"},
  Abzan = {"W", "B", "G"},        abzan = {"W", "B", "G"},
  Jeskai = {"U", "R", "W"},       jeskai = {"U", "R", "W"},
  Sultai = {"B", "G", "U"},       sultai = {"B", "G", "U"},
  Mardu = {"R", "W", "B"},        mardu = {"R", "W", "B"},
  Temur = {"G", "R", "U"},        temur = {"G", "R", "U"},

  Obscura = {"U", "W", "B"},      obscura = {"U", "W", "B"},
  Maestros = {"B", "R", "U"},     maestros = {"B", "R", "U"},
  Riveteers = {"R", "G", "B"},    riveteers = {"R", "G", "B"},
  Cabaretti = {"G", "R", "W"},    cabaretti = {"G", "R", "W"},
  Brokers = {"W", "G", "U"},      brokers = {"W", "G", "U"},

  Glint = {"U", "B", "R", "G"},       glint = {"U", "B", "R", "G"},
  Dune = {"B", "R", "G", "W"},        dune = {"B", "R", "G", "W"},
  Ink = {"R", "G", "W", "U"},         ink = {"R", "G", "W", "U"},
  Witch = {"G", "W", "U", "B"},       witch = {"G", "W", "U", "B"},
  Yore = {"W", "U", "B", "R"},        yore = {"W", "U", "B", "R"},

  Chaos = {"B", "R", "G", "U"},       chaos = {"B", "R", "G", "U"},
  Aggression = {"B", "R", "G", "W"},  aggression = {"B", "R", "G", "W"},
  Altruism = {"G", "W", "U", "R"},    altruism = {"G", "W", "U", "R"},
  Growth = {"G", "W", "U", "B"},      growth = {"G", "W", "U", "B"},
  Artiface = {"W", "U", "B", "R"},    artiface = {"W", "U", "B", "R"},

  C = {},               c = {},
  Colorless = {},       colorless = {},
}

local compareColors = function (self, oracleObject)
  local operation = self.operation
  local field = self.field
  local value = self.value

  local oracleObjectColors = set(oracleObject[field])

  local result

  if operation == "=" then
    if value.symetric_difference(oracleObjectColors).items[1] then
      result = true
    else
      result = false
    end
  elseif operation == ":" then
    if field == "colors" then
      if value.size == 0 then
        result = value.size == oracleObjectColors.size
      else
        result = value.is_superset(oracleObjectColors)
      end
    else --self.field == "color_identity"
      result = oracleObjectColors.is_superset(value)
    end
  elseif operation == "<=" then
    result = value.is_superset(oracleObjectColors)
  elseif operation == ">=" then
    result = oracleObjectColors.is_superset(value)
  elseif operation == "<" then
    if value.symetric_difference(oracleObjectColors).items[1] then
      result = value.is_superset(oracleObjectColors)
    else
      result = false
    end
  else --operation == ">"
    if value.symetric_difference(oracleObjectColors).items[1] then
      result = oracleObjectColors.is_superset(value)
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

local compareColorCount = function (self, oracleObject)
  local objectColorCount = #(oracleObject[self.field] or {})

  if self.operation == "=" then
    return self.value == objectColorCount
  elseif self.operation == "<=" then
    return self.value <= objectColorCount
  elseif self.operation == ">=" then
    return self.value >= objectColorCount
  elseif self.operation == "<" then
    return self.value < objectColorCount
  else
    return self.value < objectColorCount
  end
end

local inverted = function (s)
  return s:len() > 0
end

local default = function(_, _) return true end

local translationTable = {
  o = "oracle_text", oracle = "oracle_text",

  kw = "keywords", keyword = "keywords",

  t = "type_line", type = "type_line",

  mv = "cmc", manavalue = "cmc",
  m = "mana_cost", mana = "mana_cost",

  c = "colors", color = "colors",
  id = "color_identity", identity = "color_identity",

  e = "set", edition = "set", s = "set",

  f = "legalities", format = "legalities",

  pow = "power", tou = "toughness", loy = "loyalty",

  game = "games",
}

local functionKey = {
  oracle_text = compareText,
  set = compareText,
  type_line = compareText,

  --colors = compareColor,
  --color_identity = compareColor,

  keywords = function(self, oracleObject)
    for _, v in pairs(oracleObject[self.field]) do
      if v:upper() == self.value:upper() then
        return true
      end
    end
    return false
  end,

  games = function(self, oracleObject)
    local ret
    for _, v in pairs(oracleObject["games"]) do
      ret = v == self.value
      if ret then break end
    end
    return ret
  end,

  legalities = function (self, oracleObject)
    local v = oracleObject["legalities"][self.value]
    return v == "legal" or v == "restricted"
  end,

  mana_cost = compareManaCost,

  cmc = compareNumber,
  power = compareNumber,
  toughness = compareNumber,
  loyalty = compareNumber,
  defense = compareNumber,
}

local colorsToTable = function (s)
  local t = {}
  s:upper():gsub(".",function(c) table.insert(t,c) end) --convert user string to table
  return t
end

local attachFunction = function (t)
  t.field = translationTable[t.field] or t.field

  t.fullQuery = t.field .. t.operation .. t.value

  if t.inverted then
    t.fullQuery = "-" .. t.fullQuery
  end

  t.value = tonumber(t.value) or t.value
  if t.field == "colors" or t.field == "color_identity" then
    if type(t.value) == "string" then
      t.value = Set(colorNames[t.value] or colorsToTable(t.value) or {})
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
