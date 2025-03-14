local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/UI-Libraries/main/Kavo/Kavo.lua"))()
local Window = Library.CreateLib("Blox Fruits | Auto Farm", "DarkTheme")

local AutoFarmTab = Window:NewTab("Auto Farm")
local FarmSection = AutoFarmTab:NewSection("Auto Farm")

local AutoFarmEnabled = false
local AutoBossFarmEnabled = false
local FarmItem = "Blox Fruit" -- Default farming method

FarmSection:NewToggle("Enable Auto Farm", "Auto farms NPCs for leveling", function(state)
    AutoFarmEnabled = state
    if AutoFarmEnabled then
        AutoFarm()
    end
end)

FarmSection:NewToggle("Enable Boss Farm", "Farms bosses for extra XP", function(state)
    AutoBossFarmEnabled = state
end)

FarmSection:NewDropdown("Select Farm Item", {"Blox Fruit", "Fighting Style", "Sword", "Gun"}, function(selected)
    FarmItem = selected
end)

FarmSection:NewButton("Teleport to Quest Giver", "Moves to the best quest giver", function()
    local _, questGiver = GetBestNPC()
    SafeTeleport(FindQuestGiverPosition(questGiver))
end)

-- Safe teleport function
local function SafeTeleport(targetPosition)
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
    end
end

-- Determine the best NPC for leveling
local function GetBestNPC()
    local level = game.Players.LocalPlayer.Data.Level.Value
    if level < 50 then
        return "Bandit", "Bandit Quest Giver"
    elseif level < 100 then
        return "Pirate", "Pirate Quest Giver"
    elseif level < 500 then
        return "Brute", "Brute Quest Giver"
    else
        return "Boss", "Boss Quest Giver"
    end
end

-- Auto-quest function
local function GetQuest(questGiver)
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc.Name == questGiver and npc:FindFirstChild("HumanoidRootPart") then
            SafeTeleport(npc.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
            wait(1)
            game:GetService("ReplicatedStorage").Remotes.Combat:FireServer("StartQuest", questGiver)
            wait(1)
        end
    end
end

-- Attack function based on selected Farm Item
local function AttackTarget(target)
    while target and target.Parent and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
        if FarmItem == "Blox Fruit" then
            game:GetService("ReplicatedStorage").Remotes.Combat:FireServer("UseFruitSkill")
        elseif FarmItem == "Fighting Style" then
            game:GetService("ReplicatedStorage").Remotes.Combat:FireServer("UseMeleeSkill")
        elseif FarmItem == "Sword" then
            game:GetService("ReplicatedStorage").Remotes.Combat:FireServer("UseSwordSkill")
        elseif FarmItem == "Gun" then
            game:GetService("ReplicatedStorage").Remotes.Combat:FireServer("UseGunSkill")
        end
        wait(0.2)
    end
end

-- Auto Farm Logic
local function AutoFarm()
    while AutoFarmEnabled do
        local targetNPC, questGiver = GetBestNPC()
        GetQuest(questGiver)

        for _, npc in pairs(workspace.Enemies:GetChildren()) do
            if npc.Name == targetNPC and npc:FindFirstChild("HumanoidRootPart") then
                SafeTeleport(npc.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
                AttackTarget(npc)
            end
        end
        wait(1)
    end
end
