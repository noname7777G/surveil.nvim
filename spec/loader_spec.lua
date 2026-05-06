local busted = require('busted')
local loader = require('lua.surveil').loader

busted.describe("Stat evaluation", function()
  local powers = {
    [[x]],
    [[*]],
    [[f]],
    [[* + 1]],
    [[X + 2]],
    [[x + 3]],
    [[4]],
    [[5]],
    [[15]],
  }
  local expectedResults = {
    0, 0, 0, 1, 2, 3, 4, 5, 15
  }
  for i, stat in ipairs(powers) do
    busted.assert.are.equal(expectedResults[i], loader.evaluatePT(stat))
  end
end)
