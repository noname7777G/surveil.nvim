local parser = require 'parser'

--TODO: memoize results for future queries so that we do not have to perform redundant queries.

---@class querySession
---@field primaryTable card[]
local M = {}

---@param list card[]
M.setPrimaryTable = function(list)
  M.primaryTable = list
end

---comment
---@param list card[]?
---@param query string?
M.queryTable = function(list, query)
  if not list then return nil end
  if not query or query == "" then return list end

  local parsedQuery = parser:match(query)
  local results = {}

  for _, oracleObject in pairs(list) do
    local addObject = false

    for _, branch in pairs(parsedQuery) do
      for _, qObject in pairs(branch) do
        if not (qObject:compare(oracleObject) ~= qObject.inverted) then
          addObject = false
          break
        end

        addObject = true
      end
    end

    if addObject then
      table.insert(results, oracleObject)
    end
  end

  return results
end

---@param query string?: The query to run. For a full list of currently implemented syntax, please see README.md. Returns all cards if empty or nil.
---@return card[]?: The results of the query. Will return an empty table if there are no results. Will return nil if the primaryTable is not set.
M.query = function(query)
  if not M.primaryTable then return nil end
  if not query or query == "" then return M.primaryTable end

  local parsedQuery = parser:match(query)
  if not parsedQuery then return M.primaryTable end
  local results = {}

  for _, oracleObject in pairs(M.primaryTable) do
    local addObject = false
    for _, branch in pairs(parsedQuery) do
      for _, qObject in pairs(branch) do
        if not (qObject:compare(oracleObject) ~= qObject.inverted) then
          addObject = false
          break
        end

        addObject = true
      end

      if addObject then
        table.insert(results, oracleObject)
      end
    end
  end

  return results
end

return M
