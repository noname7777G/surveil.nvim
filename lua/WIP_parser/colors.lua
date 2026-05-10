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
  return colors.relationshipTable[self.value][oracleObject[self.field]] == 0
end

---@param oracleObject card
colors[">="] = function(self, oracleObject)
  return colors.relationshipTable[self.value][oracleObject[self.field]] >= 0
end

---@param oracleObject card
colors["<="] = function(self, oracleObject)
  return colors.relationshipTable[self.value][oracleObject[self.field]] <= 0
end

---@param oracleObject card
colors[">"] = function(self, oracleObject)
  return colors.relationshipTable[self.value][oracleObject[self.field]] > 0
end

---@param oracleObject card
colors["<"] = function(self, oracleObject)
  return colors.relationshipTable[self.value][oracleObject[self.field]] < 0
end

return colors
