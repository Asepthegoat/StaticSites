local TS,RS,Http = cloneref(game:GetService("TweenService")),cloneref(game:GetService("RunService")),cloneref(game:GetService("HttpService"))
local lastrs,lastattack,steptick = tick(),tick(),tick()
local isFarming,hide_notify = false,false
local Players = cloneref(game:GetService("Players"))
local queueonteleport = queueonteleport or queue_on_teleport
local player = Players.LocalPlayer
local speed = 300
local StarterGui = cloneref(game:GetService("StarterGui"))
local function init()
    game:GetService("ReplicatedStorage").Modules.Net["RE/OnAnalyticsActivity"]:FireServer("TeamSelect/Team/Marines")
    task.wait(0.1)
    game:GetService("ReplicatedStorage").Remotes["CommF_"]:InvokeServer("SetTeam2","Marines")
end 
repeat init() task.wait(0.2) until player.Character
--[[
task.wait(1)
local Event = game:GetService("ReplicatedStorage").Modules.Net["RE/OnAnalyticsActivity"]
Event:FireServer("TeamSelect/Team/Marines")
local Event2 = game:GetService("ReplicatedStorage").Remotes.CommF_
Event2:InvokeServer("SetTeam2","Marines")
]]
local char = player.Character or player.CharacterAdded:Wait()

player.CharacterAdded:Connect(function(charz)
    char = charz
end)



local function hopserver()
    local Event = game:GetService("ReplicatedStorage").__ServerBrowser
    local tbl = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&cursor="))
    for i,v in pairs(tbl.data) do
        Event:InvokeServer("teleport",v.id)
        task.wait(math.random(3,5))
    end
end

local function Notify(title,text,icon,button1,button2,callback)
    StarterGui:SetCore("SendNotification", {
            Title = title,
            Icon = icon or nil, -- contoh ikon notifikasi default
            Text = text or "" or nil,
            Duration = 5,
            Callback = callback or nil,
            Button1 = button1 or nil,
            Button2 = button2 or nil,
})
end

local function tween(target) --target.Position mksdny
    local rootPart = char.HumanoidRootPart
    local startCFrame = rootPart.CFrame
    local duration = (rootPart.Position - target).Magnitude / speed
    local elapsed = 0 
    local tweens
    local done = false
    tweens = RS.Heartbeat:Connect(function(deltaTime)
        if tween then
            elapsed = elapsed + deltaTime
            local alpha = math.clamp(elapsed / duration, 0, 1)
            rootPart.CFrame = startCFrame:Lerp(CFrame.new(target), alpha)
            duration = (rootPart.Position - target).Magnitude / speed
            elapsed = 0 
            startCFrame = rootPart.CFrame
            if alpha >= 1 then
                tweens:Disconnect()
                done = true
            end
        end
    end)
    repeat task.wait(0.2) until done
end


local function gacha() --work
    local Event = game:GetService("ReplicatedStorage").Remotes.CommF_
    local Res,Result = Event:InvokeServer("Cousin","CheckCanBuyType","DLCBoxData")
    local Event2 = game:GetService("ReplicatedStorage").Remotes.ReportActivity
    Event2:FireServer("GachaWindow")
    task.wait(0.5)
    if Result then
        Event:InvokeServer("Cousin","DLCBoxData")
    end
end

local function scanchest()
    local tbl = {}
    for i,v in ipairs(workspace.ChestModels:GetChildren()) do
        if (char.HumanoidRootPart.Position - v:FindFirstChildOfClass("Part").Position).Magnitude < 5000 then
            table.insert(tbl,v:FindFirstChildOfClass("Part").Position)
        end
    end
    return tbl
end

-- setclipboard("Vector3.new(" .. tostring(workspace.Characters.pxgfrhz33829.HumanoidRootPart.Position) .. ")")

local function ischestsafe(chest)
    local safe = true
    for i,v in ipairs(Players:GetChildren()) do
        if (chest.Position - v.Character.HumanoidRootPart.Position).Magnitude < 200 then
            safe = false
            break
        end
    end
    return safe
end

