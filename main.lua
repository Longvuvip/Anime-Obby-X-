-- Anime Obby X - Full Server Script
-- Đặt script này trong ServerScriptService

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Tạo RemoteEvent cho chọn nhân vật
local chooseEvent = Instance.new("RemoteEvent")
chooseEvent.Name = "ChooseCharacter"
chooseEvent.Parent = ReplicatedStorage

-- Game Pass ID
local GamePasses = {
    Gojo = 1274134158,
    Ichigo = 1276614971,
}

-- Số Win mở khoá
local WinUnlocks = {
    Luffy = 0,
    Naruto = 1,
    Goku = 3,
    Saitama = 5,
    Tanjiro = 7,
    Zoro = 10,
    Deku = 15,
    Levi = 20,
}

-- Tạo Folder lưu thông tin mở khoá
Players.PlayerAdded:Connect(function(player)
    local folder = Instance.new("Folder")
    folder.Name = "UnlockedCharacters"
    folder.Parent = player

    -- Mở khoá theo GamePass
    for name, id in pairs(GamePasses) do
        local success, hasPass = pcall(function()
            return MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
        end)
        local val = Instance.new("BoolValue")
        val.Name = name
        val.Value = success and hasPass
        val.Parent = folder
    end

    -- Mở khoá theo số win
    local leaderstats = player:WaitForChild("leaderstats")
    local wins = leaderstats:WaitForChild("Wins")

    wins:GetPropertyChangedSignal("Value"):Connect(function()
        for name, req in pairs(WinUnlocks) do
            local val = folder:FindFirstChild(name)
            if not val then
                local v = Instance.new("BoolValue")
                v.Name = name
                v.Value = wins.Value >= req
                v.Parent = folder
            else
                val.Value = wins.Value >= WinUnlocks[name]
            end
        end
    end)

    -- Kích hoạt ngay từ đầu
    for name, req in pairs(WinUnlocks) do
        local v = Instance.new("BoolValue")
        v.Name = name
        v.Value = wins.Value >= req
        v.Parent = folder
    end
end)

-- Khi người chơi chọn nhân vật từ UI
chooseEvent.OnServerEvent:Connect(function(player, characterName)
    local folder = player:WaitForChild("UnlockedCharacters")
    local isUnlocked = folder:FindFirstChild(characterName)
    if isUnlocked and isUnlocked.Value then
        local charFolder = ReplicatedStorage:WaitForChild("Characters")
        local charModel = charFolder:FindFirstChild(characterName)
        if charModel then
            local clone = charModel:Clone()
            player:LoadCharacter()
            clone:PivotTo(player.Character:GetPivot())
            clone.Parent = workspace
            player.Character:Destroy()
            player.Character = clone
        end
    end
end)