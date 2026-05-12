require('card')

local colors = {}

local file = io.open("./data/colorRelationships.json", "r")

local json = ""
if file then
  json = file:read()
end

colors.relationshipTable = vim.json.decode(json)

---@param oracleObject card
colors["="] = function(self, oracleObject)
  local relationship = colors.relationshipTable[self.value][oracleObject[self.field]]
  if relationship then
    return relationship == 0
  else
    return false
  end
end

---@param oracleObject card
colors[">="] = function(self, oracleObject)
  local relationship = colors.relationshipTable[self.value][oracleObject[self.field]]
  if relationship then
    return relationship >= 0
  else
    return false
  end
end

---@param oracleObject card
colors["<="] = function(self, oracleObject)
  local relationship = colors.relationshipTable[self.value][oracleObject[self.field]]
  if relationship then
    return relationship <= 0
  else
    return false
  end
end

---@param oracleObject card
colors[">"] = function(self, oracleObject)
  local relationship = colors.relationshipTable[self.value][oracleObject[self.field]]
  if relationship then
    return relationship > 0
  else
    return false
  end
end

---@param oracleObject card
colors["<"] = function(self, oracleObject)
  local relationship = colors.relationshipTable[self.value][oracleObject[self.field]]
  if relationship then
    return relationship < 0
  else
    return false
  end
end

return colors
