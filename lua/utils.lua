local M = {}

M.evaluatePT = function (value)
  local try = tonumber(value or 0)

  if try then
    return try
  elseif type(value) == "string" then
    local repl = value:gsub("[^%d+-]", "0")
    return vim.fn.eval(repl)
  else
    return 0
  end
end

return M
