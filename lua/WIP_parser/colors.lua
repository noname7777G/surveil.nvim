local colors = {}

colors["="] = function(self, oracleObject)
  return (self.value.symmetric_difference(oracleObject.colors).size == 0)
end

colors[":"] = function(self, oracleObject)
  if self.value.size == 0 then
    return oracleObject.colors.size == 0
  else
    return self.value.is_superset(oracleObject.colors)
  end
end

colors[">="] = function(self, oracleObject)
  return (self.value.is_superset(oracleObject.colors))
end

colors["<="] = function(self, oracleObject)
  return (oracleObject.colors.is_superset(self.value))
end

colors["<"] = function(self, oracleObject)
  if self.value.symmetric_difference(oracleObject.colors).size > 0 then
    return oracleObject.colors.is_superset(self.value)
  else
    return false
  end
end

colors[">"] = function(self, oracleObject)
  if self.value.symmetric_difference(oracleObject.colors).size > 0 then
    return self.value.is_superset(oracleObject.colors)
  else
    return false
  end
end

return colors
