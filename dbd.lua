getgenv().Config = getgenv().Config or {
    AutoRace = false, -- เปลี่ยนเป็น true เพื่อฟาร์มด่าน (แข่ง) false จะปิด
    AutoFarm = true,  -- เปลี่ยนเป็น true เพื่อฟาร์มขับรถบนฟ้า false จะปิด
    FarmSpeed = 500,  -- ความเร็วตอนบินบนฟ้า (แล้วแต่รถแต่รถฟรีเริ่มต้นแค่นี้พอ)
    TargetRace = "Race1", -- ไม่ต้องปรับอะไร
    TeleportDelay = 0.7 -- ความเร็วในการวาร์ปแต่ละ Checkpoint (0.7พอดีแล้วต่ำกว่านี้ได้เงินน้อยมากกว่านี้ช้า)
}

getgenv().AutoRaceState = getgenv().AutoRaceState or {
    Active = false,
    CurrentIndex = 1
}

getgenv().AutoFarmState = getgenv().AutoFarmState or {
    Direction = 1,
    Active = false
}

local Players = game:GetService("Players")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

while not Players.LocalPlayer do
    task.wait(0.5)
end
local LocalPlayer = Players.LocalPlayer

print("[MCP] Waiting for game to fully load...")
repeat
    task.wait(1)
    local isStillLoading = false
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    
    if PlayerGui then
        local ls = PlayerGui:FindFirstChild("LoadingScreen")
        if ls and ls.Enabled then
            local Loading = ls:FindFirstChild("Loading")
            if Loading then
                local Bottom = Loading:FindFirstChild("Bottom")
                local Bar = Bottom and Bottom:FindFirstChild("Bar")
                local LoadingText = Bar and Bar:FindFirstChild("Loading")
                if LoadingText and LoadingText:IsA("TextLabel") then
                    local txt = string.lower(LoadingText.Text)
                    if string.match(txt, "loading game") or string.match(txt, "%.%.%.") then
                        isStillLoading = true
                    end
                end
            end
        end
    end
until not isStillLoading
print("[MCP] Game fully loaded! Starting script...")

local hasClickedPlay = false
local hasSelectedCar = false

local function HardwareClick(Button)
    local vim = game:GetService("VirtualInputManager")
    local absPos = Button.AbsolutePosition
    local absSize = Button.AbsoluteSize
    local cx = absPos.X + (absSize.X / 2)
    local cy = absPos.Y + (absSize.Y / 2)
    
    if cx > 0 and cy > 0 then
        local guiService = game:GetService("GuiService")
        local inset, _ = guiService:GetGuiInset()
        cy = cy + inset.Y
        
        vim:SendMouseMoveEvent(cx, cy, game)
        task.wait(0.1)
        vim:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
        task.wait(0.1)
        vim:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
        return true
    end
    return false
end

local function checkAndClickPlay()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return end
    
    local LoadingScreen = PlayerGui:FindFirstChild("LoadingScreen")
    if not LoadingScreen or not LoadingScreen.Enabled then
        return
    end

    local Center = LoadingScreen:FindFirstChild("Center")
    local Frame = Center and Center:FindFirstChild("Frame")
    local Play = Frame and Frame:FindFirstChild("Play")
    local Button = Play and Play:FindFirstChild("Button")
    
    local Loading = LoadingScreen:FindFirstChild("Loading")
    if Loading then
        local Bottom = Loading:FindFirstChild("Bottom")
        local Bar = Bottom and Bottom:FindFirstChild("Bar")
        local LoadingText = Bar and Bar:FindFirstChild("Loading")
        if LoadingText and LoadingText:IsA("TextLabel") then
            local txt = string.lower(LoadingText.Text)
            if string.match(txt, "loading game") or string.match(txt, "%.%.%.") then
                print("[AutoPlay] Game is still loading... waiting.")
                return 
            end
        end
    end
    
    local function isReallyVisible(gui)
        local current = gui
        while current and current:IsA("GuiObject") do
            if not current.Visible then return false end
            current = current.Parent
        end
        return true
    end
    
    if Button and isReallyVisible(Button) then
        print("[AutoPlay] Game loaded! Play button is visible. Waiting 2 seconds before clicking...")
        task.wait(3) 
        
        if HardwareClick(Button) then
            print("[AutoPlay] Hardware Clicked PLAY button!")
            task.wait(3) 
        else
            print("[AutoPlay] Button position not loaded yet.")
        end
    end
