local Set = require('Set')

local colors = {
  "B",
  "G",
  "R",
  "U",
  "W",
  "BG",
  "BR",
  "BU",
  "BW",
  "GR",
  "GU",
  "GW",
  "RU",
  "RW",
  "UW",
  "BGR",
  "BGU",
  "BGW",
  "BRU",
  "BRW",
  "BUW",
  "GRU",
  "GRW",
  "GUW",
  "RUW",
  "BGRU",
  "BGRW",
  "BGUW",
  "BRUW",
  "GRUW",
  "BGRUW",
}

local colorRelationshipTable = {}
for _, queryColor in ipairs(colors) do
  colorRelationshipTable[queryColor] = {}

  local queryColorTable = {}
  queryColor:upper():gsub(".", function(c) table.insert(queryColorTable, c) end) --convert user string to table
  local queryColorSet = Set(queryColorTable)

  for _, cardColor in ipairs(colors) do
    local cardColorTable = {}
    cardColor:upper():gsub(".", function(c) table.insert(cardColorTable, c) end) --convert user string to table
    local cardColorSet = Set(cardColorTable)

    local symDiffCount = queryColorSet.symmetric_difference(cardColorSet).size

    if symDiffCount == 0 then
      colorRelationshipTable[queryColor][cardColor] = 0
    elseif queryColorSet.is_superset(cardColorSet) then
      colorRelationshipTable[queryColor][cardColor] = 1
    elseif cardColorSet.is_superset(queryColorSet) then
      colorRelationshipTable[queryColor][cardColor] = -1
    else
      colorRelationshipTable[queryColor][cardColor] = nil
    end
  end
end

local json = vim.json.encode(colorRelationshipTable)

local file = io.open("colorRelationships.json", "a")

if file then
  file:write(json)
end
