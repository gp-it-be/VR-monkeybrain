-- #region SelectScene

local selectScene = {}
selectScene.__index = selectScene



function selectScene.create()
    local self = setmetatable({}, selectScene)
    self.selectBoxes = {}
    self:init()
    return self
end


function selectScene:init()
    x = -0.25 
    y = .875 
    local box = world:newBoxCollider(x, y + 0.5, -2.5, .25)
    self.selectBoxes[1] = numberBlock.new(box, "Hardcore Endurance")

    local box = world:newBoxCollider(x, y, -2.5, .25)
    self.selectBoxes[2] = numberBlock.new(box, "Training")
end


function selectScene:update(dt)
    local hit
    if lovr.headset.wasPressed("hand/left", "trigger") then
        hit = leftPointer:getHit()
    else
        if lovr.headset.wasPressed("hand/right", "trigger") then
            hit = rightPointer:getHit()
        end
    end
    if hit then
        for i, box in ipairs(self.selectBoxes) do
            if box.collider == hit.collider then
                if box.number == "Hardcore Endurance" then
                    scenes[#scenes] = nil
                    scenes[#scenes+1] = gameScene:create() 
                end
            end
        end
    end
    return true
end

function selectScene:draw(sceneLevel)
    if sceneLevel ~= 0 then
        return 
    end
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

    for i, box in ipairs(self.selectBoxes) do drawBox(box, leftHit, rightHit) end

    lovr.graphics.setColor(0.7, 0.7, 0.9)
    lovr.graphics.print("Monkey Brain", -0.1, 2.8, -2, 0.40)
end



return selectScene
-- #endregion SelectScene