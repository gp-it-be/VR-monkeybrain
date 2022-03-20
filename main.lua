pointer = require 'pointer'
numberBlock = require 'numberBlock'
selectScene = require 'selectScene'
transitionScene = require 'transitionScene'

Gamestate = {["PLAY"] = 1, ["GAMEOVER"] = 2}




-- #region GameScene

gameScene = {}
gameScene.__index = gameScene

function gameScene.create()
    local self = setmetatable({}, gameScene)
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

    for i, box in ipairs(boxes) do drawBox(box, leftHit, rightHit) end

    drawScore()
end

-- #endregion GameScene


-- #region Game
local game = {}
game.__index = game

function game.new()
    local self = setmetatable({}, game)
    self.numbersVisible = true
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
            box:setKinematic(true)
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
        --TODO make this change state of the game to game over? Of een game over scene erboven? die highscores etc toont
        scenes[#scenes] = selectScene:create()
        scenes[#scenes+1] = transitionScene:createFadeOut(0.5)
        
    end
end

function game:areNumbersVisible() return self.numbersVisible end
-- #endregion Game


function lovr.errhand(message)
    print(message)
end

function lovr.load()
    math.randomseed(os.time())
    print("world initting")
    world = lovr.physics.newWorld()
    world:setLinearDamping(.01)
    world:setAngularDamping(.005)
    world:setGravity(0, 0, 0)

    scenes = {}
    --table.insert(scenes, gameScene:create())
    table.insert(scenes, selectScene:create())
    table.insert(scenes, transitionScene:createFadeOut(0.5))


 

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
    --print(dt)
    text = ""

    leftPointer:update()
    rightPointer:update()
    local activeScene =  scenes[#scenes]
    local sceneShouldStay = activeScene:update(dt)
    if sceneShouldStay == false then
        table.remove(scenes, #scenes)
    end
end

function lovr.draw()
    local amountSeeThrough = 0
    for i, scene in ipairs(scenes) do
        if scene.isSeeThrough and scene:isSeeThrough() then
        amountSeeThrough = amountSeeThrough + 1
        end
    end



    for i, scene in ipairs(scenes) do
        scene:draw(#scenes - i - amountSeeThrough)
    end
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


function drawScore()
    lovr.graphics.setColor(0.7, 0.6, 0)
    lovr.graphics.print("Score: " .. currentGame.score, 0.75, 3.0, -3, 0.5, 0)
end
