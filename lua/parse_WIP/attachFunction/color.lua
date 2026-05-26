-- Use this as a model for other comparison units

require('card')
local number = require 'number'

local color = {}

local file = io.open("./data/colorRelationships.json", "r")

local json = ""
if file then
  json = file:read()
  file:close()
end

color.relationshipTable = vim.json.decode(json)

file = io.open("./data/colorNames.json", "r")

if file then
  json = file:read()
  file:close()
end

color.nameTable = vim.json.decode(json)

----- Translation information ----------------------------------
-- These are used in the parser to form queries.

-- Define shorthand here, the RHS should be the name of the field the relevant data is in.
color.alias = {
  c = "colors",
  color = "colors",
  id = "color_identity",
  identity = "color_identity",
}

-- This is where all the inelegant logic lives.
color.preProc = {
  colors = function(queryPart)
    local valueNumber = tonumber(queryPart.value)

    if valueNumber then
      queryPart.value = valueNumber

      if queryPart.field == "colors" then
        queryPart.field = "colorsCount"
      else
        queryPart.field = "colorIdentityCount"
      end

      return
    else
      queryPart.value = queryPart.value:lower()

      queryPart.value = color.nameTable[queryPart.value] or queryPart.value

      if not color.relationshipTable[queryPart.value] then

      end
    end
  end,

  color_identity = color.preProc.colors,
}

-- Define operator overloads here.
color.operationTranslation = {
  color = {},
  color_identity = {},
  colorsCount = {},
  colorIdentityCount = {},
}
color.operationTranslation.color[":"] = ">="
color.operationTranslation.color_identity[":"] = "<="
color.operationTranslation.colorsCount[":"] = "="
color.operationTranslation.colorIdentityCount[":"] = "="

-- LHS should be everything on the RHS of the alias table and anything preProc changes the field to.
-- RHS should be the name of the relevant module.
-- Typically, this will be the module this table is defined in but certain special operations may want to borrow logic from other modules.
color.functionKey = {
  colors = color,
  color_identity = color,
  colorsCount = number,
  colorIdentityCount = number,
}

----- Comparison functions -------------------------------------
-- The actual functions that will be run to compare cards to the queryPart.
-- Must ALWAYS return true or false, never nil or some other value.
-- Not every operation has to have a field.

---@param oracleObject card
color["="] = function(self, oracleObject)
  local relationship = color.relationshipTable[self.value][oracleObject[self.field]]
  if relationship then
    return relationship == 0
  else
    return false
  end
end

---@param oracleObject card
color[">="] = function(self, oracleObject)
  local relationship = color.relationshipTable[self.value][oracleObject[self.field]]
  if relationship then
    return relationship >= 0
  else
    return false
  end
end

---@param oracleObject card
color["<="] = function(self, oracleObject)
  local relationship = color.relationshipTable[self.value][oracleObject[self.field]]
  if relationship then
    return relationship <= 0
  else
    return false
  end
end

---@param oracleObject card
color[">"] = function(self, oracleObject)
  local relationship = color.relationshipTable[self.value][oracleObject[self.field]]
  if relationship then
    return relationship > 0
  else
    return false
  end
end

---@param oracleObject card
color["<"] = function(self, oracleObject)
  local relationship = color.relationshipTable[self.value][oracleObject[self.field]]
  if relationship then
    return relationship < 0
  else
    return false
  end
end

---@param oracleObject card
color["!="] = function(self, oracleObject)
  local relationship = color.relationshipTable[self.value][oracleObject[self.field]]
  if relationship then
    return relationship ~= 0
  else
    return true
  end
end

return color
