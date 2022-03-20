gameScene = {}
gameScene.__index = gameScene

currentGame = {}

function gameScene.create()
    print("new game scene")
    local self = setmetatable({}, gameScene)
    currentGame = game.new()
    currentGame:startRound()
    return self
end


function gameScene:update(dt)
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
    return true
end


function gameScene:draw()
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

    for i, box in ipairs(boxes) do game.drawBox(box, leftHit, rightHit) end

    drawScore()
end

-- #endregion GameScene


-- #region Game
game = {}
game.__index = game

function game.new()
    local self = setmetatable({}, game)
    self.numbersVisible = true
    self.score = 0
    self.round = 0

    tapSound = lovr.audio.newSource('short.wav')

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
            box:setKinematic(true)
            local numberBlock = numberBlock.new(box, placedBlocks)
            boxes[placedBlocks] = numberBlock
        end
    end
end

function game:isRoundFinished() return next(boxes) == nil end

function game:onHit(numberBlock)
    if numberBlock.number == nextNeededNumber() then
        tapSound:stop()
        tapSound:play()
        local removedbox = table.remove(boxes, 1)
        removedbox:destroy()
        self.numbersVisible = false
        self.score = self.score + numberBlock.number
    else
        --TODO make this change state of the game to game over? Of een game over scene erboven? die highscores etc toont
        --scenes[#scenes] = selectScene:create()
        scenes[#scenes+1] = hiscoreScene:create(self.score, "HARDCORE ENDURANCE")
        scenes[#scenes+1] = transitionScene:createFadeOut(0.5)
        
    end
end

function game:areNumbersVisible() return self.numbersVisible end

function nextNeededNumber() return boxes[next(boxes)].number end
-- #endregion Game





function game.drawBox(numberbox, leftHit, rightHit)
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


function drawScore()
    lovr.graphics.setColor(0.7, 0.6, 0)
    lovr.graphics.print("Score: " .. currentGame.score, 0.75, 3.0, -3, 0.5, 0)
end


return gameScene