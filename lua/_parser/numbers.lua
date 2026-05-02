local compareNumber = function(self, oracleObject)
  local oracleObjectValue = utils.evaluatePT(oracleObject[self.field])

  if self.operation == "=" or self.operation == ":" then
    return oracleObjectValue == self.value
  elseif self.operation == "<=" then
    return oracleObjectValue <= self.value
  elseif self.operation == ">=" then
    return oracleObjectValue >= self.value
  elseif self.operation == "<" then
    return oracleObjectValue < self.value
  elseif self.operation == ">" then
    return oracleObjectValue > self.value
  end
end
