--[[
        X hoger -> naar rechts
        Y hoger -> naar boven
        Z lager -> naar voren
     --]] pointer = require 'pointer'
numberBlock = require 'numberBlock'

local game = {}
game.__index = game

function game.new()
    local self = setmetatable({}, game)
    self.numbersVisible = true
    return self
end

function game:startRound()
    self.numbersVisible = true

    boxes = {}
    i = 0;
    for x = -0.25, 0.5, .25 do
        for y = .875, 1.25, .24999 do
            local box = world:newBoxCollider(x, y, -2 - y / 5, .25)
            i = i + 1
            local numberBlock = numberBlock.new(box, i)
            boxes[i] = numberBlock
        end
    end
end

function game:isRoundFinished() return next(boxes) == nil end

function game:onHit(numberBlock)
    debug(self.numbersVisible)
    if numberBlock.number == nextNeededNumber() then
        local removedbox = table.remove(boxes, 1)
        removedbox:destroy()
        self.numbersVisible = false
    else

    end
end

function game:areNumbersVisible()
    return self.numbersVisible
end


function lovr.load()
    world = lovr.physics.newWorld()
    world:setLinearDamping(.01)
    world:setAngularDamping(.005)
    world:setGravity(0, 0, 0)

    pointer:init({source = pointer.handWrapper.new("hand/left"), world = world})

    currentGame = game.new()
    currentGame:startRound()

    lovr.timer.step() -- Reset the timer before the first update

    shader = lovr.graphics.newShader('standard')
    shader:send('lovrExposure', 2)
end

function lovr.update(dt)
    text = ""

    pointer:update()
    world:update(dt)

    if lovr.headset.wasPressed("hand/left", "trigger") then
        local hit = pointer:getHit()
        if hit then
            for i, box in ipairs(boxes) do
                if box.collider == hit.collider then
                    currentGame:onHit(box)
                end
            end
        end
    end


    if currentGame:isRoundFinished() then currentGame:startRound() end
end

function lovr.draw()
    local hit = pointer:getHit()

    for i, hand in ipairs(lovr.headset.getHands()) do
        local position = vec3(lovr.headset.getPosition(hand))
        local direction = quat(lovr.headset.getOrientation(hand)):direction()

        lovr.graphics.setColor(1, 1, 1)
        lovr.graphics.sphere(position, .01)
        lovr.graphics.print(hand, position, 0.02)

        lovr.graphics.setColor(1, 0, 0)
        lovr.graphics.line(position, position + direction * 50)
    end

    for i, box in ipairs(boxes) do drawBox(box, hit) end

    lovr.graphics.setColor(0.7, 0.6, 0)
    debug(tostring(currentGame:areNumbersVisible()))

    drawDebug()
end

function nextNeededNumber() return boxes[next(boxes)].number end

function drawBox(numberbox, hit)
    if numberbox == nil then return end

    local box = numberbox.collider
    local x, y, z = box:getPosition()
    local boxColor = (hit and hit.collider == box) and {0.50, 0.100, 0.200} or
                         {0.20, 0.70, 0.170}
    lovr.graphics.setColor(boxColor)
    lovr.graphics.cube('fill', x, y, z, .25, box:getOrientation())

 
    if currentGame:areNumbersVisible() then
        lovr.graphics.setColor(0.7, 0.6, 0)
        lovr.graphics.print(numberbox.number, x, y, z + 0.15, 0.25)
    end

end

function debug(text) debugText = text end

function drawDebug()
    if debugText ~= nil then
        lovr.graphics.setColor(0.7, 0.6, 0)
        lovr.graphics.print("debug: " .. debugText, -1, 3.5, -3, 0.5, 0)
    end
end
