     --[[
        X hoger -> naar rechts
        Y hoger -> naar boven
        Z lager -> naar voren
     --]]
pointer = require 'pointer'


function lovr.load()

 --checkWorks =  lovr.headset:getPosition(lovr.headset)
 
      world = lovr.physics.newWorld()
      world:setLinearDamping(.01)
      world:setAngularDamping(.005)
      world:setGravity(0,0,0)
     


      pointer:init({ source =pointer.handWrapper.new("hand/left"),   world = world })
      

      -- Create boxes!
      boxes = {}
      for x = -1, 1, .25 do
        for y = .125, 2, .24999 do
          local box = world:newBoxCollider(x, y, -2 - y / 5, .25)
          table.insert(boxes, box)
        end
      end
    
    
      lovr.timer.step() -- Reset the timer before the first update
    
      shader = lovr.graphics.newShader('standard')
      shader:send('lovrExposure', 2)
end


function lovr.update(dt)
  text = ""

  pointer:update()
  world:update(dt)
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


    drawBox(1, 2)
    drawBox(3, 2)
    drawBox(8, 5)
    drawBox(7, 4)
    drawBox(0, 3)
    drawBox(3, 6)
    drawBox(4, 4)

    for i, box in ipairs(boxes) do
      drawBox2(box, hit)
    end

    lovr.graphics.setColor(0.7, 0.6, 0)
    lovr.graphics.print(text, 1, 1, -1, 100, 0)
  
end

function drawBox2(box, hit)
  local x, y, z = box:getPosition()
  local boxColor = (hit and hit.collider == box) and { 0.50, 0.100, 0.200 } or { 0.20, 0.70, 0.170 }
  lovr.graphics.setColor(boxColor)
  lovr.graphics.cube('fill', x, y, z, .25, box:getOrientation())
  lovr.graphics.setColor(0.7, 0.6, 0)
  --lovr.graphics.print(hit or ".", x ,y, z +0.5, 0.5)

  
end


--https://lovr.org/docs/v0.15.0/World
--https://lovr.org/docs/v0.15.0/Physics/Boxes even better
function drawBox(r, c)
    scale = 0.3
    x = (-10 + (2 * r )) * scale
    y = (-5 + (2 * c)) * scale
    z = -5 * scale
    boxSize = 0.7 * scale
    lovr.graphics.setColor(0.7, 0.6, 0)
    lovr.graphics.cube('fill', x , y , z,  boxSize, 0)
    lovr.graphics.setColor(0.2, 0.2, 0.8)
    -- lovr.graphics.print('17', x , y , z + (boxSize / 2) + (0.1 * scale), 0.3 * scale)
    -- lovr.graphics.print(lovr.headset.getHands()[1]."hand/left", x , y , z + (boxSize / 2) + (0.1 * scale), 0.3 * scale)
    lovr.graphics.print(lovr.headset.getPosition("hand/left"), x , y , z + (boxSize / 2) + (0.1 * scale), 0.3 * scale)
end


--lovr.controlleradded = refreshSource
--lovr.controllerremoved = refreshSource
