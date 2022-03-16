
local numberBlock = {}
numberBlock.__index = numberBlock

function numberBlock.new(collider, number)
  local self = setmetatable({}, numberBlock)
  self.number = number
  self.collider = collider
  return self
end

function numberBlock:destroy()
    self.collider:destroy()
end

return numberBlock