end

local function checkAndSelectStarterCar()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return end
    
    local StarterPick = PlayerGui:FindFirstChild("StarterPick")
    if not StarterPick or not StarterPick.Enabled then
        hasSelectedCar = false
        return
    end

    if hasSelectedCar then return end

    local Menu = StarterPick:FindFirstChild("Menu")
    if Menu then
        local Vehicles = Menu:FindFirstChild("Vehicles")
        local Buttons = Menu:FindFirstChild("Buttons")
        
        if Vehicles and Buttons then
            local BlueCar = Vehicles:FindFirstChild("1997 Hassan P34 LT-R")
            local Confirm = Buttons:FindFirstChild("Confirm")
            
            if BlueCar and Confirm then
                hasSelectedCar = true
                
                task.wait(1)
                
                if HardwareClick(BlueCar) then
                    print("[AutoCar] Selected Blue Car!")
                    task.wait(0.5)
                    
                    if HardwareClick(Confirm) then
                        print("[AutoCar] Confirmed Car Selection!")
                    end
                else
                    hasSelectedCar = false
                end
            end
        end
    end
end

local function checkAndSpawnCar()
    if workspace:FindFirstChild(LocalPlayer.Name .. "'s Car") then 
        return 
    end
    
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return end
    
    local GarageMenu = PlayerGui:FindFirstChild("GarageMenu")
    
    if not GarageMenu or not GarageMenu.Enabled then
        local MainUI = PlayerGui:FindFirstChild("Main_User_Interface")
        if MainUI then
            local UIFrame = MainUI:FindFirstChild("UI_Frame")
            if UIFrame then
                local Buttons = UIFrame:FindFirstChild("Buttons")
                if Buttons then
                    local SpawnBtn = Buttons:FindFirstChild("Spawn")
                    if SpawnBtn then
                        HardwareClick(SpawnBtn)
                        task.wait(1) 
                    end
                end
            end
        end
    end
    
    if GarageMenu and GarageMenu.Enabled then
        local Menu = GarageMenu:FindFirstChild("Menu")
        if Menu then
            local Container = Menu:FindFirstChild("Container")
            if Container then
                local Vehicles = Container:FindFirstChild("Vehicles")
                if Vehicles then
                    for _, child in pairs(Vehicles:GetChildren()) do
                        if child:IsA("ImageButton") and child.Name ~= "Teleport" then
                            HardwareClick(child)
                            task.wait(0.5)
                            
                            for _, btn in pairs(Menu:GetChildren()) do
                                if btn:IsA("TextButton") then
                                    local btnText = tostring(btn.Text):lower()
                                    if string.match(btnText, "spawn") and not string.match(btnText, "despawn") then
                                        HardwareClick(btn)
                                        print("[AutoCar] Spawned Car!")
                                        task.wait(1)
                                        
                                        local ExitBtn = Menu:FindFirstChild("Exit") or Menu:FindFirstChild("Close")
                                        if ExitBtn then
                                            HardwareClick(ExitBtn)
                                        else
                                            local MainUI = PlayerGui:FindFirstChild("Main_User_Interface")
                                            if MainUI then
                                                local SpawnBtn = MainUI:FindFirstChild("UI_Frame"):FindFirstChild("Buttons"):FindFirstChild("Spawn")
                                                if SpawnBtn then HardwareClick(SpawnBtn) end
                                            end
                                        end
                                        break
                                    end
                                end
                            end
                            break
                        end
                    end
                end
            end
        end
    end
end

local GameModules = {
    Network = nil,
    RaceData = nil,
    Initialized = false
}

