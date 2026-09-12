--feel free to use and copy
--join us at https://discord.gg/WmsssRkgd2
local Gui = loadstring(game:HttpGet("https://raw.githubusercontent.com/Asepthegoat/LIUDEX-Z/refs/heads/main/script/packages/UI-LIB.lua"))()
Gui.Set({
    title = "Blox Fruit",
    textcolor = Color3.fromRGB(255,255,255),
    desc = "Developed By Jorell",
    background = Color3.fromRGB(26,26,26),
    transparency = 0.25,
    tabbackground = Color3.fromRGB(35,35,35),
    tabtransparency = 0.1,
    border = Color3.fromRGB(52,5,105),
    toggle = {
        framecolor = Color3.fromRGB(29,12,35),
        active = Color3.fromRGB(0,255,0),
        inactive = Color3.fromRGB(255,0,0)
    },
    option = {
        active = Color3.fromRGB(91, 27, 201), -- rgb(37, 37, 37) pallete
        inactive = Color3.fromRGB(123, 93, 255),
        stroke = Color3.fromRGB(53, 0, 145)
    },
    input = {
        framecolor = Color3.fromRGB(29,12,35),
        bgplaceholder =  Color3.fromRGB(100,17,185)
    },
    buttonColor = Color3.fromRGB(29,12,35),
    logo = "rbxassetid://131858077876191" --or you can use getcustomasset to
})

--Init
local Main,Misc,Peformance = Gui.new("Main"),Gui.new("Misc"),Gui.new("Peformance")
local Main_Farm = Main:AddTab("Farm")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = ReplicatedStorage.Modules.Net
local RegisterAttack = Net["RE/RegisterAttack"]
local AttackRemote = Net["RE/RegisterHit"] require(game.ReplicatedStorage.Modules.Net):RemoteEvent("RegisterHit",true)
local AutoAttack = true

local function GetSessionID()
    local SendHitsToServer = getrenv()._G.SendHitsToServer
    local CombatThread = getupvalues(SendHitsToServer)[1]
    local UserIDSlice = tostring(getplayer().UserId):sub(2, 4)
    local MemorySlice = tostring(CombatThread):sub(11, 15)
    local SessionID = UserIDSlice .. MemorySlice

    return SessionID
end

local SessionID = GetSessionID()
local hub = {
    autofarm = false,
    autoattack = true,
    bring = false,
    autoraceskill = true,
    targetEnemy = "NearestNPC"
}
local state = {
    tweening = false,
    tweencon = nil,
    lockedRandom = false,
}
local ICD = {
    lastattack = tick(),
    lastRace = tick(),
    raceskill = false,
}


--function
local attackCombo,attacktbl,lockedEnemy = 1,{"HumanoidRootPart","Head","UpperTorso","RightUpperLeg","RightUpperArm"},nil
local tweenpos = Vector3.new(0,0,0)
    function tweenEnemy()
        if lockedEnemy and (lockedEnemy.Humanoid:GetState() == Enum.HumanoidStateType.Dead or lockedEnemy.Parent == nil or not lockedEnemy:IsDescendantOf(workspace)) then
            lockedEnemy = nil
            state.tweening = false
            if state.tweencon then
                state.tweencon:Disconnect()
            end
            state.tweencon = nil
        end
        if lockedEnemy and lockedEnemy:FindFirstChild("Humanoid").Health > 0 then
                tweenpos = lockedEnemy.HumanoidRootPart.Position + Vector3.new(0,30,0)
                lockedEnemy.HumanoidRootPart.Anchored = true
                getrootpart().Velocity = Vector3.zero
                if state.tweencon and not state.tweencon.Connected and (getrootpart().Position - tweenpos).Magnitude < 3 then
                    getrootpart().CFrame = CFrame.new(tweenpos)
                    state.tweening = false
                    state.tweencon = nil
                elseif not state.tweening then
                    keyclick(Enum.KeyCode.Q)
                    state.tweening = true
                    state.tweencon = gototarget(tweenpos,true,250)
                end
        end
    end
local function raceActiveSkill(type)
    if type then
        return game:GetService("ReplicatedStorage").Remotes.CommE:FireServer("ActivateAbility")
    end
    return game:GetService("Players").LocalPlayer.Backpack.Awakening.RemoteFunction:InvokeServer(true)
end

