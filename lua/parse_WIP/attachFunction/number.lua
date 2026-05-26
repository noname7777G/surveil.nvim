local number = {}

number.alias = {
  mv = "cmc",
  manavalue = "cmc",

  pow = "evaluatedPower",
  power = "evaluatedPower",
  tou = "evaluatedToughness",
  toughness = "evaluatedToughness",
  loy = "evaluatedLoyalty",
  loyalty = "evaluatedLoyalty",
  defense = "evaluatedDefense",
}

number.preProc = {
  cmc = function(queryPart)
    local valueNumber = tonumber(queryPart.value)
    if valueNumber then
      queryPart.value = valueNumber
    else
      queryPart.value = nil
    end
  end,
  evaluatedPower = number.preProc.cmc,
  evaluatedToughness = number.preProc.cmc,
  evaluatedLoyalty = number.preProc.cmc,
  evaluatedDefense = number.preProc.cmc,
}

number.operationTranslation = {
  cmc = {},
  evaluatedPower = {},
  evaluatedToughness = {},
  evaluatedLoyalty = {},
  evaluatedDefense = {},
}
number.operationTranslation.cmc[":"] = "="
number.operationTranslation.evaluatedPower[":"] = "="
number.operationTranslation.evaluatedToughness[":"] = "="
number.operationTranslation.evaluatedLoyalty[":"] = "="
number.operationTranslation.evaluatedDefense[":"] = "="

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
number["!="] = function(self, oracleObject)
  return oracleObject[self.field] ~= self.value
end

return number