local function InitializeGameModules()
    if GameModules.Initialized then return true end

    local success, err = pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local rsModules = ReplicatedStorage:FindFirstChild("Modules")
        if rsModules then
            local subModules = rsModules:FindFirstChild("Modules")
            if subModules then
                local networkModule = subModules:FindFirstChild("Network")
                if networkModule then
                    GameModules.Network = require(networkModule)
                    print("[MCP] Network Module loaded successfully")
                end
            end
        end

        if workspace:FindFirstChild("Races") then
            GameModules.RaceData = workspace.Races
            print("[MCP] Race Data loaded successfully")
        end

        GameModules.Initialized = true
    end)

    if not success then
        warn("[MCP] Failed to initialize:", err)
        return false
    end

    return GameModules.Initialized
end

local function GetAvailableRaces()
    if not GameModules.RaceData then return {} end

    local races = {}
    for _, race in pairs(GameModules.RaceData:GetChildren()) do
        if race:IsA("Model") or race:IsA("Folder") then
            table.insert(races, {
                Name = race.Name,
                Instance = race,
                QueueRegion = race:FindFirstChild("QueueRegion"),
                Checkpoints = race:FindFirstChild("Checkpoints", true)
            })
        end
    end
    return races
end

local function SendNetworkCommand(command, arg1, arg2, arg3)
    if not GameModules.Network then
        warn("[MCP] Network Module not available")
        return false
    end

    local success = pcall(function()
        if type(GameModules.Network.FireServer) == "function" then
            GameModules.Network.FireServer(command, arg1, arg2, arg3)
            return true
        elseif type(GameModules.Network.Fire) == "function" then
            GameModules.Network.Fire(command, arg1, arg2, arg3)
            return true
        end
    end)

    return success
end

local function getCar()
    local car = workspace:FindFirstChild(LocalPlayer.Name .. "'s Car")
    if car and car:FindFirstChild("DriveSeat") then
        return car
    end
    return nil
end

