hiscoreScene = {}
hiscoreScene.__index = hiscoreScene

existingScores = {}

local rows = {
    {'CONFIRM'}, {}, {'backspace'}, {'z', 'x', 'c', 'v', 'b', 'n', 'm'},
    {'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'},
    {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'},
    {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'}
}

hiscoreScene.amountOfScores = 5

enteredName = ""

function hiscoreScene.create(_, score, gameMode)
    local self = setmetatable({}, hiscoreScene)
    self.score = score
    self.gameMode = gameMode
    hiscoreScene:load(score)
    return self
end

function hiscoreScene:load(score)
    content = lovr.filesystem.read("hiscores.txt")
    lineNr = 0
    for line in string.gmatch(content, "[^\n]*\n") do
        lineNr = lineNr + 1
        parts = split(line, ",")
        existingScores[lineNr] = {score = tonumber(parts[1]), name = parts[2]}
    end

    self.scoreRank = determineNewScoreRank(score, existingScores)
    if self.scoreRank <= hiscoreScene.amountOfScores then
        self.state = "ASKING_NAME"
        keyBlocks = {}
        for rowIndex, row in ipairs(rows) do
            for keyIndex, key in ipairs(row) do
                local box = world:newBoxCollider(0 + keyIndex * 0.3,
                                                 0 + rowIndex * 0.3, -2.5, .25)
                local numberBlock = numberBlock.new(box, key)
                keyBlocks[#keyBlocks + 1] = numberBlock
            end
        end

    else
        self.state = "VISUALISING"
    end
end

function hiscoreScene:update(dt)
    local hit
    if lovr.headset.wasPressed("hand/left", "trigger") then
        hit = leftPointer:getHit()
    else
        if lovr.headset.wasPressed("hand/right", "trigger") then
            hit = rightPointer:getHit()
        end
    end
    if hit then
        for i, box in ipairs(keyBlocks) do
            if box.collider == hit.collider then
                if box.number == "CONFIRM" then
                    -- TODO add the score , save, change state
                end
                if box.number == "backspace" then
                    enteredName = substring(enteredName, 1, 3)
                end
                if box.number ~= "CONFIRM" and box.number ~= "backspace" then
                    enteredName = enteredName .. box.number
                end
            end
        end
    end
    return true
end

function hiscoreScene:draw()
    lovr.graphics.setColor(1, 1, 1)
    lovr.graphics.print(self.gameMode, 0.75, 3.0, -3, 0.5, 0)

    lovr.graphics.print("rank", -1.15, 2.7, -3, 0.5, 0)
    lovr.graphics.print("score", 0.15, 2.7, -3, 0.5, 0)
    lovr.graphics.print("name", 1.5, 2.7, -3, 0.5, 0)

    for index, value in ipairs(existingScores) do
        lovr.graphics.print(index, -1.15, 2.5 - 0.35 * index, -3, 0.5, 0)
        lovr.graphics.print(value.score, 0.15, 2.5 - 0.35 * index, -3, 0.5, 0)
        lovr.graphics.print(value.name, 1.5, 2.5 - 0.35 * index, -3, 0.5, 0)
    end

    if self.state == "ASKING_NAME" then

        lovr.graphics.setColor(0.7, 0.7, 0.9)
        lovr.graphics.print("ENTER NAME: "  .. enteredName .. flickeringDash(),
                            -0.1, 0, -2, 0.20)

        local leftHit = leftPointer:getHit()
        local rightHit = rightPointer:getHit()

        for i, hand in ipairs(lovr.headset.getHands()) do
            local position = vec3(lovr.headset.getPosition(hand))
            local direction =
                quat(lovr.headset.getOrientation(hand)):direction()

            lovr.graphics.setColor(1, 1, 1)
            lovr.graphics.sphere(position, .01)
            lovr.graphics.print(hand, position, 0.02)

            lovr.graphics.setColor(1, 0, 0)
            lovr.graphics.line(position, position + direction * 50)
        end

        for i, box in ipairs(keyBlocks) do
            drawBox(box, leftHit, rightHit)
        end
    else
        print("VISUALI")
    end

end

function flickeringDash()
    if (os.time() % 2 < 1) then return "_" end
    return " "

end

function determineNewScoreRank(score, existingScores)
    for index, existingScore in ipairs(existingScores) do
        if score > existingScore.score then return index end
    end
    return #existingScores + 1
end

function split(pString, pPattern)
    local Table = {} -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then table.insert(Table, cap) end
        last_end = e + 1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end

return hiscoreScene
