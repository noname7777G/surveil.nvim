local number = {}

number["="] = function(self, oracleObject)
  return oracleObject[self.field] == self.value
end
number["<="] = function(self, oracleObject)
  return oracleObject[self.field] <= self.value
end
number[">="] = function(self, oracleObject)
  return oracleObject[self.field] >= self.value
end
number["<"] = function(self, oracleObject)
  return oracleObject[self.field] < self.value
end
number[">"] = function(self, oracleObject)
  return oracleObject[self.field] > self.value
end

return number