local HardcodedCheckpoints = {
    CFrame.new(3322.75391, -2.98221874, 856.207031, 0.961249948, -0, -0.275678426, 0, 1, -0, 0.275678426, 0, 0.961249948),
    CFrame.new(3029.11035, -2.98251534, 660.071289, 0.90629667, -0, -0.422642082, 0, 1, -0, 0.422642082, 0, 0.90629667),
    CFrame.new(2712.32471, -2.71244168, 551.923279, 0.961249948, -0, -0.275678426, 0, 1, -0, 0.275678426, 0, 0.961249948),
    CFrame.new(2243.62769, 11.4912271, 400.442963, 0.961273968, -0, -0.275594592, 0, 1, -0, 0.275594592, 0, 0.961273968),
    CFrame.new(1904.36377, 26.7458763, 291.231598, 0.961273968, -0, -0.275594592, 0, 1, -0, 0.275594592, 0, 0.961273968),
    CFrame.new(1530.1626, 31.9467812, 174.704254, 0.961273968, -0, -0.275594592, 0, 1, -0, 0.275594592, 0, 0.961273968),
    CFrame.new(1002.90912, 31.9467812, 89.6374817, 0.997567594, -0, -0.069705762, 0, 1, -0, 0.069705762, 0, 0.997567594),
    CFrame.new(650.174438, 31.9467812, 85.0496674, 0.997561574, -0, -0.0697919354, 0, 1, -0, 0.0697919354, 0, 0.997561574),
    CFrame.new(-71.0034027, 31.9467812, 85.063797, 0.997561574, -0, -0.0697919354, 0, 1, -0, 0.0697919354, 0, 0.997561574),
    CFrame.new(-598.346558, 31.9467812, 90.0487671, 0.999847949, -0, -0.017436387, 0, 1, -0, 0.017436387, 0, 0.999847949),
    CFrame.new(-1268.3009, 27.0796738, 127.055672, 0.987685978, 0, 0.156449571, 0, 1, 0, -0.156449571, 0, 0.987685978),
    CFrame.new(-1907.99951, 0.0378112793, 273.795837, 0.987685978, 0, 0.156449571, 0, 1, 0, -0.156449571, 0, 0.987685978),
    CFrame.new(-2636.82983, 1.82403743, 428.264252, 0.987685978, 0, 0.156449571, 0, 1, 0, -0.156449571, 0, 0.987685978),
    CFrame.new(-3216.74487, 31.0064926, 553.652466, 0.978144467, 0, 0.207926437, 0, 1, 0, -0.207926437, 0, 0.978144467),
    CFrame.new(-3950.44702, 35.2185516, 709.604736, 0.978144467, 0, 0.207926437, 0, 1, 0, -0.207926437, 0, 0.978144467),
    CFrame.new(-4660.58008, 42.7379608, 850.122559, 0.978144467, 0, 0.207926437, 0, 1, 0, -0.207926437, 0, 0.978144467),
    CFrame.new(-5585.95361, 31.2529411, 1047.8811, 0.978144467, 0, 0.207926437, 0, 1, 0, -0.207926437, 0, 0.978144467),
    CFrame.new(-6619.43799, 21.7992363, 1267.53735, 0.978144467, 0, 0.207926437, 0, 1, 0, -0.207926437, 0, 0.978144467),
    CFrame.new(-7327.51709, 22.3053837, 1418.03223, 0.978144467, 0, 0.207926437, 0, 1, 0, -0.207926437, 0, 0.978144467),
    CFrame.new(-7821.0498, 21.3898964, 1591.77344, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-8344.55664, 20.6597939, 1812.67102, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-8821.00195, -3.07220554, 2015.56396, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-9545.2998, -66.8724213, 2322.6062, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-10178.6094, -105.570412, 2592.0708, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-10954.1738, -96.6220856, 2920.63599, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-11599.7734, -44.2234802, 3194.69482, 0.933587551, 0, 0.358349502, 0, 1, 0, -0.358349502, 0, 0.933587551),
    CFrame.new(-12214.1719, -3.47106814, 3455.34375, 0.919954896, 0.0324398763, 0.390679777, -0.0348830558, 0.999391019, -0.000842849724, -0.390469193, -0.01285272, 0.920526266),
    CFrame.new(-12793.3662, 10.8271008, 3767.78955, 0.819119215, 0.00760517037, 0.573572874, -0.00869537517, 0.999961853, -0.000840923283, -0.573557377, -0.0042986148, 0.819154143),
    CFrame.new(-13161.8184, 11.1573267, 4079.84912, 0.707068145, 0.00055025419, 0.707145214, -8.77476559e-05, 0.999999762, -0.000690396351, -0.707145452, 0.000426106912, 0.707068026),
    CFrame.new(-13403.8789, 11.0501556, 4361.43457, 0.601813793, -0.000193678774, 0.798636496, 0.000578846259, 0.999999821, -0.000193678774, -0.798636258, 0.000578846259, 0.601813793),
    CFrame.new(-13679.3926, 8.66257763, 4764.74316, 0.559158266, -0.0101906154, 0.828998327, 0.018619027, 0.99982661, -0.000267954543, -0.828851819, 0.0155849699, 0.55925107),
    CFrame.new(-14051.5127, -1.67429996, 5316.53223, 0.559165239, -0.00940431841, 0.829002857, 0.018643152, 0.999825418, -0.00123271719, -0.828846574, 0.0161445197, 0.559242964),
    CFrame.new(-14523.6396, 15.336587, 6016.59619, 0.559094846, -0.00818593241, 0.829063416, 0.0186413676, 0.999822617, -0.00269920612, -0.828894258, 0.0169639848, 0.559148252),
    CFrame.new(-14915.5742, 18.7651558, 6628.48779, 0.492507637, 0.00265895878, 0.870304048, 0.00116756, 0.99999243, -0.00371590909, -0.870307386, 0.00284624565, 0.492500782),
    CFrame.new(-15249.7432, 18.6678143, 7331.59521, 0.366565168, 0.00282828882, 0.930388093, 0.00154391024, 0.999992132, -0.00364816631, -0.930391073, 0.00277372659, 0.366557896),
    CFrame.new(-15492.7119, 15.584156, 8070.88379, 0.292316377, -0.003236413, 0.956316233, 0.0200774055, 0.999794662, -0.00275348965, -0.956110954, 0.0200052373, 0.292321324),
    CFrame.new(-15689.5098, 3.4773736, 8714.65625, 0.292299449, -0.00418970454, 0.956317663, 0.0209280103, 0.999778926, -0.00201655645, -0.956097841, 0.0206032619, 0.292322516),
    CFrame.new(-15938.4307, -8.57035923, 9528.83887, 0.292418897, 0.000300941523, 0.956290483, 0.003909308, 0.999991238, -0.00151010114, -0.956282496, 0.00418001506, 0.292415142),
    CFrame.new(-16209.8154, 10.1709061, 10416.7852, 0.292418897, 0.000300941523, 0.956290483, 0.003909308, 0.999991238, -0.00151010114, -0.956282496, 0.00418001506, 0.292415142),
    CFrame.new(-16381.0215, 20.5200958, 11257.1211, 0.156444013, 0.000900918618, 0.987686455, 0.00392035162, 0.999991119, -0.00153310422, -0.987679064, 0.00411192328, 0.156439066),
    CFrame.new(-16521.0684, 23.4328728, 12137.1777, 0.156372786, 0.00398549158, 0.987690032, -0.0252873637, 0.999680221, -3.03350389e-05, -0.987374365, -0.0249713343, 0.156423509)
}

