pointer = require 'pointer'
numberBlock = require 'numberBlock'
selectScene = require 'selectScene'
transitionScene = require 'transitionScene'
gameScene = require 'gameScene'
hiscoreScene = require 'hiscoreScene' --TODO remove?



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
    table.insert(scenes, hiscoreScene:create(9, "HARDCORE"))
    -- table.insert(scenes, selectScene:create())
    table.insert(scenes, transitionScene:createFadeOut(0.5))

    leftPointer = pointer.new({
        source = pointer.handWrapper.new("hand/left"),
        world = world
    })
    rightPointer = pointer.new({
        source = pointer.handWrapper.new("hand/right"),
        world = world
    })
    lovr.timer.step() -- Reset the timer before the first update -- why?
    shader = lovr.graphics.newShader('standard')
    shader:send('lovrExposure', 2)
end

function lovr.update(dt)
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

