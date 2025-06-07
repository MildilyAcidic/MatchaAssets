--[[
Made by @acidzs
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer


local Autoblock = {}
Autoblock.__index = Autoblock


local CONFIG = {
    hitboxSize = {x = 14, z = 14},
    stepInterval = 0.005,
    fKeyCode = 0x46
}

function Autoblock.new()
    local self = setmetatable({}, Autoblock)
    self.character = nil
    self.primaryPart = nil
    self.isFHeld = false
    self.live = workspace:FindFirstChild("Live")
    self.isRunning = false
    self.cachedChildren = {}
    self.lastCacheTime = 0
    self.cacheInterval = 0.1
    return self
end

function Autoblock:initialize()
    self:updateCharacter()
    self.isRunning = true
end

function Autoblock:updateCharacter()
    self.character = Player.Character
    self.primaryPart = self.character and self.character.PrimaryPart
end

function Autoblock:cleanup()
    if self.isFHeld then
        keyrelease(CONFIG.fKeyCode)
        self.isFHeld = false
    end
    self.character = nil
    self.primaryPart = nil
end

function Autoblock:isValidCharacter(chr)
    return chr ~= self.character and chr:FindFirstChild("M1ing")
end

function Autoblock:isInHitbox(pos, center)
    if not pos or not center then return false end
    
    local dx = math.abs(pos.x - center.x)
    local dz = math.abs(pos.z - center.z)
    
    return dx <= CONFIG.hitboxSize.x * 0.5 and dz <= CONFIG.hitboxSize.z * 0.5
end

function Autoblock:updateCache()
    local currentTime = os.time()
    if currentTime - self.lastCacheTime > self.cacheInterval then
        self.cachedChildren = self.live and self.live:GetChildren() or {}
        self.lastCacheTime = currentTime
    end
end

function Autoblock:DetectM1()
    if not self.character or not self.primaryPart then
        return false
    end
    
    local center = self.primaryPart.Position
    if not center then return false end
    
    self:updateCache()
    
    for _, chr in ipairs(self.cachedChildren) do
        if self:isValidCharacter(chr) then
            local enemyPart = chr.PrimaryPart
            if enemyPart then
                local pos = enemyPart.Position
                if self:isInHitbox(pos, center) then
                    return true
                end
            end
        end
    end
    
    return false
end

function Autoblock:handleFKey(shouldHold)
    if shouldHold and not self.isFHeld then
        keypress(CONFIG.fKeyCode)
        self.isFHeld = true
    elseif not shouldHold and self.isFHeld then
        keyrelease(CONFIG.fKeyCode)
        self.isFHeld = false
    end
end

function Autoblock:step()
    if not self.isRunning then return end
    
    
    if not self.character and Player.Character then
        self:updateCharacter()
    end
    
    local shouldHoldF = self:DetectM1()
    self:handleFKey(shouldHoldF)
end

function Autoblock:start()
    self:initialize()
    
    
    coroutine.wrap(function()
        while self.isRunning do
            self:step()
            wait(CONFIG.stepInterval)
        end
    end)()
end

function Autoblock:stop()
    self.isRunning = false
    self:cleanup()
end


local detector = Autoblock.new()
detector:initialize()

while true do
    detector:step()
    wait(0.005)
end
