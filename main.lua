-- main.lua tối ưu cho Anime Obby X

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerData = {} -- lưu data tạm, nên thay bằng DataStore khi có server

-- Cấu hình nhân vật mở khóa: {Name = string, RequiredWin = number, GamePassID = number or nil}
local Characters = {
    {Name = "Luffy", RequiredWin = 0, GamePassID = nil},
    {Name = "Naruto", RequiredWin = 5, GamePassID = nil},
    {Name = "Goku", RequiredWin = 10, GamePassID = 12345678}, -- ví dụ GamePassID
    {Name = "Saitama", RequiredWin = 20, GamePassID = nil},
    -- Thêm nhân vật khác tại đây
}

-- Giả lập dữ liệu win hiện tại của người chơi
playerData.Wins = 12 -- Ví dụ: bạn lấy từ server hoặc lưu store

-- Hàm kiểm tra xem người chơi có quyền mở nhân vật
local function CanUnlockCharacter(char)
    local hasPass = false
    if char.GamePassID then
        local success, hasPassOwn = pcall(function()
            return MarketplaceService:UserOwnsGamePassAsync(player.UserId, char.GamePassID)
        end)
        hasPass = success and hasPassOwn
    end
    return playerData.Wins >= char.RequiredWin or hasPass
end

-- UI chọn nhân vật đơn giản
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "CharacterSelectGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 400, 0, 300)
Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0.5,0.5)

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local SelectedCharacter = nil

-- Tạo nút cho từng nhân vật
for _, char in ipairs(Characters) do
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Text = char.Name
    btn.BackgroundColor3 = CanUnlockCharacter(char) and Color3.fromRGB(50,150,50) or Color3.fromRGB(150,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.AutoButtonColor = CanUnlockCharacter(char)
    btn.Name = char.Name

    if CanUnlockCharacter(char) then
        btn.MouseButton1Click:Connect(function()
            SelectedCharacter = char
            print("Chọn nhân vật:", char.Name)
            -- Gọi hàm clone nhân vật
            CloneCharacter(char.Name)
        end)
    else
        btn.MouseButton1Click:Connect(function()
            warn("Chưa đủ điều kiện mở nhân vật: "..char.Name)
        end)
    end
end

-- Hàm clone nhân vật chuẩn, xử lý model, animation
function CloneCharacter(charName)
    local charModel = ReplicatedStorage:FindFirstChild("Characters")
    if not charModel then
        warn("Không tìm thấy folder Characters trong ReplicatedStorage")
        return
    end

    local modelToClone = charModel:FindFirstChild(charName)
    if not modelToClone then
        warn("Không tìm thấy nhân vật "..charName)
        return
    end

    -- Xóa nhân vật cũ trong workspace nếu có
    local currentChar = workspace:FindFirstChild(player.Name)
    if currentChar then
        currentChar:Destroy()
    end

    local clone = modelToClone:Clone()
    clone.Name = player.Name
    clone.Parent = workspace

    -- Đặt vị trí spawn nhân vật
    if workspace:FindFirstChild("SpawnLocation") then
        clone:SetPrimaryPartCFrame(workspace.SpawnLocation.CFrame + Vector3.new(0, 5, 0))
    else
        clone:SetPrimaryPartCFrame(CFrame.new(0, 10, 0))
    end

    -- Thêm logic animation nếu có
    -- Ví dụ:
    -- local humanoid = clone:FindFirstChildOfClass("Humanoid")
    -- if humanoid then
    --     humanoid:LoadAnimation(...)
    -- end

    print("Nhân vật "..charName.." đã được clone thành công!")
end

-- Tối ưu xử lý input cho PC & Mobile
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    -- Ví dụ: nhấn phím 1-4 để chọn nhân vật
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        local index = nil
        if key == Enum.KeyCode.One then index = 1 end
        if key == Enum.KeyCode.Two then index = 2 end
        if key == Enum.KeyCode.Three then index = 3 end
        if key == Enum.KeyCode.Four then index = 4 end

        if index and Characters[index] and CanUnlockCharacter(Characters[index]) then
            CloneCharacter(Characters[index].Name)
        end
    end
end)

print("Script main.lua đã khởi chạy thành công!")