-- #region Transition

local transitionScene = {}
transitionScene.__index = transitionScene

function transitionScene.createFadeIn(first, time)
    return transitionScene:create(time, true)
end

function transitionScene.createFadeOut(first, time)
    return transitionScene:create(time, false)
end

function transitionScene.create(first, time, omega)
    local self = setmetatable({}, transitionScene)
    self.totaltime = time
    self.timeLeft = time
    self.isFadeIn = omega
    return self
end

function transitionScene:update(dt)
    self.timeLeft = self.timeLeft - dt
    return self.timeLeft > 0
end


--sceneLevel is 0 when you are the top level scene
--1 if theres 1 scene bove you, etc
function transitionScene:draw(sceneLevel)
    -- if sceneLevel ~= 0 then
    --     return 
    -- end
    x, y, z = lovr.headset.getPosition("head")

    local fade = (self.timeLeft / self.totaltime)
    if self.isFadeIn then
        fade = 1 - fade
    end

    lovr.graphics.setColor(0.9, 0.95, 0.9, fade)
    lovr.graphics.sphere(x, y, z, 0.5)

end


function transitionScene:isSeeThrough()
    return true
end

return transitionScene

-- #endregion Transition