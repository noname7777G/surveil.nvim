local color_identity = {}

color_identity["="] = function(self, oracleObject)
  return (self.value.symmetric_difference(oracleObject.color_identity).size == 0)
end

color_identity[":"] = function(self, oracleObject)
  return (oracleObject.color_identity.is_superset(self.value))
end

color_identity[">="] = function(self, oracleObject)
  return (self.value.is_superset(oracleObject.color_identity))
end

color_identity["<="] = function(self, oracleObject)
  return (oracleObject.color_identity.is_superset(self.value))
end

color_identity["<"] = function(self, oracleObject)
  if self.value.symmetric_difference(oracleObject.color_identity).size > 0 then
    return oracleObject.color_identity.is_superset(self.value)
  else
    return false
  end
end

color_identity[">"] = function(self, oracleObject)
  if self.value.symmetric_difference(oracleObject.color_identity).size > 0 then
    return self.value.is_superset(oracleObject.color_identity)
  else
    return false
  end
end

return color_identity
