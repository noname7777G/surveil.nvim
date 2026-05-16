-- Use this as a model for other comparison units

require('card')

local color = {}

local file = io.open("./data/colorRelationships.json", "r")

local json = ""
if file then
  json = file:read()
end

color.relationshipTable = vim.json.decode(json)

----- Translation information ----------------------------------
-- These are used in the parser to form queries.

-- Define shorthand here, the RHS should be the name of the field the relavent data is in.
color.alias = {
  c = "colors",
  color = "colors",
  id = "color_identity",
  identity = "color_identity",
}

color.operationTranslation = {
  color = {},
  color_identity = {}
}

color.operationTranslation.color[":"] = ">="
color.operationTranslation.color_identity[":"] = "<="

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
