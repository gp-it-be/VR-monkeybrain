--[[
        X hoger -> naar rechts
        Y hoger -> naar boven
        Z lager -> naar voren
     --]] pointer = require 'pointer'
numberBlock = require 'numberBlock'

-- #region Game
local game = {}
game.__index = game

function game.new()
    local self = setmetatable({}, game)
    self.numbersVisible = true
    self.mistakes = 0
    self.score = 0
    self.round = 0
    return self
end

function game:startRound()
    self.numbersVisible = true
    self.round = self.round + 1

    local usedCoordinates = {}

    boxes = {}

    local placedBlocks = 0
    while placedBlocks <= self.round do

        local r = math.random(0, 3)
        local c = math.random(0, 4)
        if usedCoordinates[r .. "," .. c] == nil then
            usedCoordinates[r .. "," .. c] = true
            placedBlocks = placedBlocks + 1

            x = -0.25 + c * 0.25
            y = .875 + r * 0.25
            local box = world:newBoxCollider(x, y, -2.5, .25)
            local numberBlock = numberBlock.new(box, placedBlocks)
            boxes[placedBlocks] = numberBlock
        end
    end
end

function game:isRoundFinished() return next(boxes) == nil end

function game:onHit(numberBlock)
    if numberBlock.number == nextNeededNumber() then
        local removedbox = table.remove(boxes, 1)
        removedbox:destroy()
        self.numbersVisible = false
        self.score = self.score + numberBlock.number
    else
        self.mistakes = self.mistakes + 1
    end
end

function game:areNumbersVisible() return self.numbersVisible end
-- #endregion Game

function lovr.load()
    math.randomseed(os.time())

    world = lovr.physics.newWorld()
    world:setLinearDamping(.01)
    world:setAngularDamping(.005)
    world:setGravity(0, 0, 0)

    leftPointer = pointer.new({
        source = pointer.handWrapper.new("hand/left"),
        world = world
    })
    rightPointer = pointer.new({
        source = pointer.handWrapper.new("hand/right"),
        world = world
    })

    currentGame = game.new()
    currentGame:startRound()

    lovr.timer.step() -- Reset the timer before the first update

    shader = lovr.graphics.newShader('standard')
    shader:send('lovrExposure', 2)
end

function lovr.update(dt)
    text = ""

    leftPointer:update()
    rightPointer:update()
    world:update(dt)

    local hit
    if lovr.headset.wasPressed("hand/left", "trigger") then
        hit = leftPointer:getHit()
    else
        if lovr.headset.wasPressed("hand/right", "trigger") then
            hit = rightPointer:getHit()
        end
    end
    if hit then
        for i, box in ipairs(boxes) do
            if box.collider == hit.collider then
                currentGame:onHit(box)
            end
        end
    end

    if currentGame:isRoundFinished() then currentGame:startRound() end
end

function lovr.draw()
    local leftHit = leftPointer:getHit()
    local rightHit = rightPointer:getHit()

    for i, hand in ipairs(lovr.headset.getHands()) do
        local position = vec3(lovr.headset.getPosition(hand))
        local direction = quat(lovr.headset.getOrientation(hand)):direction()

        lovr.graphics.setColor(1, 1, 1)
        lovr.graphics.sphere(position, .01)
        lovr.graphics.print(hand, position, 0.02)

        lovr.graphics.setColor(1, 0, 0)
        lovr.graphics.line(position, position + direction * 50)
    end

    for i, box in ipairs(boxes) do drawBox(box, leftHit, rightHit) end

    drawDebug()
    drawScore()
end

function nextNeededNumber() return boxes[next(boxes)].number end

function drawBox(numberbox, leftHit, rightHit)
    if numberbox == nil then return end

    local box = numberbox.collider
    local x, y, z = box:getPosition()
    local isHit = (leftHit and leftHit.collider == box) or
                      (rightHit and rightHit.collider == box)
    local boxColor = isHit and {0.50, 0.100, 0.200} or {0.20, 0.70, 0.170}
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

function drawScore()
    lovr.graphics.setColor(0.7, 0.6, 0)
    lovr.graphics.print("Oopsies: " .. currentGame.mistakes, 0.75, 3.5, -3, 0.5, 0)
    lovr.graphics.print("Score: " .. currentGame.score, 0.75, 3.0, -3, 0.5, 0)
end
