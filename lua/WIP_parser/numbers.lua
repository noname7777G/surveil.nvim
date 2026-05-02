local number = {}

local operations = {}

operations["="] = function(self, oracleObject)
  return oracleObject[self.field] == self.value
end
operations[":"] = operations["="]
operations["<="] = function(self, oracleObject)
  return oracleObject[self.field] <= self.value
end
operations[">="] = function(self, oracleObject)
  return oracleObject[self.field] >= self.value
end
operations["<"] = function(self, oracleObject)
  return oracleObject[self.field] < self.value
end
operations[">"] = function(self, oracleObject)
  return oracleObject[self.field] > self.value
end

number.evaluatedPower = operations
number.evaluatedToughness = operations
number.evaluatedLoyalty = operations
number.evaluatedDefense = operations

return number
