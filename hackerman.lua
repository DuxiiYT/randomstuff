if not game.IsLoaded then
    game.Loaded:wait();
end

local Players = game:GetService("Players");

local InsertService = game:GetService("InsertService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local CoreGui = game:GetService("CoreGui");

local TweenService = game:GetService("TweenService");
local UserInputService = game:GetService("UserInputService");

local RunService = game:GetService("RunService");

local LocalPlayer = Players.LocalPlayer;
local OnChatted = ReplicatedStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent;


if getgenv().Running then
    warn("Already running")
    printconsole("Already running")
    return;
end

local Admin = {
    Commands = {},
    Prefix = ">",
    Events = {},
    CEvents = {
        Tools = {},
        Whitelisted = {},
        InfiniteControlEvent = nil,
        Noclip = nil,
        View = {},
        LoopKill = {},
        LoopVoid = {},
    },
    Version = "1.0.3"
}

getgenv().Running = true;

local FlyTable = {
    ["W"] = 0,
    ["A"] = 0,
    ["S"] = 0,
    ["D"] = 0
}

local Keys = {}

-- Initializing UI
-- Not using local, because we need those values to be global

local NotificationUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/DuxiiYT/Notification/main/notif"))()

local UI = InsertService:LoadLocalAsset("rbxassetid://11243619448"):Clone();

CommandBar = UI.CommandBar;
Input = CommandBar.Input;

CommandList = UI.CommandList;
Container = CommandList.ScrollBar.Container;

CommandList.BackgroundTransparency = 1
CommandList.Visible = false

CommandList.Shadow.ImageTransparency = 1;

Container.CommandName.TextTransparency = 1
Container.CommandName.Description.TextTransparency = 1

CommandBar.BackgroundTransparency = 1

CommandBar.Shadow.ImageTransparency = 1;

Input.TextTransparency = 1
CommandBar.Position = UDim2.new(0.5, 0, 1, 35)

Container.Parent = nil;

UI.Parent = CoreGui;

X = UI.CommandList.Close


X.MouseButton1Click:Connect(function()
    CommandList.Visible = false
end)

local AddCommand = function(CommandName, Description, MainFunction, CommandArguments)
    for _, Command in pairs(Admin.Commands) do
        if string.lower(Command[1]) == string.lower(CommandName) then
            return nil; -- if command overrides
        end
    end
    -- ok ill try. after i eat tho in like 5 min
    if typeof(MainFunction) == "function" then
        if CommandArguments then -- make the template ui for the commandbar ig
            table.insert(Admin.Commands, {CommandName, Description, MainFunction, CommandArguments})
        else
            table.insert(Admin.Commands, {CommandName, Description, MainFunction})
        end
    else
        return nil;
    end
end

local speed = 50 -- This is the fly speed. Change it to whatever you like. The variable can be changed while running

local c
local h
local bv
local bav
local cam
local flying
local p = game.Players.LocalPlayer
local buttons = {
        W = false,
        S = false,
        A = false,
        D = false,
        Moving = false
}

local yesfly = function () -- Call this function to begin flying
        if not p.Character or not p.Character.Head or flying then
                return
        end
        
        c = p.Character
        h = c.Humanoid
        h.PlatformStand = true
        cam = workspace:WaitForChild('Camera')
        bv = Instance.new("BodyVelocity")
        bav = Instance.new("BodyAngularVelocity")
        bv.Velocity, bv.MaxForce, bv.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
        bav.AngularVelocity, bav.MaxTorque, bav.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
        bv.Parent = c.Head
        bav.Parent = c.Head
        flying = true
        h.Died:connect(function()
                flying = false
        end)
end

local nofly = function () -- Call this function to stop flying
        if not p.Character or not flying then
                return
        end
        h.PlatformStand = false
        bv:Destroy()
        bav:Destroy()
        flying = false
end

game:GetService("UserInputService").InputBegan:connect(function (input, GPE)
        if GPE then
                return
        end
        for i, e in pairs(buttons) do
                if i ~= "Moving" and input.KeyCode == Enum.KeyCode[i] then
                        buttons[i] = true
                        buttons.Moving = true
                end
        end
end)

function Encode(eid)

        local player = LocalPlayer['Name']
        local normalid = eid
        local reid = normalid
        
        local char_to_hex = function(c)
        return string.format("%%%02X", string.byte(c))
        end
        
        local function urlencode(url)
        if url == nil then
                return
        end 
        url = url:gsub("\n", "\r\n")
        url = url:gsub(".", char_to_hex)
        url = url:gsub(" ", "+")
        return url
        end
        function FixId(id)
                local dab = game:HttpGet("https://www.roblox.com/studio/plugins/info?assetId="..id)
                if string.find(dab, 'value="') then
                        local epic = string.find(dab, 'value="')
                        local almost = string.sub(dab, epic + 7, epic + 18)
                        local filter1 = string.gsub(almost, " ", "")
                        local filter2 = string.gsub(filter1, "/", "")
                        local filter3 = string.gsub(filter2, ">", "")
                        local filter4 = string.gsub(filter3, '"', "")
                        local versionid = string.gsub(filter4, "<", "")
                        return versionid
                end
        end
        local avidStr = "&assetversionid="
        local encid = FixId(reid)
        _G.song =avidStr .. encid


end

game:GetService("UserInputService").InputEnded:connect(function (input, GPE)
        if GPE then
                return
        end
        local a = false
        for i, e in pairs(buttons) do
                if i ~= "Moving" then
                        if input.KeyCode == Enum.KeyCode[i] then
                                buttons[i] = false
                        end
                        if buttons[i] then
                                a = true
                        end
                end
        end
        buttons.Moving = a
end)

local setVec = function (vec)
        return vec * (speed / vec.Magnitude)
end

game:GetService("RunService").Heartbeat:connect(function (step) -- The actual fly function, called every frame
        if flying and c and c.PrimaryPart then
                local p = c.PrimaryPart.Position
                local cf = cam.CFrame
                local ax, ay, az = cf:toEulerAnglesXYZ()
                c:SetPrimaryPartCFrame(CFrame.new(p.x, p.y, p.z) * CFrame.Angles(ax, ay, az))
                if buttons.Moving then
                        local t = Vector3.new()
                        if buttons.W then
                                t = t + (setVec(cf.lookVector))
                        end
                        if buttons.S then
                                t = t - (setVec(cf.lookVector))
                        end
                        if buttons.A then
                                t = t - (setVec(cf.rightVector))
                        end
                        if buttons.D then
                                t = t + (setVec(cf.rightVector))
                        end
                        c:TranslateBy(t * step)
                end
        end
end)


local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Toggled = false
local Keybind = "f"

Mouse.KeyDown:Connect(function(Key)
        if Key == Keybind then
                if Toggled then
                        Toggled = false
                        nofly()
                else
                        Toggled = true
                        yesfly()
                end
        end
end)

local GetIndex = function(Table, Element)
    for Index, Object in pairs(Table) do
        if Object == Element then
            return Index;
        end
    end
end

local GetPlayer = function(caller, Name)
    local PlayerList = Players:GetPlayers();
    Name = string.lower(tostring(Name));

    if Name == "random" then
        return {PlayerList[math.random(1, #PlayerList)]};
    elseif Name == "all" then
        return PlayerList;
    elseif Name == "others" then
        table.remove(PlayerList, GetIndex(PlayerList, caller));

        return PlayerList;
    elseif Name == "me" then
        return {caller};
    end

    for _, Player in pairs(Players:GetPlayers()) do
        if string.lower(string.sub(Player.Name, 1, #Name)) == Name then
            return {Player};
        elseif string.lower(string.sub(Player.DisplayName, 1, #Name)) == Name then
            return {Player};
        end
    end
end

local CommandCheck = function(caller, RawCommand)
    RawCommand = string.lower(RawCommand);

    local Splitted = string.split(RawCommand, " ");
    local Arguments = {};

    local CurrentCommand = Splitted[1];

    if string.sub(RawCommand, 1, 1) == Admin.Prefix then
        CurrentCommand = string.sub(CurrentCommand, 2)
    end

    for Index, Argument in pairs(Splitted) do
        if Index ~= 1 then
            table.insert(Arguments, Argument);
        end
    end

    for _, Command in pairs(Admin.Commands) do
        local Aliases = string.split(string.lower(Command[1]), "/"); -- rejoin/rj

        for _, Alias in pairs(Aliases) do
            if Alias == CurrentCommand then
                coroutine.wrap(function()
                    if Command[4] then -- Arguments
                        Command[3](caller, unpack(Arguments));
                    else
                        Command[3]();
                    end
                end)();
            end
        end
    end
end

local ReplaceHumanoid = function(Cam)
    local OldHum = LocalPlayer.Character:WaitForChild("Humanoid", math.huge);
    local NewHum = OldHum:Clone();

    if Cam then
        NewHum.Parent = LocalPlayer.Character;
        OldHum:Destroy();
    else
        OldHum:Destroy();
        NewHum.Parent = LocalPlayer.Character;
    end

    for _, Accessory in pairs(LocalPlayer.Character:GetChildren()) do
        if Accessory:IsA("Accessory") then
            sethiddenproperty(Accessory, "BackendAccoutrementState", 0);

            for _, Attachment in pairs(Accessory:GetDescendants()) do
                if Attachment:IsA("Attachment") then
                    Attachment:Destroy();
                end
            end
        end
    end

    if LocalPlayer.Character:FindFirstChild("Body Colors") then
        LocalPlayer.Character["Body Colors"]:Destroy();
    end
end

local AttachTool = function(Tool, Position, RHandGrip)
    if Position then
        local Arm = (LocalPlayer.Character:FindFirstChild("Right Arm") or
                        LocalPlayer.Character:FindFirstChild("RightHand")).CFrame *
                        CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0);
        Tool.Grip = Arm:ToObjectSpace(Position):Inverse();
    end
end

local GetTool = function()
    for _, Tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if Tool:FindFirstChild("Handle") then
            return Tool;
        end
    end

    return false;
end

local function GetNetlessVelocity(Velocity) -- edit this if you have a better netless method
    if Velocity.Y > 1 or Velocity.Y < -1 then
        return Velocity * (25.05 / Velocity.Y)
    end

    Velocity = Velocity * Vector3.new(1, 0, 1)

    local Magnitude = Velocity.Magnitude

    if Magnitude > 1 then
        Velocity = Velocity * 100 / Magnitude
    end

    return Velocity + Vector3.new(0, 25.05, 0)
end

local function Align(Part0, Part1, Position, Rotation)
    Part0.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.0001, 0.0001, 0.0001, 0.0001)
    Part0.CFrame = Part1.CFrame;

    local Attachment0 = Instance.new("Attachment", Part0)

    Attachment0.Orientation = Position or Vector3.new(0, 0, 0)
    Attachment0.Position = Vector3.new(0, 0, 0)
    Attachment0.Name = "Attachment0_" .. Part0.Name

    local Attachment1 = Instance.new("Attachment", Part1)

    Attachment1.Orientation = Vector3.new(0, 0, 0)
    Attachment1.Position = Position or Vector3.new(0, 0, 0)
    Attachment1.Name = "Attachment1_" .. Part1.Name

    local AlignPosition = Instance.new("AlignPosition", Attachment0)

    AlignPosition.ApplyAtCenterOfMass = false
    AlignPosition.MaxForce = math.huge
    AlignPosition.MaxVelocity = math.huge
    AlignPosition.ReactionForceEnabled = false
    AlignPosition.Responsiveness = 200
    AlignPosition.Attachment1 = Attachment1
    AlignPosition.Attachment0 = Attachment0
    AlignPosition.Name = "AlignPosition"
    AlignPosition.RigidityEnabled = false

    local AlignOrientation = Instance.new("AlignOrientation", Attachment0)
    AlignOrientation.MaxAngularVelocity = math.huge
    AlignOrientation.MaxTorque = math.huge
    AlignOrientation.PrimaryAxisOnly = false
    AlignOrientation.ReactionTorqueEnabled = false
    AlignOrientation.Responsiveness = 200
    AlignOrientation.Attachment1 = Attachment1
    AlignOrientation.Attachment0 = Attachment0
    AlignOrientation.RigidityEnabled = false

    local RVelocity = Vector3.new(0, 25.05, 0)

    local Stepped = RunService.Stepped:Connect(function()
        Part0.Velocity = RVelocity
    end)

    local Heartbeat = RunService.Heartbeat:Connect(function()
        RVelocity = Part0.Velocity
        Part0.Velocity = GetNetlessVelocity(RVelocity)
    end)

    Part0.Destroying:Connect(function()
        Part0 = nil

        Stepped:Disconnect()
        Heartbeat:Disconnect()
    end)

    Attachment0.Orientation = Rotation or Vector3.new(0, 0, 0)
    Attachment0.Position = Vector3.new(0, 0, 0)
    Attachment1.Orientation = Vector3.new(0, 0, 0)
    Attachment1.Position = Position or Vector3.new(0, 0, 0)

    Part0.CFrame = Part1.CFrame
end

local GetRoot = function(Character)
    return Character and Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso") or
               Character:FindFirstChild("LowerTorso")
end

local ReplaceCharacter = function()
    local Character = LocalPlayer.Character;
    local Model = Instance.new("Model");

    LocalPlayer.Character = Model;
    LocalPlayer.Character = Character;

    Model:Destroy()
end

local ReturnMass = function(Character)
    local Mass = 0;

    for _, Object in pairs(Character:GetChildren()) do
        if Object:IsA("BasePart") then
            Mass = Mass + Object:GetMass();
        end
    end

    return Mass;
end

local ResizeLeg = function(Amount)
    local Scales = {}

    if LocalPlayer.Character.Humanoid:FindFirstChild("Animator") then
        LocalPlayer.Character.Humanoid.Animator:Destroy();
    end

    for _, Scale in pairs(LocalPlayer.Character.Humanoid:GetChildren()) do
        if Scale:IsA("NumberValue") then
            table.insert(Scales, Scale);
        end
    end

    local Remove = function()
        LocalPlayer.Character.LeftFoot:WaitForChild("OriginalSize"):Destroy();

        LocalPlayer.Character.LeftLowerLeg:WaitForChild("OriginalSize"):Destroy()
        LocalPlayer.Character.LeftUpperLeg:WaitForChild("OriginalSize"):Destroy()
    end

    if LocalPlayer.Character.LeftLowerLeg:FindFirstChild("LeftKneeRigAttachment") then
        LocalPlayer.Character.LeftLowerLeg.LeftKneeRigAttachment:WaitForChild("OriginalPosition"):Destroy()

        LocalPlayer.Character.LeftLowerLeg.LeftKneeRigAttachment:Destroy()
    end

    if LocalPlayer.Character.LeftUpperLeg:FindFirstChild("LeftKneeRigAttachment") then
        LocalPlayer.Character.LeftUpperLeg.LeftKneeRigAttachment:WaitForChild("OriginalPosition"):Destroy()

        LocalPlayer.Character.LeftUpperLeg.LeftKneeRigAttachment:Destroy()
    end

    for Count = 1, Amount or 6 do
        Remove();

        Scales[Count]:Destroy()
    end
end

local ReasonCheck = function(Context, Reason)
    local Reasons = {
        ["Humanoid"] = "Could not "..Context.." because they have no humanoid",
        ["Dead"] = "Could not "..Context.." because they are dead",
        ["Sitting"] = "Could not "..Context.." because they are sitting",
        ["Arm"] = "Could not "..Context.." because they have no Right Arm",
        ["Mass"] = "Could not "..Context.." because they have more mass",
    }

    return Reasons[Reason];
end

local KillableCheck = function(Character, Context)
    print(Context)

    if not Character:FindFirstChild("Humanoid") then
        return ReasonCheck(Context, "Humanoid");
    end

    local Humanoid = Character:FindFirstChild("Humanoid");

    if Humanoid:GetState() == Enum.HumanoidStateType.Dead then
        return ReasonCheck(Context, "Dead");
    end

    if Humanoid.SeatPart ~= nil then
        return ReasonCheck(Context, "Sitting");
    end

    local Arm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")

    if not Arm then
        return ReasonCheck(Context, "Arm");
    end

    if ReturnMass(LocalPlayer.Character) < ReturnMass(Character) then
        if LocalPlayer.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
            return ReasonCheck(Context, "Mass");

        else
            repeat
                ResizeLeg(1);
            until ReturnMass(LocalPlayer.Character) > ReturnMass(Character)
        end
    end

    return Character:FindFirstChild("Head")
end

Admin.Events.Chatted = LocalPlayer.Chatted:Connect(function(Message)
    if string.sub(Message, 1, 1) == Admin.Prefix then
        CommandCheck(LocalPlayer, Message);
    end
end)

Admin.Events.GChatted = OnChatted:Connect(function(Data)
    if table.find(Admin.CEvents.Whitelisted, Data.SpeakerUserId) ~= nil then
        if string.sub(Data.Message, 1, 1) == Admin.Prefix then
            CommandCheck(Players:GetPlayerByUserId(Data.SpeakerUserId), Data.Message);
        end
    end
end)

CommandList.ScrollBar.Positioner:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    local absoluteSize = CommandList.ScrollBar.Positioner.AbsoluteContentSize
    CommandList.ScrollBar.CanvasSize = UDim2.new(0, absoluteSize.X, 0, absoluteSize.Y + 50)
end)

Admin.Events.InputBegan = UserInputService.InputBegan:Connect(
    function(KInput, ProcessedEvent)
        if ProcessedEvent then
            return
        end

        local KeyCode = tostring(KInput.KeyCode):split(".")[3]
        Keys[KeyCode] = true

        if KInput.KeyCode == Enum.KeyCode.Semicolon and not Admin.Debounce then
            Admin.Debounce = true;

            local Tweens = {}

            table.insert(Tweens, TweenService:Create(CommandBar, TweenInfo.new(.75, Enum.EasingStyle.Quint), {
                Position = UDim2.new(0.5, 0, 1, -100)
            }))
            table.insert(Tweens, TweenService:Create(CommandBar, TweenInfo.new(.75, Enum.EasingStyle.Quint), {
                BackgroundTransparency = 0
            }))
            table.insert(Tweens, TweenService:Create(Input, TweenInfo.new(.75, Enum.EasingStyle.Quint), {
                TextTransparency = 0
            }))
            table.insert(Tweens, TweenService:Create(CommandBar.Shadow, TweenInfo.new(.75, Enum.EasingStyle.Quint), {
                ImageTransparency = 0
            }))

            for _, Tween in pairs(Tweens) do
                Tween:Play();
            end

            task.wait();

            Input:CaptureFocus();
        end
    end)

Admin.Events.InputEnded = UserInputService.InputEnded:Connect(
    function(KInput, ProcessedEvent)
        if ProcessedEvent then
            return
        end

        local KeyCode = tostring(KInput.KeyCode):split(".")[3]

        if Keys[KeyCode] then
            Keys[KeyCode] = false
        end
    end)

Admin.Events.FocusLost = Input.FocusLost:Connect(function(Enter)
    if Enter then
        local Access = Input.Text

        local Tweens = {};

        table.insert(Tweens, TweenService:Create(CommandBar, TweenInfo.new(.75, Enum.EasingStyle.Quint), {
            Position = UDim2.new(0.5, 0, 1, 35)
        }))
        table.insert(Tweens, TweenService:Create(CommandBar, TweenInfo.new(.75, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 1
        }))
        table.insert(Tweens, TweenService:Create(Input, TweenInfo.new(.75, Enum.EasingStyle.Quint), {
            TextTransparency = 1
        }))
        table.insert(Tweens, TweenService:Create(CommandBar.Shadow, TweenInfo.new(.75, Enum.EasingStyle.Quint), {
            ImageTransparency = 1
        }))

        for _, Tween in pairs(Tweens) do
            Tween:Play();
        end

        Input.Text = ""

        task.wait();

        Admin.Debounce = false;

        CommandCheck(LocalPlayer, Access);
    end
end)

RunService.Heartbeat:Connect(function()
    sethiddenproperty(LocalPlayer, "MaximumSimulationRadius", math.huge);
    sethiddenproperty(LocalPlayer, "SimulationRadius", 9e9);

    settings().Physics.AllowSleep = false;

    LocalPlayer.ReplicationFocus = workspace;
end)

AddCommand("commands/cmds", "shows the command list in the console", function()
    CommandList.Visible = true

    local CommandsTween = TweenService:Create(CommandList, TweenInfo.new(.25, Enum.EasingStyle.Quint), {
        BackgroundTransparency = 0
    })
    CommandsTween:Play()

    CommandsTween.Completed:Wait()

    for _, Object in ipairs(CommandList.ScrollBar:GetDescendants()) do
        if Object.Name == "Container" then
            local TextLabelTween = TweenService:Create(Object.CommandName, TweenInfo.new(.025, Enum.EasingStyle.Quint),
                {
                    TextTransparency = 0
                })
            TextLabelTween:Play()

            local DescriptionTween = TweenService:Create(Object.CommandName.Description,
                TweenInfo.new(.025, Enum.EasingStyle.Quint), {
                    TextTransparency = 0
                })
            DescriptionTween:Play()

            DescriptionTween.Completed:Wait()
        end
    end
end)

AddCommand("cmdlist", "shows how much commands there are", function()
    NotificationUI.Notify("Commands", "There are "..#Admin.Commands.." commands available for now", 5);
end)

AddCommand("changeprefix/prefix", "changes your prefix", function(caller, prefix)
    if prefix then
        Admin.Prefix = prefix
    else
        NotificationUI.Notify("Prefix", "The Current Prefix is "..tostring(Admin.Prefix), 5)
    end
end, "prefix")

AddCommand("script", "says the script", function()
    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Moon Admin v"..Admin.Version, "All");
end)

AddCommand("quit/stopadmin/q", "stops the admin", function()
    for _, Event in pairs(Admin.Events) do
        Event:Disconnect();
    end

    UI:Destroy();

    getgenv().Running = false;

    NotificationUI.Notify("Moon Admin", "Stopped the admin", 5);
end)

AddCommand("respawn/re", "refreshes your character", function()
    ReplaceCharacter();

    wait(Players.RespawnTime - .05);

    local SavedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame;

    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(15);

    LocalPlayer.CharacterAdded:wait();
    game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
    LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = SavedPosition;
end)

AddCommand("resizeleg/leg", "resizes your leg", function(caller, amount)
    ResizeLeg(tonumber(amount));
end, "amount")

AddCommand("getmass/gmass", "refreshes your character", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        for _, Player in pairs(Target) do
            NotificationUI.Notify("Mass", tostring(ReturnMass(Player.Character)), 5)
        end
    else
        NotificationUI.Notify("Mass", tostring(ReturnMass(LocalPlayer.Character)), 5)
    end
end, "player")

AddCommand("antivoid", "prevents the target from voiding you", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        for _, Player in pairs(Target) do
            Player.Character.ChildRemoved:Connect(function(Child)
                if Child:IsA("Humanoid") then
                    NotificationUI.Notify("Anti Void", Player.Name.." tried to void you.", 5)

                    local Position = LocalPlayer.Character:GetPrimaryPartCFrame()
                    
                    workspace:FindFirstChildWhichIsA("Seat", true):Sit(LocalPlayer.Character.Humanoid)
                    LocalPlayer.Character:SetPrimaryPartCFrame(workspace:FindFirstChildWhichIsA("Seat", true).CFrame)

                    Player.CharacterAdded:wait();

                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping);

                    repeat game:GetService("RunService").Heartbeat:wait() until LocalPlayer.Character.Humanoid.SeatPart == nil;

                    LocalPlayer.Character:SetPrimaryPartCFrame(Position);
                end
            end)

            Player.CharacterAdded:Connect(function(Character)
                Character.ChildRemoved:Connect(function(Child)
                    if Child:IsA("Humanoid") then
                        NotificationUI.Notify("Anti Void", Player.Name.." tried to void you.", 5)
                        
                        local Position = LocalPlayer.Character:GetPrimaryPartCFrame()

                        workspace:FindFirstChildWhichIsA("Seat", true):Sit(LocalPlayer.Character.Humanoid)
                        LocalPlayer.Character:SetPrimaryPartCFrame(workspace:FindFirstChildWhichIsA("Seat", true).CFrame)

                        Player.CharacterAdded:wait();

                        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping);

                        repeat game:GetService("RunService").Heartbeat:wait() until LocalPlayer.Character.Humanoid.SeatPart == nil;

                        LocalPlayer.Character:SetPrimaryPartCFrame(Position);
                    end
                end)
            end)
        end
    end
end, "player")

AddCommand("goto", "teleports to a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        for _, Player in pairs(Target) do
            LocalPlayer.Character:SetPrimaryPartCFrame(GetRoot(Player.Character).CFrame);
        end
    end
end, "player")

AddCommand("walkspeed/ws", "i swear to god if you dont know what this means", function(_, speed)
    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed;
end, "speed")

AddCommand("jumppower/jp", "i swear to god if you dont know what this means", function(_, power)
    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = power;
end, "power")

AddCommand("view", "views a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        for _, Player in pairs(Target) do
            for _, Event in pairs(Admin.CEvents.View) do
                Event:Disconnect();
            end

            workspace.CurrentCamera.CameraSubject = Player.Character:FindFirstChildOfClass("Humanoid");

            Admin.CEvents.View[Player.Name.."_View"] = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject") :Connect(function()
                local Humanoid = Player.Character:WaitForChild("Humanoid", 2.5);

                if Humanoid then
                    workspace.CurrentCamera.CameraSubject = Humanoid
                end
            end)
        end
    end
end, "player")

AddCommand("unview", "unviews a player", function()
    for _, Event in pairs(Admin.CEvents.View) do
        Event:Disconnect();
    end

    workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid");
end)

AddCommand("rejoin/rj", "rejoins your server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer);
end)

AddCommand("checkgrabbers/cgrab/cgrabs", "checks if anyone is using grabtools", function()
    local Tool = GetTool();

    if Tool then
        Tool.Parent = LocalPlayer.Character;

        Tool.Parent = workspace;

        local GrabCheckerConnection = Tool.AncestryChanged:Connect(function(_, Parent)
            local Character = Parent;

            local Player = Players:GetPlayerFromCharacter(Character);

            NotificationUI.Notify("Grab Tools", Player.DisplayName .. " is grabbing tools", 5);
        end)

        task.delay(.5, function()
            GrabCheckerConnection:Disconnect();

            if Tool.Parent == workspace then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(Tool);
            end
        end)
    end
end)

AddCommand("noclip", "noclips your character", function()
    Admin.CEvents.Noclip = RunService.Stepped:Connect(function()
        for _, BPart in pairs(LocalPlayer.Character:GetChildren()) do
            if BPart:IsA("BasePart") then
                BPart.CanCollide = false;
            end
        end
    end)
end)

AddCommand("clip", "clips your character", function()
    if Admin.CEvents.Noclip then
        Admin.CEvents.Noclip:Disconnect();
    end
end)

AddCommand("sync", "syncs all playing audios", function()
    for _, Audio in pairs(workspace:GetDescendants()) do
        coroutine.wrap(function()
            if Audio:IsA("Sound") then
                Audio.TimePosition = 0;
            end
        end)();
    end
end)

AddCommand("dupe/dupetools", "dupes your tools", function(_, amount)
    Admin.CEvents.Tools = {};

    for Duped = 1, amount do
        ReplaceCharacter();

        wait(Players.RespawnTime - .05);

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame

        for _, Tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            Tool.Parent = LocalPlayer.Character;
        end

        for _, Tool in pairs(LocalPlayer.Character:GetChildren()) do
            if Tool:IsA("Tool") then
                Tool.Handle.Anchored = true;
                Tool.Parent = workspace;

                table.insert(Admin.CEvents.Tools, Tool)
            end
        end

        (LocalPlayer.Character:FindFirstChild("Right Arm") or LocalPlayer.Character:FindFirstChild("RightHand")):BreakJoints()

        ReplaceHumanoid();

        LocalPlayer.CharacterAdded:Wait()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position

        LocalPlayer.Character:WaitForChild("Humanoid");

        for Index, Tool in pairs(Admin.CEvents.Tools) do
            pcall(function()
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(Tool);

                Tool.Handle.Anchored = false;
            end);
        end
    end

    Admin.CEvents.Tools = {};
end, "amount")

AddCommand("dupefor", "dupes your tools for a player", function(caller, player, amount)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        for Duped = 1, amount do
            ReplaceHumanoid();

            local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

            for _, Player in pairs(Target) do
                local TouchInterest = Player.Character.Head;
    
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    task.wait();

                    Tool.Handle:BreakJoints();

                    firetouchinterest(Tool.Handle, TouchInterest, 0);
                end
            end

            LocalPlayer.CharacterAdded:wait();

            repeat RunService.Heartbeat:wait() until LocalPlayer.Character:FindFirstChild("Body Colors");

            LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position
        end
    end
end, "player, amount")

AddCommand("jail", "works for only dollhouse rp", function(caller, player)
    if game.PlaceId == 417267366 then
        local Target = GetPlayer(caller, player);

        if Target ~= nil then
            if #Target == 1 then
                local Check = KillableCheck(Target[1].Character, "jail "..Target[1].DisplayName);

                if type(Check) == "string" then
                    NotificationUI.Notify("Jail", Check, 5)

                    return
                end
            end

            local BEvents = {};

            local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

            ReplaceHumanoid();

            for _, Player in pairs(Target) do
                local Check = KillableCheck(Player.Character, "jail "..Player.DisplayName);

                if type(Check) ~= "string"  then
                    local Tool = GetTool();

                    if Tool then
                        Tool.Parent = LocalPlayer.Character

                        AttachTool(Tool,
                            CFrame.new(5534.38086, -5000, -17137.502, 0.984812498, -0, -0.173621148, 0, 1, -0, 0.173621148, 0, 0.984812498));

                        BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                            BEvents[Tool]:Disconnect();

                            LocalTool.Handle:BreakJoints();
                        end)

                        firetouchinterest(Tool.Handle, Check, 0);

                        NotificationUI.Notify("Jail", "Successfully jailed "..Player.DisplayName.."!", 5)
                    else
                        NotificationUI.Notify("Jail", "You don't have enough tools!", 5)
                    end
                else
                    NotificationUI.Notify("Jail", Check, 5)
                end
            end

            LocalPlayer.CharacterAdded:wait();
            LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
        end
    else
        NotificationUI.Notify("Game", "The game isn't Dollhouse Roleplay!", 5)
    end
end, "player")

AddCommand("bathroom", "works for only dollhouse rp", function(caller, player)
    if game.PlaceId == 417267366 then
        local Target = GetPlayer(caller, player);

        if Target ~= nil then
            if #Target == 1 then
                local Check = KillableCheck(Target[1].Character, "bathroom "..Target[1].DisplayName);

                if type(Check) == "string" then
                    NotificationUI.Notify("Bathroom", Check, 5)

                    return
                end
            end

            local BEvents = {};

            local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

            ReplaceHumanoid();

            for _, Player in pairs(Target) do
                local Check = KillableCheck(Target[1].Character, "bathroom "..Target[1].DisplayName);

                if type(Check) ~= "string" then
                    local Tool = GetTool();

                    if Tool then
                        Tool.Parent = LocalPlayer.Character

                        AttachTool(Tool, game:GetService("Workspace")["Bathroom Toilet"].Seat.CFrame);

                        BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                            BEvents[Tool]:Disconnect();

                            LocalTool.Handle:BreakJoints();
                        end)

                        firetouchinterest(Tool.Handle, Check, 0);

                        NotificationUI.Notify("Bathroom", "Successfully bathroomed "..Player.DisplayName.."!", 5)
                    else
                        NotificationUI.Notify("Bathroom", "You don't have enough tools!", 5)
                    end
                else
                    NotificationUI.Notify("Bathroom", Check, 5)
                end
            end

            LocalPlayer.CharacterAdded:wait();
            LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
        end
    else
        NotificationUI.Notify("Game", "The game isn't Dollhouse Roleplay!", 5)
    end
end, "player")

AddCommand("ReplaceHumanoid/Humanoid/Hum", "replaces your humanoid", ReplaceHumanoid)

AddCommand("kill", "kills a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "kill "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("Kill", Check, 5)

                return
            end
        end

        local BEvents = {};

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(15);

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "kill "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    AttachTool(Tool, Check.CFrame);

                    BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                        BEvents[Tool]:Disconnect();

                        LocalTool.Handle:BreakJoints();
                    end)

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("Kill", "Successfully killed "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Kill", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Kill", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("loopkill/lkill", "loopkills a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "LoopKill "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("LoopKill", Check, 5)

                return
            end
        end

        local BEvents = {};

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(15);

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "kill "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    AttachTool(Tool, Check.CFrame);

                    BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                        BEvents[Tool]:Disconnect();

                        LocalTool.Handle:BreakJoints();
                    end)

                    firetouchinterest(Tool.Handle, Check, 0);

                    table.insert(Admin.CEvents.LoopKill, Player)
                else
                    NotificationUI.Notify("LoopKill", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Kill", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;

        while #Admin.CEvents.LoopKill ~= 0 do
            local BEvents = {};

            LocalPlayer.Character:WaitForChild("Humanoid");

            for _, Player in pairs(Target) do
                if not Player.Character then
                    repeat RunService.Heartbeat:wait() until Player.Character
                end

                repeat RunService.Heartbeat:wait() until Player.Character:FindFirstChildOfClass("Humanoid")
                repeat RunService.Heartbeat:wait() until Player.Character:FindFirstChildOfClass("Humanoid"):FindFirstChild("Animator");

                repeat RunService.Heartbeat:wait() until Player.Character:FindFirstChild("Right Arm") or Player.Character:FindFirstChild("RightHand")
            end

            wait(.055);

            ReplaceHumanoid();

            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(15);
    
            for _, Player in pairs(Target) do
                local TouchInterest = "Head";
    
                TouchInterest = Player.Character:WaitForChild(TouchInterest);

                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    AttachTool(Tool, TouchInterest.CFrame);

                    BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                        BEvents[Tool]:Disconnect();

                        LocalTool.Handle:BreakJoints();
                    end)

                    firetouchinterest(Tool.Handle, TouchInterest, 0);
                end
            end
    
            LocalPlayer.CharacterAdded:wait();
            LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
        end
    end
end, "player")

AddCommand("unloopkill/unlkill", "stops loopkilling", function()
    Admin.CEvents.LoopKill = {};
end)

AddCommand("walkkill/wkill", "kills the player while you have less mass", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "WalkKill "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("WalkKill", Check, 5)

                return
            end
        end

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 1e2 * 5, 1e4)

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "WalkKill "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    Tool.Handle.Position = Check.Position;

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("WalkKill", "Successfully WalkKill "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("WalkKill", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("WalkKill", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("fastkill/fkill", "fast kills a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "kill "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("Kill", Check, 5)

                return
            end
        end

        local BEvents = {};

        ReplaceCharacter();

        wait(Players.RespawnTime - .05)

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(15);

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "kill "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    AttachTool(Tool, Check.CFrame);

                    BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                        BEvents[Tool]:Disconnect();

                        LocalTool.Handle:BreakJoints();
                    end)

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("Kill", "Successfully killed "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Kill", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Kill", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("masskill/mkill", "mass kills a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if LocalPlayer.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
            NotificationUI.Notify("MassKill", "Not R15", 5)
        end

        ResizeLeg()

        local BEvents = {};

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(15);

        for _, Player in pairs(Target) do
            local Tool = GetTool()

            if Tool then
                local Check = Player.Character.Head;

                Tool.Parent = LocalPlayer.Character;

                AttachTool(Tool, Check.CFrame);

                BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                    BEvents[Tool]:Disconnect();

                    LocalTool.Handle:BreakJoints();
                end)

                firetouchinterest(Tool.Handle, Check, 0);

                NotificationUI.Notify("MassKill", "Successfully MassKilled "..Player.DisplayName.."!", 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("bring", "brings a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "bring "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("Bring", Check, 5)

                return
            end
        end

        local BEvents = {};

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "bring "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    AttachTool(Tool, caller.Character.HumanoidRootPart.CFrame);

                    BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                        BEvents[Tool]:Disconnect();

                        LocalTool.Handle:BreakJoints();
                    end)

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("Bring", "Successfully bringed "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Bring", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Bring", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("fastbring/fbring", "fast brings a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "bring "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("Bring", Check, 5)

                return
            end
        end

        ReplaceCharacter();

        wait(Players.RespawnTime - .05);

        local BEvents = {};

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "kill "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    AttachTool(Tool, caller.Character.HumanoidRootPart.CFrame);

                    BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                        BEvents[Tool]:Disconnect();

                        LocalTool.Handle:BreakJoints();
                    end)

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("Bring", "Successfully bringed "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Bring", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Bring", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("void", "voids a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "void "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("Void", Check, 5)

                return
            end
        end

        ReplaceHumanoid(true);

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(0, -9000, 0))

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "void "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("Void", "Successfully voided "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Void", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Void", Check, 5)
            end
        end
        
        workspace.FallenPartsDestroyHeight = -506

        LocalPlayer.CharacterAdded:wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("massvoid/mvoid", "mass voids a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if LocalPlayer.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
            NotificationUI.Notify("MassKill", "Not R15", 5)
        end

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        ResizeLeg();

        workspace.FallenPartsDestroyHeight = 0 / 0;

        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(0, -499, 0));

        ReplaceHumanoid(true);

        for _, Player in pairs(Target) do
            local Tool = GetTool();

            if Tool then
                local Check = Player.Character.Head;

                Tool.Parent = LocalPlayer.Character;

                firetouchinterest(Tool.Handle, Check, 0);
            end
        end

        workspace.FallenPartsDestroyHeight = -506

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("loopmassvoid/loopmvoid/lmvoid", "loopvoids a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if LocalPlayer.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
            NotificationUI.Notify("LoopVoid", "Not R15", 5)
        end

        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "LoopVoid "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("LoopVoid", Check, 5)

                return
            end
        end

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        ResizeLeg();

        workspace.FallenPartsDestroyHeight = 0 / 0;

        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(0, -499, 0));

        ReplaceHumanoid(true);

        for _, Player in pairs(Target) do
            local Tool = GetTool();

            if Tool then
                local Check = Player.Character.Head;

                Tool.Parent = LocalPlayer.Character;

                firetouchinterest(Tool.Handle, Check, 0);
            end

            table.insert(Admin.CEvents.LoopVoid, Player)
        end

        workspace.FallenPartsDestroyHeight = -506

        LocalPlayer.CharacterAdded:wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;

        while #Admin.CEvents.LoopVoid ~= 0 do
            LocalPlayer.Character:WaitForChild("Humanoid");

            ResizeLeg();

            for _, Player in pairs(Target) do
                if not Player.Character then
                    repeat RunService.Heartbeat:wait() until Player.Character
                end

                repeat RunService.Heartbeat:wait() until Player.Character:FindFirstChildOfClass("Humanoid")
                repeat RunService.Heartbeat:wait() until Player.Character:FindFirstChildOfClass("Humanoid"):FindFirstChild("Animator");

                repeat RunService.Heartbeat:wait() until Player.Character:FindFirstChild("Right Arm") or Player.Character:FindFirstChild("RightHand")
            end
    
            workspace.FallenPartsDestroyHeight = 0 / 0;
    
            LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(0, -499, 0));
    
            ReplaceHumanoid(true);
    
            for _, Player in pairs(Target) do
                local Tool = GetTool();

                if Tool then
                    local Check = Player.Character.Head;
    
                    Tool.Parent = LocalPlayer.Character;
    
                    firetouchinterest(Tool.Handle, Check, 0);
                end
            end
    
            workspace.FallenPartsDestroyHeight = -506
    
            LocalPlayer.CharacterAdded:wait();
            LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
        end
    end
end, "player")

AddCommand("unloopvoid/unlmvoid", "stops loopvoiding", function()
    Admin.CEvents.LoopVoid = {};
end)

AddCommand("punish", "punishes a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "punish "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("Punish", Check, 5)

                return
            end
        end

        local BEvents = {};

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gethiddenproperty(LocalPlayer, "SimulationRadius"), gethiddenproperty(LocalPlayer, "SimulationRadius"), gethiddenproperty(LocalPlayer, "SimulationRadius"))

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "punish "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                        BEvents[Tool]:Disconnect();

                        LocalTool.Handle:BreakJoints();
                    end)

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("Punish", "Successfully punished "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Punish", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Punish", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("attach", "attaches a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "attach "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("Attach", Check, 5)

                return
            end
        end

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "attach "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("Attach", "Successfully attached "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Attach", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Attach", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("massattach/mattach", "mass attaches a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "MassAttach "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("MassAttach", Check, 5)

                return
            end
        end

        ResizeLeg();

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "attach "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("MassAttach", "Successfully masskilled "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("MassAttach", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("MassAttach", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("control", "controls a player for " .. tostring(Players.RespawnTime) .. " seconds", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil and #Target == 1 then
        local Position = LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame;

        ReplaceHumanoid();

        local BEvent;

        local Noclip = RunService.Stepped:Connect(function()
            for _, BPart in pairs(LocalPlayer.Character:GetChildren()) do
                if BPart:IsA("BasePart") then
                    BPart.CanCollide = false;
                end
            end
        end)

        local Velocity = game:GetService("RunService").Heartbeat:Connect(function()
            LocalPlayer.Character.HumanoidRootPart.Velocity = LocalPlayer.Character.Humanoid.MoveDirection * 20;
        end)

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "control "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    local VPos = Player.Character.HumanoidRootPart.Position;

                    Tool.Handle.CanCollide = false;

                    AttachTool(Tool, LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(1.5, 10, 0) *
                        CFrame.Angles(0, math.rad(90), 0));

                    firetouchinterest(Tool.Handle, Check, 0);

                    BEvent = Tool.AncestryChanged:Connect(function()
                        BEvent:Disconnect();

                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(VPos) * CFrame.new(0, -10, 0);

                        workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid;
                    end)

                    NotificationUI.Notify("Control", "Successfully controlled "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Control", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Control", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;

        Noclip:Disconnect();
        Velocity:Disconnect();
    end
end, "player")

AddCommand("infinitecontrol/icontrol", "controls a player for infinity", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil and #Target == 1 then
        local Position = LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame;

        Admin.CEvents.InfiniteControlEvent = LocalPlayer.CharacterAdded:Connect(function()
            LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;

            wait(.25);

            ReplaceHumanoid();

            local BEvent;

            local Noclip = RunService.Stepped:Connect(function()
                for _, BPart in pairs(LocalPlayer.Character:GetChildren()) do
                    if BPart:IsA("BasePart") then
                        BPart.CanCollide = false;
                    end
                end
            end)

            local Velocity = game:GetService("RunService").Heartbeat:Connect(function()
                LocalPlayer.Character.HumanoidRootPart.Velocity = LocalPlayer.Character.Humanoid.MoveDirection * 20;
            end)

            for _, Player in pairs(Target) do
                local Check = KillableCheck(Player.Character, "control "..Player.DisplayName);
    
                if type(Check) ~= "string" then
                    local Tool = GetTool();
    
                    if Tool then
                        Tool.Parent = LocalPlayer.Character;
    
                        local VPos = Player.Character.HumanoidRootPart.Position;
    
                        Tool.Handle.CanCollide = false;
    
                        AttachTool(Tool, LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(1.5, 10, 0) *
                            CFrame.Angles(0, math.rad(90), 0));
    
                        firetouchinterest(Tool.Handle, Check, 0);
    
                        BEvent = Tool.AncestryChanged:Connect(function()
                            BEvent:Disconnect();
    
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(VPos) * CFrame.new(0, -10, 0);
    
                            workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid;
                        end)
    
                        NotificationUI.Notify("Control", "Successfully controlled "..Player.DisplayName.."!", 5)
                    else
                        NotificationUI.Notify("Control", "You don't have enough tools!", 5)
                    end
                else
                    NotificationUI.Notify("Control", Check, 5)
                end
            end    

            LocalPlayer.CharacterAdded:wait();

            Noclip:Disconnect();
            Velocity:Disconnect();
        end)

        LocalPlayer.Character:WaitForChild("Humanoid");

        ReplaceHumanoid();

        local BEvent;

        local Noclip = RunService.Stepped:Connect(function()
            for _, BPart in pairs(LocalPlayer.Character:GetChildren()) do
                if BPart:IsA("BasePart") then
                    BPart.CanCollide = false;
                end
            end
        end)

        local Velocity = game:GetService("RunService").Heartbeat:Connect(function()
            LocalPlayer.Character.HumanoidRootPart.Velocity = LocalPlayer.Character.Humanoid.MoveDirection * 20;
        end)

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "control "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    local VPos = Player.Character.HumanoidRootPart.Position;

                    Tool.Handle.CanCollide = false;

                    AttachTool(Tool, LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(1.5, 10, 0) *
                        CFrame.Angles(0, math.rad(90), 0));

                    firetouchinterest(Tool.Handle, Check, 0);

                    BEvent = Tool.AncestryChanged:Connect(function()
                        BEvent:Disconnect();

                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(VPos) * CFrame.new(0, -10, 0);

                        workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid;
                    end)

                    NotificationUI.Notify("Control", "Successfully controlled "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Control", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Control", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:Wait();

        Noclip:Disconnect();
        Velocity:Disconnect();
    end
end, "player")

AddCommand("uninfintecontrol/unicontrol/uncontrol", "stops controlling", function()
    if Admin.CEvents.InfiniteControlEvent then
        Admin.CEvents.InfiniteControlEvent:Disconnect();
    end
end)

AddCommand("grab", "grabs a player for " .. tostring(Players.RespawnTime) .. " seconds", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil and #Target == 1 then
        local Position = LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame;

        local Knife = LocalPlayer.Character:FindFirstChild("YandereKnife");

        if not Knife then
            return;
        end

        local Animation = Instance.new("Animation");

        Animation.AnimationId = "rbxassetid://182393478";

        local LoadedAnimation = LocalPlayer.Character.Humanoid:LoadAnimation(Animation);

        LoadedAnimation:Play();
        LoadedAnimation:AdjustSpeed(0);

        LocalPlayer.Character:FindFirstChild("Left Arm"):BreakJoints();
        Align(LocalPlayer.Character:FindFirstChild("Left Arm"), LocalPlayer.Character.HumanoidRootPart,
            Vector3.new(-1.5, 1, -.5), Vector3.new(90, 90, 0))

        wait(.35);

        ReplaceHumanoid();

        Knife.Handle:BreakJoints();
        Align(Knife.Handle, LocalPlayer.Character:FindFirstChild("Right Arm") or
            LocalPlayer.Character:FindFirstChild("RightLowerArm"), Vector3.new(-Knife.Handle.Size.X, -1.5, 0),
            Vector3.new(90, 180, 0));

        local Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character == nil then
                return;
            end

            for _, BPart in pairs(LocalPlayer.Character:GetChildren()) do
                if BPart and BPart:IsA("BasePart") then
                    BPart.CanCollide = false;
                end
            end
        end)

        local Kill = LocalPlayer:GetMouse().Button1Down:Connect(function()
            LocalPlayer.Character.Humanoid:ChangeState(15);

            LocalPlayer.Character = nil;
        end)

        for _, Player in pairs(Target) do
            Player.Character.Humanoid.PlatformStand = true;

            local Tool = GetTool();

            if Tool then
                local Check = Player.Character.Head;

                Tool.Parent = LocalPlayer.Character;

                local VPos = Player.Character.HumanoidRootPart.Position;

                Tool.Handle.CanCollide = false;

                Tool.Grip = CFrame.new(1, 0, -2) * CFrame.Angles(math.rad(90), math.rad(90), 0);

                firetouchinterest(Tool.Handle, Check, 0);
            else
                NotificationUI.Notify("Grab", "Not enough tools!")
            end
        end

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;

        Kill:Disconnect();
        Noclip:Disconnect();
    end
end, "player")

AddCommand("skydive", "skydives a player", function(caller, player, studs)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "skydive "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("SkyDive", Check, 5)

                return
            end
        end

        local BEvents = {};

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "skydive "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    AttachTool(Tool, Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, studs or 800, 0));

                    BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                        BEvents[Tool]:Disconnect();

                        LocalTool.Handle:BreakJoints();
                    end)

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("SkyDive", "Successfully skydived "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("SkyDive", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("SkyDive", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player, studs")

AddCommand("sink", "sinks a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "skydive "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("SkyDive", Check, 5)

                return
            end
        end

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        local Noclip = RunService.Stepped:Connect(function()
            for _, BPart in pairs(LocalPlayer.Character:GetChildren()) do
                if BPart:IsA("BasePart") then
                    BPart.CanCollide = false;
                end
            end
        end)

        ReplaceHumanoid();

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "sink "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    AttachTool(Tool, Player.Character.HumanoidRootPart.CFrame);

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("Sink", "Successfully sinked "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Sink", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Sink", Check, 5)
            end
        end

        wait(.055);

        local Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart,
            TweenInfo.new(2.5, Enum.EasingStyle.Linear), {
                CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -15, 0)
            });

        Tween:Play();

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;

        Noclip:Disconnect();
    end
end, "player")

AddCommand("kidnap", "kidnaps a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "skydive "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("SkyDive", Check, 5)

                return
            end
        end

        if #Target > 1 then
            return;
        end

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        local Noclip = RunService.Stepped:Connect(function()
            for _, BPart in pairs(LocalPlayer.Character:GetChildren()) do
                if BPart:IsA("BasePart") then
                    BPart.CanCollide = false;
                end
            end
        end)

        for _, Animation in pairs(LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
            Animation:Stop()
        end

        local Player = Target[1];

        ReplaceHumanoid();

        LocalPlayer.Character.Humanoid:ChangeState(15);

        LocalPlayer.Character.HumanoidRootPart.CFrame =
            Player.Character.HumanoidRootPart.CFrame * CFrame.new(25, 0, -5) * CFrame.Angles(0, math.rad(90), 0);

        local Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart,
            TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
                CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5) *
                    CFrame.Angles(0, math.rad(90), 0)
            })

        Tween:Play();
        Tween.Completed:wait();

        wait(.5);

        local Tool = GetTool();

        if Tool then
            Tool.Parent = LocalPlayer.Character;

            AttachTool(Tool, LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(1.5, 2.5, 0) *
                CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)))

            firetouchinterest(Tool.Handle, Player.Character.Head, 0);

            Tool.AncestryChanged:wait();
        else
            NotificationUI.Notify("Kidnap", "You don't have enough tools!", 5)
        end

        wait(.25);

        local Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart,
            TweenInfo.new(2.25, Enum.EasingStyle.Linear), {
                CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -100)
            });

        Tween:Play();
        Tween.Completed:wait();

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;

        Noclip:Disconnect();
    end
end, "player")

AddCommand("explode", "explodes a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "explode "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("Explode", Check, 5)

                return
            end
        end

        local BEvents = {};

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(15);

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "explode "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    AttachTool(Tool, Check.CFrame * CFrame.new(0, 250, 0));

                    BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                        BEvents[Tool]:Disconnect();

                        LocalTool.Handle:BreakJoints();
                    end)

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("Explode", "Successfully exploded "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Explode", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Explode", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("firework", "makes a player turn into a firework", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "firework "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("FireWork", Check, 5)

                return
            end
        end

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "firework "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    firetouchinterest(Tool.Handle, Check, 0);

                    AttachTool(Tool, Player.Character.HumanoidRootPart.CFrame);

                    NotificationUI.Notify("FireWork", "Successfully fireworked "..Player.DisplayName.."!", 5)

                    workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid;
                else
                    NotificationUI.Notify("FireWork", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("FireWork", Check, 5)
            end
        end

        task.delay(.15, function()
            local Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(1.5), {CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 200, 0)});
            Tween:Play();

            Tween.Completed:wait();

            LocalPlayer.Character.Humanoid:ChangeState(15);
            LocalPlayer.Character = nil;
        end)

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("fling", "flings a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        local Position, Velocity = LocalPlayer.Character.HumanoidRootPart.CFrame,
            LocalPlayer.Character.HumanoidRootPart.Velocity;

        for _, Player in pairs(Target) do
            local PPosition = GetRoot(Player.Character).Position;

            local Running = RunService.Stepped:Connect(function(step)
                step = step - workspace.DistributedGameTime;

                GetRoot(LocalPlayer.Character).CFrame = (GetRoot(Player.Character).CFrame -
                                                            (Vector3.new(0, 1e6, 0) * step)) +
                                                            (GetRoot(Player.Character).Velocity * (step * 30));
                GetRoot(LocalPlayer.Character).Velocity = Vector3.new(0, 1e6, 0)
            end)

            local STime = tick();

            repeat
                wait();

            until (PPosition - GetRoot(Player.Character).Position).Magnitude >= 60 or tick() - STime >= 1;

            Running:Disconnect();

            GetRoot(LocalPlayer.Character).Velocity = Velocity;
            GetRoot(LocalPlayer.Character).CFrame = Position;

            wait();
        end

        local Running = RunService.Stepped:Connect(function()
            GetRoot(LocalPlayer.Character).Velocity = Velocity;
            GetRoot(LocalPlayer.Character).CFrame = Position;
        end)

        wait(2);

        GetRoot(LocalPlayer.Character).Anchored = true

        Running:Disconnect();

        GetRoot(LocalPlayer.Character).Anchored = false

        GetRoot(LocalPlayer.Character).Velocity = Velocity;
        GetRoot(LocalPlayer.Character).CFrame = Position;
    end
end, "player")

AddCommand("getoutfit","Steal someones outfit (need to have their items)",function()
    for _, Target in pairs(GetPlayer(args[2])) do
    game:GetService("AvatarEditorService"):PromptSaveAvatar(Target.Character.Humanoid.HumanoidDescription,Enum.HumanoidRigType.R6)
    end
end)

AddCommand("fflag", "Don't know",function()
    local TeleportService = game:GetService("TeleportService")
TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
syn.queue_on_teleport([[
setfflag("AvatarEditorServiceEnabled2_PlaceFilter", "True;]]..game.PlaceId..[[");
]])
end)

AddCommand("r6","Change your body type to R6",function()
game:GetService("AvatarEditorService"):PromptSaveAvatar(game.Players.LocalPlayer.Character.Humanoid.HumanoidDescription,Enum.HumanoidRigType.R6)
mousemoveabs(2060,1320)
wait(0.1)
mousemoveabs(2061,1321)
wait(0.1)
mouse1click()
ReplaceCharacter();

wait(Players.RespawnTime - .05);

local SavedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame;

LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(15);

LocalPlayer.CharacterAdded:wait();
game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = SavedPosition;
end)

AddCommand("r15", "Change your body type to R15",function()
game:GetService("AvatarEditorService"):PromptSaveAvatar(game.Players.LocalPlayer.Character.Humanoid.HumanoidDescription,Enum.HumanoidRigType.R15)
mousemoveabs(2060,1320)
wait(0.1)
mousemoveabs(2061,1321)
wait(0.1)
mouse1click()
ReplaceCharacter();

wait(Players.RespawnTime - .05);

local SavedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame;

LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(15);

LocalPlayer.CharacterAdded:wait();
game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = SavedPosition;
end)

AddCommand("toolfling/tfling", "tool flings a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if LocalPlayer.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
            warn("not r15")

            return
        end

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        for _, Player in pairs(Target) do
            local Tool = GetTool();

            if Tool then
                local Check = Player.Character.Head;

                Tool.Parent = LocalPlayer.Character;

                firetouchinterest(Tool.Handle, Check, 0);
            end
        end

        local BodyVelocity = Instance.new("BodyAngularVelocity");

        BodyVelocity.MaxTorque = Vector3.new(1, 1, 1) * math.huge
        BodyVelocity.P = math.huge
        BodyVelocity.AngularVelocity = Vector3.new(1, 1, 1) * 1e5;
        BodyVelocity.Parent = GetRoot(LocalPlayer.Character);

        LocalPlayer.CharacterAdded:wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("shorten/baby","Become tiny!", function()
game.StarterGui:SetCore("SendNotification", {
Title = "Proportions (short):"; 
Text = "Height %90 Width %75 Head %100 Proportions %100 Body Type %0"; 
Duration = 15;
})

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local function rm()
   for i,v in pairs(Character:GetDescendants()) do
       if v:IsA("BasePart") then
           if v.Name ~= "Head" then
               for i,cav in pairs(v:GetDescendants()) do
                   if cav:IsA("Attachment") then
                       if cav:FindFirstChild("OriginalPosition") then
                           cav.OriginalPosition:Destroy()
                       end
                   end
               end
               v:FindFirstChild("OriginalSize"):Destroy()
               if v:FindFirstChild("AvatarPartScaleType") then
                   v:FindFirstChild("AvatarPartScaleType"):Destroy()
               end
           end
       end
   end
end
rm()
wait(0.1)
Humanoid:FindFirstChild("BodyTypeScale"):Destroy()
wait(0.3)
rm()
wait(0.1)
Humanoid:FindFirstChild("BodyWidthScale"):Destroy()
wait(0.3)
rm()
wait(0.1)
Humanoid:FindFirstChild("BodyDepthScale"):Destroy()
wait(0.3)
rm()
wait()
wait(0.1)
Humanoid:FindFirstChild("HeadScale"):Destroy()
wait(0.3)
end)

AddCommand("teleport/tp", "teleports a player to another", function(caller, player, player2)
    local Target = GetPlayer(caller, player)
    local TeleportedTo = GetPlayer(caller, player2)
    local Position = LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame

    if Target ~= nil and TeleportedTo ~= nil then
        if #TeleportedTo > 1 then
            return
        end

        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "teleport "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("Teleport", Check, 5)

                return
            end
        end

        local BEvents = {};

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        for _, Player in pairs(Target) do
            local Check = KillableCheck(Player.Character, "teleport "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    AttachTool(Tool, TeleportedTo[1].Character.HumanoidRootPart.CFrame);

                    BEvents[Tool] = Tool.AncestryChanged:Connect(function(LocalTool)
                        BEvents[Tool]:Disconnect();

                        LocalTool.Handle:BreakJoints();
                    end)

                    firetouchinterest(Tool.Handle, Check, 0);

                    NotificationUI.Notify("Teleport", "Successfully teleported "..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Teleport", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Teleport", Check, 5)
            end
        end

        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player, player2")

AddCommand("equiptools/etools", "equips all the tools", function()
    for _, Tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        Tool.Parent = LocalPlayer.Character;
    end
end)

AddCommand("ntools", "gives the tools in your backpack to another person", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        for _, Player in pairs(Target) do
            local TouchInterest = Player.Character.Head;

            for _, Tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                if Tool:FindFirstChild("Handle") then
                    Tool.Parent = LocalPlayer.Character;

                    Tool.Handle:BreakJoints();

                    Tool.Parent = workspace;

                    firetouchinterest(Tool.Handle, TouchInterest, 0)
                end
            end
        end

        LocalPlayer.CharacterAdded:wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("handto/givetool", "gives the tool you are holding to another person", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        ReplaceHumanoid();

        for _, Player in pairs(Target) do
            local TouchInterest = Player.Character.Head;

            for _, Tool in pairs(LocalPlayer.Character:GetChildren()) do
                if Tool:IsA("Tool") and Tool:FindFirstChild("Handle") then
                    Tool.Handle:BreakJoints();

                    firetouchinterest(Tool.Handle, TouchInterest, 0);
                end
            end
        end

        LocalPlayer.CharacterAdded:wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")

AddCommand("mute", "mutes a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil and game:GetService("SoundService").RespectFilteringEnabled == false then
        for _, Player in pairs(Target) do
            for _, Object in pairs(Player.Character:GetDescendants()) do
                if Object:IsA("Sound") then
                    Object.Volume = 0;
                end
            end
        end
    end
end, "player")

AddCommand("whitelist/wl", "whitelists a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        for _, Player in pairs(Target) do
            table.insert(Admin.CEvents.Whitelisted, Player.UserId);

            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w " .. Player.Name ..
                                                                                           " You have been whitelisted to moon admin, use the prefix " ..
                                                                                           Admin.Prefix ..
                                                                                           " to get started.", "All");
        end
    end
end, "player")

table.sort(Admin.Commands, function(FirstElement, NextElement)
    return FirstElement[1]:lower() < NextElement[1]:lower()
end)

for _, Command in ipairs(Admin.Commands) do
    local clonedContainer = Container:Clone()

    if Command[4] then
        clonedContainer.CommandName.Text = Command[1] .. " { " .. Command[4] .. " }"
    else
        clonedContainer.CommandName.Text = Command[1]
    end

    clonedContainer.CommandName.Description.Text = Command[2]

    clonedContainer.Parent = CommandList.ScrollBar
end

AddCommand("ghost","you can walk as a ghost",function()
local baseplate = Instance.new("Part")
baseplate.Parent = workspace
baseplate.Size = Vector3.new(2048,5,2048)
baseplate.Anchored = true
baseplate.Name = "Baseplate"
baseplate.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,-11,0)
    for i,v in pairs(game.workspace:GetDescendants()) do
     if v:IsA('BasePart') then
       if v.Material == Enum.Material.Grass then
         v.CanCollide = false
       end
     end
    end
end)

AddCommand("unghost/unpumpkin/deletebaseplate","delete random baseplate",function()
     for i,v in pairs(game.workspace:GetDescendants()) do
     if v:IsA('BasePart') then
       if v.Material == Enum.Material.Grass then
         v.CanCollide = true
       end
     end
     end
     if game:GetService("Workspace"):FindFirstChild("Baseplate") then
    game:GetService("Workspace").Baseplate:Destroy()
    end
end)

AddCommand("pumpkin","you can walk as a pumpkin",function()
local baseplate = Instance.new("Part")
baseplate.Parent = workspace
baseplate.Size = Vector3.new(2048,5,2048)
baseplate.Anchored = true
baseplate.Name = "Baseplate"
baseplate.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,-9.55,0)


local Humanoid = game.Players.LocalPlayer.Character.Humanoid
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _,v in pairs(ActiveTracks) do
	    v:Stop()
local animate = game:GetService("Workspace").LaDuxii.Animate
animate.Disabled = true
end


    for i,v in pairs(game.workspace:GetDescendants()) do
     if v:IsA('BasePart') then
       if v.Material == Enum.Material.Grass then
         v.CanCollide = false
       end
     end
    end
end)


AddCommand("spook", "spook a player", function(caller, player)
local oldCF = LocalPlayer.Character.HumanoidRootPart.CFrame
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        
        for _, Player in pairs(Target) do
                distancepl = 3
                if Player.Character and Player.Character:FindFirstChild('Humanoid') then
                        LocalPlayer.Character.HumanoidRootPart.CFrame =
                        Player.Character.HumanoidRootPart.CFrame +  Player.Character.HumanoidRootPart.CFrame.lookVector * distancepl
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, Player.Character.HumanoidRootPart.Position)
                        wait(1)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = oldCF
                end
        end
        end
end, "player")


AddCommand("hide","go to dollhouse house",function()
game:GetService("Workspace").LaDuxii.HumanoidRootPart.CFrame = CFrame.new(5617.07031, 67.2376938, -17260.6699, -0.999935448, 3.11831378e-08, -0.0113629522, 3.1071675e-08, 1, 9.98585392e-09, 0.0113629522, 9.63214308e-09, -0.999935448)
for _,v in ipairs(workspace:GetDescendants()) do
if v:IsA("BasePart") and v.Material==Enum.Material.Cobblestone then
v:Destroy()
end
end
end)


AddCommand("halloween","halloween theme for dollhouse",function()
        if game.PlaceId == 417267366 then
    local Settings = {
    DarkTheme = true, -- requires new bubblechat
    NewBubbleChatEnabled = true,
    BubbleChatSettings = {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    },
    ChatSettings = {
        BubbleChatEnabled = false,
        ChatWindowBackgroundFadeOutTime = .1,
        --MessageHistoryLengthPerChannel = 5000,
        PlayerDisplayNamesEnabled = false
    }
}

local ChatService = game:GetService("Chat")
local ChatModule = ChatService:WaitForChild("ClientChatModules", 1/0):WaitForChild("ChatSettings", 1/0)

if Settings.NewBubbleChatEnabled and not ChatService.BubbleChatEnabled then
    ChatService.BubbleChatEnabled = true
end

for _, x in next, Settings.ChatSettings do
    require(ChatModule)[_] = x
end

if Settings.DarkTheme and Settings.NewBubbleChatEnabled then
    for i = 1, 10 do
        pcall(ChatService.SetBubbleChatSettings, ChatService, Settings.BubbleChatSettings)
        task.wait()
    end
end

game.Lighting.TimeOfDay = "17:00:00:"

game.Lighting.FogEnd = 1000


for _,v in pairs(workspace:GetDescendants()) do
   if v.ClassName == "PointLight" then
       v:Destroy()
   end
end

for _,v in ipairs(workspace:GetDescendants()) do
if v:IsA("BasePart") and v.Material==Enum.Material.Neon then
v.Material = 'Plastic'
end
end

 local SkyBox = game:GetObjects('rbxassetid://3609199304')
 print(SkyBox[1]:GetChildren())
 SkyBox[1].Parent = game.Lighting
 
    for i,v in pairs(game.workspace:GetDescendants()) do
     if v:IsA('BasePart') then
       if v.Material == Enum.Material.Grass then
         v.Material = Enum.Material.Sand
         v.Color = Color3.fromRGB(100,0,0)
       end
     end
    end
    end
end)

AddCommand("unhalloween","removes halloween theme for dollhouse",function()
    for _,v in ipairs(workspace:GetDescendants()) do
if v:IsA("BasePart") and v.Material==Enum.Material.Plastic then
v.Material = 'Neon'
end
end
    game.Lighting.TimeOfDay = "14:00:00:"
    game.Lighting.FogEnd = 500000
    game:GetService("Lighting")["Sky_Halloween"]:Destroy()
    for i,v in pairs(game.workspace:GetDescendants()) do
     if v:IsA('BasePart') then
       if v.Material == Enum.Material.Sand then
         v.Material = Enum.Material.Grass
         v.Color = Color3.fromRGB(52, 142, 64)
       end
     end
    end
end)


AddCommand("seat","sits you",function()
    game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(workspace:FindFirstChildWhichIsA("Seat", true).CFrame);
end)

AddCommand("fly",function()
        wait(.1)
        yesfly()
end)

AddCommand("unfly",function()
        wait(.1)
        nofly()
end)

AddCommand("rejoinre/rjre","rejoins and respawns at the same location",function()
        if not syn.queue_on_teleport then
        end
        rejoining = true
        local c = game.Players.LocalPlayer.Character.Head.CFrame
        syn.queue_on_teleport(string.format([[
    game:GetService('ReplicatedFirst'):RemoveDefaultLoadingScreen()
    local playeradded, charadded
    playeradded = game:GetService('Players').PlayerAdded:Connect(function(plr)
        charadded = plr.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(%f, %f, %f)
            admin()
            game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
            charadded:Disconnect()
        end)
        playeradded:Disconnect()
    end)
]], c.X, c.Y, c.Z))
        game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, game:GetService("Players"))
end)

AddCommand("massfling/mfling", "mass flings a player", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if LocalPlayer.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
            warn("not r15")

            return
        end

        ResizeLeg();

        ReplaceHumanoid();

        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

        for _, Player in pairs(Target) do
            local TouchInterest = "Head";

            TouchInterest = Player.Character[TouchInterest];

            local Tool = GetTool();

            if Tool then
                Tool.Parent = LocalPlayer.Character;

                firetouchinterest(Tool.Handle, TouchInterest, 0);
            end
        end

        local BodyVelocity = Instance.new("BodyAngularVelocity");

        BodyVelocity.MaxTorque = Vector3.new(1, 1, 1) * math.huge
        BodyVelocity.P = math.huge
        BodyVelocity.AngularVelocity = Vector3.new(1, 1, 1) * 1e5;
        BodyVelocity.Parent = GetRoot(LocalPlayer.Character);

        LocalPlayer.CharacterAdded:wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
    end
end, "player")


AddCommand("serverhop/shop", "Teleports you to a new game",function()
        local LP = game:GetService('Players').LocalPlayer

        local ogChar = LP.Character
        LP.Character = Clone
        LP.Character = ogChar
        function shop()
                pcall(function()
                        local Servers =
                                game.HttpService:JSONDecode(
                                game:HttpGet("https://games.roblox.com/v1/games/417267366/servers/Public?sortOrder=Asc&limit=100")
                        )
                        while wait() do
                                v = Servers.data[math.random(#Servers.data)]
                                if v.playing < v.maxPlayers - 2 and v.id ~= game.JobId then
                                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id)
                                        break
                                end
                        end
                end)
        end
        
        
        local function hop()
                shop()
                while wait() do
                        pcall(shop)
                end
        end
        hop()
end)


AddCommand("Halloweentheme/htheme","dollhouse only", function()
    local Settings = {
    DarkTheme = true, -- requires new bubblechat
    NewBubbleChatEnabled = true,
    BubbleChatSettings = {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    },
    ChatSettings = {
        BubbleChatEnabled = false,
        ChatWindowBackgroundFadeOutTime = .1,
        --MessageHistoryLengthPerChannel = 5000,
        PlayerDisplayNamesEnabled = false
    }
}

local ChatService = game:GetService("Chat")
local ChatModule = ChatService:WaitForChild("ClientChatModules", 1/0):WaitForChild("ChatSettings", 1/0)

if Settings.NewBubbleChatEnabled and not ChatService.BubbleChatEnabled then
    ChatService.BubbleChatEnabled = true
end

for _, x in next, Settings.ChatSettings do
    require(ChatModule)[_] = x
end

if Settings.DarkTheme and Settings.NewBubbleChatEnabled then
    for i = 1, 10 do
        pcall(ChatService.SetBubbleChatSettings, ChatService, Settings.BubbleChatSettings)
        task.wait()
    end
end

game.Lighting.TimeOfDay = "17:00:00:"

for _,v in pairs(workspace:GetDescendants()) do
   if v.ClassName == "PointLight" then
       v:Destroy()
   end
end

for _,v in ipairs(workspace:GetDescendants()) do
if v:IsA("BasePart") and v.Material==Enum.Material.Neon then
v.Material = 'Plastic'
end
end

 local SkyBox = game:GetObjects('rbxassetid://3609199304')
 print(SkyBox[1]:GetChildren())
 SkyBox[1].Parent = game.Lighting
 
    for i,v in pairs(game.workspace:GetDescendants()) do
     if v:IsA('BasePart') then
       if v.Material == Enum.Material.Grass then
         v.Material = Enum.Material.Sand
         v.Color = Color3.fromRGB(100,0,0)
       end
     end
   end
end)


AddCommand("ignore","ignores a players messages n disappears",function(caller,player)
    local Target = GetPlayer(caller, player);
        local MuteRequest = game.ReplicatedStorage.DefaultChatSystemChatEvents.MutePlayerRequest
        for _, Player in pairs(Target) do
        MuteRequest:InvokeServer(Target.Name);
        if (Player.Character) then
                        Player.Character.HumanoidRootPart.CFrame = CFrame.new(0,500,0)
            Player.Character.Parent = game.ReplicatedStorage
        end
        end
end,"player")


AddCommand("unignore","brings player back",function(caller,player)
    local Target = GetPlayer(caller, player);
        local UnMuteRequest = game.ReplicatedStorage.DefaultChatSystemChatEvents.UnMutePlayerRequest
        for _, Player in pairs(Target) do
                UnMuteRequest:InvokeServer(Target.Name);
                if (Player.Character and Player.Character.Parent == game.ReplicatedStorage) then
            Player.Character.Parent = workspace
                end
        end
end,"player")


AddCommand("antibang","antibans u",function()
workspace.FallenPartsDestroyHeight = 0/0
local plr = game.Players.LocalPlayer
local old = plr.Character.HumanoidRootPart.CFrame

plr.Character.HumanoidRootPart.CFrame = CFrame.new(1,-490,1)
wait(1)
plr.Character.HumanoidRootPart.CFrame = old 
end)

AddCommand("givevalkto/gvalkto", "gives a valk to a target", function(caller, player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        if #Target == 1 then
            local Check = KillableCheck(Target[1].Character, "attach "..Target[1].DisplayName);

            if type(Check) == "string" then
                NotificationUI.Notify("Attach", Check, 5)

                return
            end
        end

        ReplaceHumanoid();
        
        local Position = LocalPlayer.Character.HumanoidRootPart.CFrame;

    
        for _, Player in pairs(Target) do
        
            local Check = KillableCheck(Player.Character, "attach "..Player.DisplayName);

            if type(Check) ~= "string" then
                local Tool = GetTool();

        wait(3.6)

                if Tool then
                    Tool.Parent = LocalPlayer.Character;

                    firetouchinterest(Tool.Handle, Check, 0);

                     game:GetService('Players').LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(5629.47461, 54.3333855, -17259.9000, -0.0496723466, -0.101534382, 0.993591249, 0.0356569625, 0.994004726, 0.103359237, -0.998128951, 0.040562544, -0.0457541458))
 wait(0.3)
        local Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart,
            TweenInfo.new(1, Enum.EasingStyle.Linear), {
                CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -15, 0)
            });

        Tween:Play();
            wait(1)
                    LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;

                    NotificationUI.Notify("Valk", "Successfully gave valk to"..Player.DisplayName.."!", 5)
                else
                    NotificationUI.Notify("Attach", "You don't have enough tools!", 5)
                end
            else
                NotificationUI.Notify("Attach", Check, 5)
            end
            


        LocalPlayer.CharacterAdded:wait();
        game.Players.LocalPlayer.Character:WaitForChild("ForceField"):Destroy()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position;
        if Player.Character:FindFirstChild("Valkyrie Helm") then
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Imagine having a fake valk, "..Player.Name, "All")
        end
        end
    end
end, "player")


AddCommand("click","te",function()
mousemoveabs(2060,1320)
wait(0.1)
mousemoveabs(2061,1321)
wait(0.1)
mouse1click()
end)

AddCommand("makefun/joke","make fun of a kid",function(caller,player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        for _, Player in pairs(Target) do
            LocalPlayer.Character:SetPrimaryPartCFrame(GetRoot(Player.Character).CFrame);
            wait(0.2)
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Haha! you're such a clown, "..Player.Name, "All")
            wait(1)
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("You just got roasted by a BOT, "..Player.Name, "All")
            wait(1)
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("What a loser, "..Player.Name, "All")
        end
    end
end, "player")


AddCommand("copyname/cname","copy someones real username",function(caller,player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        for _, Player in pairs(Target) do
        setclipboard(Player.Name)
        end
    end
end, "player")

AddCommand("copyid/cID","copy someones real username",function(caller,player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        for _, Player in pairs(Target) do
        setclipboard(Player.UserId)
        end
    end
end, "player")

AddCommand("trade","sends trade link to target",function(caller,player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        for _, Player in pairs(Target) do
        setclipboard("https://www.roblox.com/users/" ..Player.UserId .. "/trade")
        end
    end
end, "player")


AddCommand("quiet/annoy","make fun of a kid",function(caller,player)
    local Target = GetPlayer(caller, player);

        local Position, Velocity = LocalPlayer.Character.HumanoidRootPart.CFrame,
            LocalPlayer.Character.HumanoidRootPart.Velocity;

    if Target ~= nil then
        for _, Player in pairs(Target) do
            LocalPlayer.Character:SetPrimaryPartCFrame(GetRoot(Player.Character).CFrame);
            wait(0.2)
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Player.Name.. ", thats cool n all but you built like my grandma with you're no neck body built bath and body works double or nothing for a barbie girl doll that built like ken stupid kid", "All")
            wait(1)
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Player.Name.. ", YOURE BUILT LIKE AN ENDERMAN WITH HEIGHT SWAPPED TO WIDTH YOUR GOT LIKE 2 JIGGLYPUFFS RUBBING AGAINST EACH OTHER FOR BRVEEDING TO MAKE A BUZZWOLE EGG", "All")
            
            wait(2)
            
           local PPosition = GetRoot(Player.Character).Position;

            local Running = RunService.Stepped:Connect(function(step)
                step = step - workspace.DistributedGameTime;

                GetRoot(LocalPlayer.Character).CFrame = (GetRoot(Player.Character).CFrame -
                                                            (Vector3.new(0, 1e6, 0) * step)) +
                                                            (GetRoot(Player.Character).Velocity * (step * 30));
                GetRoot(LocalPlayer.Character).Velocity = Vector3.new(0, 1e6, 0)
            end)

            local STime = tick();

            repeat
                wait();

            until (PPosition - GetRoot(Player.Character).Position).Magnitude >= 60 or tick() - STime >= 1;

            Running:Disconnect();

            GetRoot(LocalPlayer.Character).Velocity = Velocity;
            GetRoot(LocalPlayer.Character).CFrame = Position;

            wait();
        end

        local Running = RunService.Stepped:Connect(function()
            GetRoot(LocalPlayer.Character).Velocity = Velocity;
            GetRoot(LocalPlayer.Character).CFrame = Position;
        end)

        wait(2);

        GetRoot(LocalPlayer.Character).Anchored = true

        Running:Disconnect();

        GetRoot(LocalPlayer.Character).Anchored = false

        GetRoot(LocalPlayer.Character).Velocity = Velocity;
        GetRoot(LocalPlayer.Character).CFrame = Position;
    end
end, "player")

AddCommand("trashid/tid","make fun of a kid for having a bad audio",function(caller,player)
    local Target = GetPlayer(caller, player);

    if Target ~= nil then
        for _, Player in pairs(Target) do
            LocalPlayer.Character:SetPrimaryPartCFrame(GetRoot(Player.Character).CFrame);
            wait(0.2)
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Player.Name.. ", ur audio looks like if it were out of ur parents movie wiggly wiggly and making it more edgy u put some random sound effect so it looks more uglier than you in rl🤓🤓", "All")
        end
    end
end, "player")