local function teleportCar(cframe)
    local car = getCar()
    if not car then return end

    car:PivotTo(cframe + Vector3.new(0, 5, 0))
    for _, part in pairs(car:GetDescendants()) do
        if part:IsA("BasePart") then
            part.AssemblyLinearVelocity = Vector3.new(0, -100, 0)
            part.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

local function isUIActive(gui)
    if not gui then return false end
    if not gui.Enabled then return false end
    local container = gui:FindFirstChild("Container") or gui:FindFirstChild("Frame")
    if container and not container.Visible then return false end
    return true
end

local RaceState = {
    IsRacing = false,
    CurrentCheckpoint = 1,
    CurrentRace = nil,
    CheckpointsList = {}
}

local function FindAllCheckpoints(parent)
    local checkpoints = {}
    local seen = {} 

    for _, obj in pairs(parent:GetDescendants()) do
        if not seen[obj] then
            local name = string.lower(obj.Name)
            local isCheckpoint = false

            if tonumber(obj.Name) then
                isCheckpoint = true
            elseif string.match(name, "^checkpoint%d+") then
                isCheckpoint = true
            elseif string.match(name, "^cp%d+") then
                isCheckpoint = true
            elseif name == "finish" or string.match(name, "finish") then
                isCheckpoint = true
            end

            if isCheckpoint and (obj:IsA("BasePart") or obj:IsA("Model")) then
                table.insert(checkpoints, obj)
                seen[obj] = true
            end
        end
    end

    return checkpoints
end

