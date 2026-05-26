local modules = { -- ADD NEW MODULES HERE, DINGUS!!!
  "color",
  "number",
  "simpleIndex"
}

local merge = function(into, t)
  for k, v in pairs(t) do
    if into[k] then
      vim.print("Comparator warning: error merging table")
      vim.print(t)
      vim.print("into")
      vim.print(into)
      vim.print("Key '" .. k .. "' already exists as value '" .. tostring(into[k]) .. "'.")
      vim.print("Clobbering with value '" .. tostring(v) .. "'.")
    end

    into[k] = v
  end
end

local comparators = {}
comparators.alias = {}
comparators.operationTranslation = {}
comparators.preProc = {}
comparators.functionKey = {}

for _, v in pairs(modules) do
  local mod = require(v)
  merge(comparators.alias, mod.alias)
  merge(comparators.operationTranslation, mod.operationTranslation)
  merge(comparators.preProc, mod.preProc)
  merge(comparators.functionKey, mod.functionKey)
end


local attachFunction = function(queryObject)
  queryObject.valid = false
  queryObject.field = queryObject.field:lower()

  queryObject.field = comparators.alias[queryObject.field] or queryObject.field

  comparators.preProc[queryObject.field](queryObject)

  queryObject.operation = comparators.operationTranslation[queryObject.field][queryObject.operation] or
      queryObject.operation

  queryObject.compare = comparators.functionKey[queryObject.field]
      [queryObject.operation]

  if queryObject.compare then
    queryObject.valid = true
  end
end

return attachFunction
