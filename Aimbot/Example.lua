local AimbotAPI = loadstring(game:HttpGet'https://github.com/RunDTM/Zeerox-Aimbot/raw/main/library.lua')()

AimbotAPI.Enabled = false
AimbotAPI.Key = Enum.UserInputType.MouseButton2
AimbotAPI.Smoothing = 0
AimbotAPI.Offset = {0, 0}

AimbotAPI.TeamCheck = false
AimbotAPI.AliveCheck = false
AimbotAPI.TeamCheck = false

AimbotAPI.Players = true
AimbotAPI.PlayerPart = 'Head'
AimbotAPI.FriendlyPlayers = {'name1', 'name2'}

AimbotAPI.FOV = 200
AimbotAPI.FOVCircleColor = Color3.fromRGB(255, 255, 255)
AimbotAPI.ShowFOV = true
AimbotAPI.CustomParts = {Instance.new('Part', workspace)}