local function LoadRaceCheckpoints(raceName)
    local races = GetAvailableRaces()
    for _, race in ipairs(races) do
        if race.Name == raceName then
            RaceState.CurrentRace = race
            RaceState.CheckpointsList = {}

            print("[MCP] ========================================")
            print("[MCP] Searching for checkpoints in " .. raceName .. "...")

            local allCheckpoints = FindAllCheckpoints(race.Instance)

            print("[MCP] Found " .. #allCheckpoints .. " potential checkpoints")

            local cps = {}
            local finishCp = nil

            for _, cp in pairs(allCheckpoints) do
                local name = string.lower(cp.Name)
                local cpNumber = tonumber(string.match(cp.Name, "%d+")) or tonumber(cp.Name)
                
                if name == "finish" or string.match(name, "finish") then
                    finishCp = cp
                    print("[MCP Debug] Found FINISH: " .. cp.Name)
                elseif cpNumber then
                    table.insert(cps, cp)
                end
            end

            table.sort(cps, function(a, b)
                local n1 = tonumber(string.match(a.Name, "%d+")) or tonumber(a.Name) or 0
                local n2 = tonumber(string.match(b.Name, "%d+")) or tonumber(b.Name) or 0
                return n1 < n2
            end)

            if finishCp then
                table.insert(cps, finishCp)
            end

            if #HardcodedCheckpoints > 0 then
                local newCps = {}
                for _, v in ipairs(HardcodedCheckpoints) do
                    table.insert(newCps, v)
                end
                
                if finishCp then
                    table.insert(newCps, finishCp)
                end
                
                cps = newCps
                print("[MCP] Loaded " .. #cps .. " Hardcoded CFrames + Finish Line successfully!")
            end

            RaceState.CheckpointsList = cps

            print("[MCP] ========================================")
            print("[MCP] Successfully loaded " .. #cps .. " checkpoints")
            print("[MCP] Checkpoint list:")
            for i, cp in ipairs(cps) do
                if typeof(cp) == "CFrame" then
                    print("[MCP]   #" .. i .. ": [Hardcoded CFrame]")
                else
                    print("[MCP]   #" .. i .. ": " .. cp.Name .. " (" .. cp.ClassName .. ")")
                end
            end
            print("[MCP] ========================================")

            if #cps == 0 then
                warn("[MCP] WARNING: No checkpoints found! Race might not work properly.")
                warn("[MCP] Race structure: " .. race.Instance:GetFullName())

                print("[MCP] Race children:")
                for _, child in pairs(race.Instance:GetChildren()) do
                    print("[MCP]   - " .. child.Name .. " (" .. child.ClassName .. ")")
                end
            end

            return #cps > 0
        end
    end
    return false
end

local function StartRace(raceName)
    if SendNetworkCommand("StartSoloRace", raceName) then
        print("[MCP] Started race via Network Module: " .. raceName)
        return true
    end

    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local RaceQueue = PlayerGui and PlayerGui:FindFirstChild("RaceQueue")

    if isUIActive(RaceQueue) then
        local container = RaceQueue:FindFirstChild("Container")
        local soloBtn = container and container:FindFirstChild("Solo")
        if soloBtn then
            HardwareClick(soloBtn)
            print("[MCP] Started race via UI click (fallback)")
            return true
        end
    end

    return false
end

local function checkAndRunAutoRace()
    if not getgenv().Config.AutoRace then return end

    if not GameModules.Initialized then
        InitializeGameModules()
    end

    local car = getCar()
    if not car then return end

    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return end

    local RacesUI = PlayerGui:FindFirstChild("Races")
    local CountdownUI = PlayerGui:FindFirstChild("Countdown")
    local driveSeat = car:FindFirstChild("DriveSeat")

    local isRacing = isUIActive(RacesUI)
    local isCountingDown = isUIActive(CountdownUI)
    local isCarFrozen = (driveSeat and driveSeat.Anchored) or isCountingDown

    if isCarFrozen then
        return
    end

    if isRacing then
        if not RaceState.IsRacing then
            RaceState.IsRacing = true
            RaceState.CurrentCheckpoint = 1
            LoadRaceCheckpoints(getgenv().Config.TargetRace)
        end

        if #RaceState.CheckpointsList > 0 then
            local hasFinishLine = false
            for _, cp in ipairs(RaceState.CheckpointsList) do
                if typeof(cp) == "CFrame" then
                    hasFinishLine = true 
                    break
                elseif typeof(cp) == "Instance" and cp.Name then
                    local name = string.lower(cp.Name)
                    if name == "finish" or string.match(name, "finish") then
                        hasFinishLine = true
                        break
                    end
                end
            end

            if RaceState.CurrentCheckpoint > #RaceState.CheckpointsList then
                if hasFinishLine then
                    print("[AutoRace] Waiting for server to finish race...")
                    return
                else
                    RaceState.CurrentCheckpoint = 1
                end
            end

            local currentCheckpoint = RaceState.CurrentCheckpoint

            if currentCheckpoint <= #RaceState.CheckpointsList then
                local cp = RaceState.CheckpointsList[currentCheckpoint]
                local targetCFrame
                
                if typeof(cp) == "CFrame" then
                    targetCFrame = cp
                else
                    local targetPart = cp
                    if cp:IsA("Model") then
                        targetPart = cp.PrimaryPart or cp:FindFirstChildWhichIsA("BasePart")
                    end
                    if targetPart then
                        targetCFrame = targetPart.CFrame
                    end
                end

                if targetCFrame then
                    local car = getCar()
                    if car then
                        teleportCar(targetCFrame)
                        print("[AutoRace] Teleported to Checkpoint " .. currentCheckpoint .. "/" .. #RaceState.CheckpointsList)
                        
                        RaceState.CurrentCheckpoint = currentCheckpoint + 1
                        task.wait(getgenv().Config.TeleportDelay or 0.5)
                    end
                end
            end
        end
    else
        if RaceState.IsRacing then
            RaceState.IsRacing = false
            RaceState.CurrentCheckpoint = 1
            print("[AutoRace] Race finished!")
        end

        local races = GetAvailableRaces()
        for _, race in ipairs(races) do
            if race.Name == getgenv().Config.TargetRace and race.QueueRegion then
                local carPart = car.PrimaryPart or driveSeat

                if carPart and (carPart.Position - race.QueueRegion.Position).Magnitude > 20 then
                    teleportCar(race.QueueRegion.CFrame)
                    print("[AutoRace] Teleported to " .. race.Name .. " queue")
                    task.wait(1)
                end

                if StartRace(race.Name) then
                    print("[AutoRace] Waiting 6 seconds for countdown...")
                    task.wait(7)
                end
                break
            end
        end
    end
end

local function checkAndRunAutoFarm()
    if not getgenv().Config.AutoFarm then return end
    if getgenv().Config.AutoRace then return end 

    local car = getCar()
    if not car then return end
    
    local driveSeat = car:FindFirstChild("DriveSeat")
    if not driveSeat then return end

    local carPart = car.PrimaryPart or driveSeat

    local skyY = 5000
    
    if carPart.Position.Y < skyY - 100 then
        car:PivotTo(CFrame.new(carPart.Position.X, skyY, carPart.Position.Z))
        print("[AutoFarm] Levitation Activated! Flying at Y=5000")
        task.wait(0.5)
    end

    for _, part in pairs(car:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end

    local maxDist = 20000
    if carPart.Position.X > maxDist then
        getgenv().AutoFarmState.Direction = -1
        car:PivotTo(CFrame.new(carPart.Position) * CFrame.Angles(0, math.pi, 0))
        print("[AutoFarm] Reached world border, U-Turning...")
    elseif carPart.Position.X < -maxDist then
        getgenv().AutoFarmState.Direction = 1
        car:PivotTo(CFrame.new(carPart.Position) * CFrame.Angles(0, math.pi, 0))
        print("[AutoFarm] Reached world border, U-Turning...")
    end

    local speed = getgenv().Config.FarmSpeed or 500
    local targetVel = Vector3.new(speed * getgenv().AutoFarmState.Direction, 0, 0)
    
    driveSeat.AssemblyAngularVelocity = Vector3.zero
    driveSeat.AssemblyLinearVelocity = targetVel
end

task.spawn(function()
    while task.wait(0.1) do 
        pcall(checkAndClickPlay)
        pcall(checkAndSelectStarterCar)
        pcall(checkAndSpawnCar)
        
        if getgenv().Config.AutoFarm then
            pcall(checkAndRunAutoFarm)
        elseif getgenv().Config.AutoRace then
            if tick() % 1 < 0.2 then
                pcall(checkAndRunAutoRace)
            end
        end
    end
end)

print("Midnight Chasers Script Loaded! (No UI, Auto Everything)")
