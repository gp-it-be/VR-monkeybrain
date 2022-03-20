hiscoreScene = {}
hiscoreScene.__index = hiscoreScene

existingScores = {}

function hiscoreScene.create(_, score, gameMode)
    local self = setmetatable({}, hiscoreScene)
    self.score = score
    self.gameMode = gameMode
    hiscoreScene:load()
    return self
end

function hiscoreScene:load()
  content = lovr.filesystem.read("hiscores.txt")
  lineNr = 0
  for line in string.gmatch(content, "[^\n]*\n") do
    lineNr = lineNr+1
    parts= split(line, ",")
    existingScores[lineNr] = {score = parts[1], name = parts[2]}
 end
end



function hiscoreScene:update()
    
end




function hiscoreScene:draw()
    lovr.graphics.setColor(1,1,1)
    lovr.graphics.print(self.gameMode, 0.75, 3.0, -3, 0.5, 0)
    
    lovr.graphics.print("rank", -1.15, 2.7, -3, 0.5, 0)
    lovr.graphics.print("score", 0.15, 2.7, -3, 0.5, 0)
    lovr.graphics.print("name", 1.5, 2.7, -3, 0.5, 0)



    for index, value in ipairs(existingScores) do
        lovr.graphics.print(index, -1.15, 2.5 - 0.35 * index, -3, 0.5, 0)
        lovr.graphics.print(value.score, 0.15, 2.5 - 0.35 * index, -3, 0.5, 0)
        print(value.name)
        lovr.graphics.print(value.name, 1.5, 2.5 - 0.35 * index, -3, 0.5, 0)
    end
end




function split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
      table.insert(Table,cap)
       end
       last_end = e+1
       s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
       cap = pString:sub(last_end)
       table.insert(Table, cap)
    end
    return Table
 end


return hiscoreScene