local function M1Attack(enemy)
    if not enemy then
        local nearest = 1000
        for i,v in ipairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - getrootpart().Position).Magnitude < nearest then
                nearest = (v.HumanoidRootPart.Position - getrootpart().Position).Magnitude
                enemy = v
            end
        end
    end
    if attackCombo > 3 then
        attackCombo = 1
    end
    RegisterAttack:FireServer(0.4,attackCombo)
    AttackRemote:FireServer(enemy[attacktbl[math.random(1,#attacktbl)]], {},nil,SessionID)
    attackCombo += 1
end

function getquest(quest)
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(
        "StartQuest",
        "DeepForestIsland",
        1
    )
    game:GetService("ReplicatedStorage").Modules.Net["RE/RobloxAnalytics"]:FireServer(
    {
        InternalName = "DeepForestIsland",
        Context = "SpokeToNPC",
        CompassTargetTracked = false
    }
)
end

import.RunService.Heartbeat:Connect(function()
    local waterpos = workspace.Map["WaterBase-Plane"].Position
    workspace.Map["WaterBase-Plane"].Position = Vector3.new(waterpos.X,-44,waterpos.Z)
    if not hub.bring and not lockedEnemy then
        local nearest = 1000
        if (hub.targetEnemy == "NearestNPC" or hub.targetEnemy == "") then
            for i,v in ipairs(workspace.Enemies:GetChildren()) do
                local distance = (getrootpart().Position - v.HumanoidRootPart.Position).Magnitude
                if distance < nearest and v.Humanoid and v.Humanoid.Health > 0 then
                    lockedEnemy = v
                    nearest = distance
                end
            end
            return
        end
        for i,v in ipairs(workspace.Enemies:GetChildren()) do
            if v.Name == hub.targetEnemy and v.Humanoid and v.Humanoid.Health > 0 then
                lockedEnemy = v
                break
            end
        end
    end

    if (tick() - ICD.lastRace) < 15 then
        if getchar().RaceEnergy.Value >= 1 then
            raceActiveSkill()
        end
        raceActiveSkill(true)
        ICD.lastRace = tick()
    end
end)

import.RunService.RenderStepped:Connect(function()
    local succ,err = pcall(function()
        if not hub.bring then
            tweenEnemy()
        end
    end)

    local suc,er = pcall(function()
        if hub.autoattack and (tick() - ICD.lastattack) >= 0.25 then
            M1Attack()
            ICD.lastattack = tick()
        end
    end)
    if not suc and er ~= nil then print("attack",er) end

    if not succ and err ~= nil then print("bring",err) end
end)

Main_Farm:Toggle({Text = "Auto Attack",Callback = function(val) hub.autoattack = val end},hub.autoattack)
Main_Farm:Toggle({Text = "Bring",Callback = function(val) 
    hub.bring = val or false
    if not val then 
        lockedEnemy = nil
        if  state.tweencon and state.tweencon.Connected then
            state.tweencon:Disconnect()
        end 
        state.tweencon = nil
        state.tweening = false
    end 
end})
Main_Farm:Input({Text = "Target",Placeholder = "Name...",Callback = function(val) hub.targetEnemy = val; print(val) end})
Main_Farm:Button({Text = "Active Race",OnClick = function() raceActiveSkill() task.wait(0.3) raceActiveSkill(true) end})

local Peformance_FPS = Peformance:AddTab("FPS")
Peformance_FPS:Toggle({Text = "Disable VFX",Callback = function(val) 
    local suc,f = pcall(function()
        if val then
            ldx:Notify("Removig VFX")
            for i,v in pairs(getconnections(game:GetService("ReplicatedStorage").Effect.Bindable.Event)) do
                hookfunction(v.Function,function()
                    return nil
                end)
            end
        else
            for i,v in pairs(getconnections(game:GetService("ReplicatedStorage").Effect.Bindable.Event)) do
                restorefunction(v.Function)
            end
        end
    end)
    if not suc then warn("VFX Hook",f) end
end})

Peformance_FPS:Toggle({Text = "Hide Notify",Callback = function(val) 
    local suc,f = pcall(function()
        ldx:Notify("Removig Notification")
        if val then
            for i,v in pairs(getconnections(game:GetService("ReplicatedStorage").Remotes.CommE.OnClientEvent)) do
                local old;
                old = hookfunction(v.Function,function(...)
                    local args = {...}
                    if args[1] == "Notify" then
                        return nil
                    end
                    return old(...)
                end)
            end
            return 
        end

        for i,v in pairs(getconnections(game:GetService("ReplicatedStorage").Remotes.CommE.OnClientEvent)) do
            restorefunction(v.Function)
        end
    end)
    if not suc then warn("Notify Hook",f) end
end})

Peformance_FPS:Button({Text = "Fast Mode",OnClick = function() firesignal(game:GetService("Players").LocalPlayer.PlayerGui.Main.SettingsMenu.Content.ScrollingFrame.FastMode.FirstButton.Activated) end})

ldx:Notify("Script Loaded","What's Up")

