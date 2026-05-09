local emDash = "—1aljfojojfo©"

local chars = {}

local bytesRemaining = 0
local inMultiByteChar = false
for i = 1, #emDash, 1 do
  local byte = emDash:byte(i)

  if inMultiByteChar then
    chars.TEMP = chars.TEMP .. string.char(byte)

    bytesRemaining = bytesRemaining - 1

    if bytesRemaining <= 0 then
      inMultiByteChar = false
      chars[chars.TEMP] = true
      chars.TEMP = ""
    end
  elseif byte > 127 then
    inMultiByteChar = true
    if byte > 239 then
      bytesRemaining = 3
    elseif byte > 223 then
      bytesRemaining = 2
    else
      bytesRemaining = 1
    end

    chars.TEMP = string.char(byte)
  else
    chars[string.char(byte)] = true
  end
end