local function getchest() --work
    local root = char.HumanoidRootPart
    local chests = scanchest()
    Notify("Chest Detector","Detected:" .. #chests .. " Chest","rbxassetid://121661147907954")
    if #chests < 1 then return warn("nochest") end
    table.sort(chests, function(a, b)
        local posa = a
        local posb = b

        if not posa or not posb then
            return false
        end

        local da = (root.Position - posa).Magnitude
        local db = (root.Position - posb).Magnitude

        return da < db
    end)
    local target = chests[1]
    while #chests > 0 do
        local pos = target
        local suc,distance = pcall(function() return (char.HumanoidRootPart.Position - pos).Magnitude end)
        pcall(tween,pos)
        task.wait(0.5)
        table.remove(chests,table.find(chests,target))
        target = nil
        for i,v in ipairs(chests) do
            local part = v
            if part then
                if not target then
                    target = part
                elseif (part - root.Position).Magnitude < (target - root.Position).Magnitude then
                    target = part
                end
            end
        end
    end
    return true
end

local portal = {
    BigMansion = Vector3.new(-12471.732421875, 375.6352233886719, -7556.66357421875),
    SeaCastle = Vector3.new(-5054.9248046875, 314.57855224609375, -3181.4375),
    Tiki = Vector3.new(-16812.556640625, 58.31882858276367, 304.6124572753906),
    Hydra1 = Vector3.new(5650.94775390625, 980.3157958984375, -350.3791809082031)
}
local islandList = {
    IceCream = Vector3.new(-918.69873046875, 310.99249267578125, -11454.71875),
    Loaf = Vector3.new(-2038.2222900390625, 40.860774993896484, -11983.6796875),
    Chocolate = Vector3.new(-78.45331573486328, 255.99114990234375, -12215.6201171875),
    Peanut = Vector3.new(-2112.87255859375, 195.64865112304688, -10225.859375)
}
local function gotoisland(island)
    if portal[island] then
        local Event = game:GetService("ReplicatedStorage").Remotes.CommF_
        Event:InvokeServer("requestEntrance",portal[island])
        task.wait()
        Event:InvokeServer("SetLastSpawnPoint",island)
    elseif islandList[island] then
        local distance = (char.HumanoidRootPart.Position - islandList[island]).Magnitude
        tween(islandList[island])
        task.wait(0.5)
    end
end

local M1Fruit = 1
function fruitM1()
    local Item = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Tiger-Tiger") or game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Tiger-Tiger")
    local Event = Item.LeftClickRemote
    Event:FireServer(Vector3.new(-0.84223020076752, 0, -0.53911805152893),M1Fruit)
    M1Fruit += 1
    if M1Fruit > 2 then 
        M1Fruit = 1
    end
end

local scripts = {}
local function dotask(ftype,tbl,bool)
    isFarming = bool
    while true do
        if not char then return end
        for i,v in ipairs(tbl) do
            gotoisland(v)
            task.wait()
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0,-30,0)
            task.wait(5.4)
            if v == "SeaCastle" then
                pcall(function()
                    workspace.Map["Boat Castle"].MapTeleportA.Hitbox:GetChildren()[1]:Destroy()
                    workspace.Map["Boat Castle"].MapTeleportB.Hitbox:GetChildren()[1]:Destroy()
                    workspace.Map["Boat Castle"].MapTeleportC.Hitbox:GetChildren()[1]:Destroy()
                end)
            end
            pcall(getchest)
            task.wait()
        end
        task.wait(1)
        hopserver()
    end
end

--[[
local function bringEnemy()
    setsimulationradius(200)
    for i,v in ipairs(workspace.Enemies:GetChildren()) do
        if isnetworkowner(v:FindFirstChild("HumanoidRootPart")) and (v:FindFirstChild("HumanoidRootPart").Position - getrootpart().Position).Magnitude < 140 then
            v:FindFirstChild("HumanoidRootPart").CFrame = getrootpart().CFrame
        end
    end
end
local isRaiding,isDoingQuest,inRaidPos = false,false,false

RS.Heartbeat:Connect(function()
    if isFarming then
        char.HumanoidRootPart.Velocity = Vector3.zero
    end
    if isRaiding then return end
    if (tick() - lastattack) > 0.4 then
        lastattack = tick()
        fruitM1()
    elseif (tick() - lastrs) > 1 then
        lastrs = tick()
        bringEnemy()
    end
end)
]]



--[[
local Event = game:GetService("ReplicatedStorage").Remotes.CommE
for i,v in pairs(getconnections(Event.OnClientEvent)) do
    local a;a = hookfunction(v.Function,function(...)
        local args = table.pack(...)
        if args[1] == "ChatNotification" then
           if string.find(args[2],"Pirates have been spotted approaching the castle!") then
                isPirateRaid = true
           elseif string.find(args[2],"Good job! Anybody who defeated at least 1 pirate") then
                task.defer(function() task.wait(0.4) isPirateRaid = false end) --biar keren
           end
        end
        return a(...)
    end)
end
]]

player.Idled:Connect(function()
game:GetService("VirtualUser"):ClickButton2(Vector2.new(0,0))
task.wait(1)
game:GetService("VirtualUser"):ClickButton2(Vector2.new(math.random(1,10),math.random(1,10)))
end)

queueonteleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/Asepthegoat/StaticSites/refs/heads/main/bloxfruit.lua"))()]])
--FPS Booster
task.spawn(function() --onclient hook
    for i,v in pairs(getconnections(game:GetService("ReplicatedStorage").Remotes.FX.OnClientEvent)) do
        local a;a = hookfunction(v.Function,function()
            return nil
        end)
    end

    if hide_notify then
        for i,v in pairs(getconnections(game:GetService("ReplicatedStorage").Remotes.CommE.OnClientEvent)) do
            local a;a = hookfunction(v.Function,function(...)
                local args = {...}
                if args[1] == "Notify" then
                    return nil
                end
                return a(...)
            end)
        end
    end
end)

local block;block = hookmetamethod(game,"__namecall",newcclosure(function(self,...) --mt hook
    local args = {...}
    local method = getnamecallmethod()
    if args[1] and args[1] == "spawn" and self == game:GetService("ReplicatedStorage").Effect.Bindable and method == "Fire" then
        return nil
    end
    return block(self,...)
end))
local farm_island_list = getgenv().IslandToFarm or {"Peanut","Loaf","IceCream","Chocolate","SeaCastle","BigMansion"}
dotask("chest",farm_island_list,true)
