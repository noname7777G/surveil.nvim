local simpleIndex = {}

simpleIndex.alias = {
  kw = "keywords",
  keyword = "keywords",

  f = "legalities",
  format = "legalities",

  game = "availabilities",

  set = "sets",
}
simpleIndex.alias["in"] = "sets" -- Lua keyword

simpleIndex.preProc = {
  keywords = function(queryPart)
    queryPart.value = queryPart.value:lower()
  end,
  legalities = simpleIndex.preProc.keywords,
  availabilities = simpleIndex.preProc.keywords,
  sets = simpleIndex.preProc.keywords,
}

simpleIndex.operationTable = {
  keywords = {},
  legalities = {},
  availabilities = {},
  sets = {},
}

simpleIndex.operationTable.keywords[":"] = "="
simpleIndex.operationTable.legalities[":"] = "="
simpleIndex.operationTable.availabilities[":"] = "="
simpleIndex.operationTable.sets[":"] = "="

---@param oracleObject card
simpleIndex["="] = function(self, oracleObject)
  return oracleObject[self.field][self.value] ~= nil
end

return simpleIndex
