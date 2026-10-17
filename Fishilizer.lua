



local Fish = {}
---begin
Fish.VERSION = "10.1.1"
Fish.NAME = "Fishilizer"


--- a list of options for our loadstring we can later use 
Fish.Options = {
    Decompile = false,
    DecompileTimeout = 10,
    MaxThreads = 3,
    DecompileIgnore = {"Chat", "CoreGui", "CorePackages"},
    SaveBytecode = false,
    SaveScriptCache = false,
    SaveScriptCachePath = "FishilizerCache",
    NilInstances = false,
    RemovePlayerCharacters = true,
    SavePlayers = false,
    IsolateStarterPlayer = true,
    IsolateLocalPlayer = false,
    SavePlayerCharacters = false,
    IncludeBackpack = true,
    IgnoreDefaultProps = true,
    IgnoreNotArchivable = true,
    Binary = false,
    ShowStatus = true,
    ReadMe = true,
    Mode = "full",
    FilePath = false,
    Callback = false,
    Clipboard = false,
    AvoidFileOverwrite = true,
    SafeMode = false,
    BoostFPS = false,
    KillAllScripts = false,
    AntiIdle = false,
    Anonymous = false,
    OUT = "Fishilizer",
    Depth = 1000,
    Terrain = true,
    CSG = true,
    Notify = true,
    StripCharacters = true,
    StripCoreScripts = true,
    EmitTags = true,
    EmitAttributes = true,
    UseGetProperties = true,
    FetchDocs = false,
    APIDumpURL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json",
}

local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local function resolveIO(name)
    local g = (getgenv and getgenv()) or _G
    if g and type(g[name]) == "function" then return g[name] end
    if type(rawget(_G, name)) == "function" then return rawget(_G, name) end
    if g then
        for _, v in pairs(g) do
            if type(v) == "table" and type(v[name]) == "function" then
                return v[name]
            end
        end
    end
    return nil
end

local IO = {
    writefile = resolveIO("writefile"),
    readfile = resolveIO("readfile"),
    makefolder = resolveIO("makefolder"),
    isfolder = resolveIO("isfolder"),
    isfile = resolveIO("isfile"),
    delfile = resolveIO("delfile"),
    setclipboard = resolveIO("setclipboard"),
    getproperties = resolveIO("getproperties"),
}

local function log(msg)
    pcall(function() print("[Fishilizer] " .. tostring(msg)) end)
    pcall(function() warn("[Fishilizer] " .. tostring(msg)) end)
end

local _progressUI = nil
local _progressEmitted = 0
local _progressTotal = 0
local BAR_TRACK_WIDTH = 304

local function destroyProgressUI()
    if _progressUI and _progressUI.gui then
        pcall(function() _progressUI.gui:Destroy() end)
    end
    _progressUI = nil
    _progressEmitted = 0
    _progressTotal = 0
end

local function buildProgressUI()
    if not Fish.Options.ShowStatus then return nil end
    local lp = Players.LocalPlayer
    if not lp then return nil end
    local pg = lp:FindFirstChildOfClass("PlayerGui")
    if not pg then return nil end

    pcall(function()
        local existing = pg:FindFirstChild("__FishilizerProgress__")
        if existing then existing:Destroy() end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "__FishilizerProgress__"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 100
    gui.Parent = pg

    local contents = Instance.new("Frame")
    contents.Name = "Contents"
    contents.BorderSizePixel = 0
    contents.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    contents.Size = UDim2.new(0, 338, 0, 28)
    contents.AnchorPoint = Vector2.new(1, 0)
    contents.Position = UDim2.new(1, -20, 0, 20)
    contents.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = contents

    local progress = Instance.new("Frame")
    progress.Name = "Progress"
    progress.BorderSizePixel = 0
    progress.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    progress.Size = UDim2.new(0, 304, 0, 13)
    progress.Position = UDim2.new(0.04712, 0, 0.23695, 0)
    progress.Visible = false
    progress.Parent = contents

    local pcorner = Instance.new("UICorner")
    pcorner.CornerRadius = UDim.new(0, 5)
    pcorner.Parent = progress

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.BorderSizePixel = 0
    bar.BackgroundColor3 = Color3.fromRGB(86, 86, 255)
    bar.Size = UDim2.new(0, 1, 0, 13)
    bar.Position = UDim2.new(-0.00222, 0, 0.00619, 0)
    bar.Parent = progress

    local bcorner = Instance.new("UICorner")
    bcorner.CornerRadius = UDim.new(0, 5)
    bcorner.Parent = bar

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "text"
    textLabel.BorderSizePixel = 0
    textLabel.TextSize = 14
    textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    textLabel.TextColor3 = Color3.fromRGB(183, 183, 183)
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(0, 338, 0, 28)
    textLabel.Visible = true
    textLabel.Text = "Saving game.. (this may take time depending on size)"
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.Parent = contents

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 86, 128)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = contents

    return {
        gui = gui,
        contents = contents,
        progress = progress,
        bar = bar,
        text = textLabel,
    }
end

local function showTextStage()
    if not _progressUI then return end
    _progressUI.text.Visible = true
    _progressUI.progress.Visible = false
end

local function showProgressStage()
    if not _progressUI then return end
    _progressUI.text.Visible = false
    _progressUI.progress.Visible = true
    if _progressUI.bar then
        _progressUI.bar.Size = UDim2.new(0, 1, 0, 13)
    end
end

local function updateBar(ratio)
    if not _progressUI or not _progressUI.bar then return end
    if ratio < 0 then ratio = 0 end
    if ratio > 1 then ratio = 1 end
    local w = math.floor(BAR_TRACK_WIDTH * ratio)
    if w < 1 then w = 1 end
    _progressUI.bar.Size = UDim2.new(0, w, 0, 13)
end

local function bumpProgress()
    if not _progressUI then return end
    _progressEmitted = _progressEmitted + 1
    if _progressTotal > 0 then
        if _progressEmitted % 25 == 0 then
            updateBar(_progressEmitted / _progressTotal)
        end
    end
end

local SKIP_SVC = {
    CoreGui=true,CorePackages=true,CoreScripts=true,Chat=true,LogService=true,
    ContentProvider=true,ScriptContext=true,Selection=true,TestService=true,
    PluginGuiService=true,PluginDebugService=true,SolidModelContentProvider=true,
    Visit=true,Stats=true,Players=true,StarterPlayer=true,SoundService=true,
    LocalizationService=true,MarketplaceService=true,AppStorageService=true,
    AvatarEditorService=true,BadgeService=true,GamePassService=true,GroupService=true,
    GuiService=true,HopperService=true,KeyframeSequenceProvider=true,
    MemoryStoreService=true,MessagingService=true,PathfindingService=true,
    PolicyService=true,ProximityPromptService=true,RobloxReplicatedStorage=true,
    SessionService=true,SharedTableRegistry=true,TeleportService=true,
    TextChatService=true,TrackerService=true,UserInputService=true,UserService=true,
    VRService=true,VoiceChatService=true,AnalyticsService=true,
    ContextActionService=true,ControllerService=true,DragDetectorService=true,
    ExperienceNotificationService=true,FriendService=true,GamepadService=true,
    GeometryService=true,GuidRegistryService=true,HapticService=true,
    InsertService=true,JointsService=true,LuaWebService=true,MouseService=true,
    NotificationService=true,PermissionsService=true,PhysicsService=true,
    ReplicatedFirst=true,SocialService=true,TextService=true,TouchInputService=true,
    VirtualInputManager=true,VirtualUser=true,ChatService=true,DataStoreService=true,
    RunService=true,TweenService=true,HttpService=true,HTTPService=true,Debris=true,
    AvatarCreationService=true,AccountService=true,AdService=true,AssetService=true,
    AvatarImportService=true,BrowserService=true,BulkImportService=true,
    CallbackService=true,ChangeHistoryService=true,CloudLocalizationTable=true,
    ClusterPacketCache=true,CollaborationService=true,CommerceService=true,
    ConfigureServerService=true,DeviceIdService=true,DraftsService=true,
    FriendPagesService=true,GenericChallengeService=true,HomeService=true,
    IXPService=true,InstanceFileService=true,LiveScriptingService=true,LodService=true,
    LoginService=true,LuaChatService=true,MeshContentProvider=true,
    MessageBusService=true,NetworkClient=true,NetworkServer=true,OpenCloudService=true,
    PackageService=true,PatchBundlerService=true,PerformanceControlService=true,
    PlayerEmulatorService=true,PluginPolicyService=true,ProcessInstancePhysicsService=true,
    PublishService=true,ReflectionMetadataService=true,RemoteDebuggerServer=true,
    RenderSettings=true,RobloxServerStorage=true,SafetyService=true,ScriptService=true,
    StudioAssetService=true,StudioData=true,StudioService=true,StyleService=true,
    TelemetryService=true,TracerService=true,UGCValidationService=true,
    UpdateService=true,UserStorageService=true,VideoCaptureService=true,
    VoiceChatInternal=true,WebViewService=true,
}

local SKIP_PROP = {
    Parent=true,RobloxLocked=true,HistoryId=true,DataCost=true,Game=true,Identity=true,
    Verb=true,LocalLocation=true,PivotOffset=true,AbsoluteSize=true,AbsolutePosition=true,
    AbsoluteContentSize=true,AbsoluteRotation=true,AbsoluteCanQuery=true,
    AbsoluteOrientation=true,CrossPlatformAssetId=true,Autopilot=true,CameraSubject=true,
    CurrentCamera=true,SelectionBox=true,SelectionSphere=true,DraggingV1=true,
    Dragging=true,Archetype=true,NetworkOwner=true,RemoteEventsFolder=true,CameraType=true,
    CameraMode=true,FieldOfViewMode=true,MaxAxisFieldOfView=true,RotVelocity=true,
    OverlapParam=true,RootPriority=true,DebugId=true,JobId=true,IsGuest=true,
    UsesAsset=true,UnfilteredPackages=true,SnippetKey=true,ReplicationEnabled=true,
    NoCollisionConstraint=true,AccumulatedMouseDelta=true,AccumulatedTouchDelta=true,
    MouseDeltaSensitivity=true,TouchDeltaSensitivity=true,LastInputType=true,
    LastInputTypeChanged=true,Running=true,ElapsedTime=true,NetworkOwnershipAuto=true,
    ReceiveAge=true,TotalRcvAge=true,TotalRcvTime=true,RcvAge=true,RcvTime=true,
    CameraSubjectDistance=true,InputTypesChanged=true,Annotation=true,Annotations=true,
    AnnotationService=true,PlaybackState=true,SecurityCapabilities=true,ClassName=true,
}

local CONTENT_PROP_EXACT = {
    MeshContent=true,ImageContent=true,SoundContent=true,AnimationContent=true,
    TextureContent=true,ShirtTemplateContent=true,PantsTemplateContent=true,
    GraphicContent=true,FaceContent=true,VideoContent=true,ColorMapContent=true,
    NormalMapContent=true,RoughnessMapContent=true,MetalnessMapContent=true,
    EmissiveMaskContent=true,SkyboxBkContent=true,SkyboxDnContent=true,
    SkyboxFtContent=true,SkyboxLfContent=true,SkyboxRtContent=true,SkyboxUpContent=true,
    SunTextureContent=true,MoonTextureContent=true,DecalContent=true,
    ParticleTextureContent=true,ExplosionTextureContent=true,TrailTextureContent=true,
    BeamTextureContent=true,SpecialMeshContent=true,CylinderMeshContent=true,
    BlockMeshContent=true,WedgeMeshContent=true,LevelOfDetailContent=true,
    ColorMapLookup=true,RoughnessMapLookup=true,NormalMapLookup=true,
    MetalnessMapLookup=true,WrapLayerContent=true,WrapTargetContent=true,
    CageMeshContent=true,ReferenceMeshContent=true,AlphaModeContent=true,
    TexturePackContent=true,WireframeContent=true,
}

local REAL_CONTENT_PROPS = {
    Texture=true,TextureId=true,TextureID=true,Image=true,MeshId=true,SoundId=true,
    AnimationId=true,ShirtTemplate=true,PantsTemplate=true,Graphic=true,SkyboxBk=true,
    SkyboxDn=true,SkyboxFt=true,SkyboxLf=true,SkyboxRt=true,SkyboxUp=true,
    SunTextureId=true,MoonTextureId=true,ImageId=true,Video=true,Sound=true,Decal=true,
    ColorMap=true,NormalMap=true,RoughnessMap=true,MetalnessMap=true,EmissiveMask=true,
    CageMeshId=true,ReferenceMeshId=true,TexturePack=true,
}

local CORE_SCRIPT_NAMES = {
    PlayerModule=true,CameraModule=true,ControlModule=true,Common=true,Utils=true,
    RbxCharacterSounds=true,Animate=true,Health=true,RbxCamera=true,
    RbxCharacterSoundsScript=true,RbxDefaultCharacter=true,TouchJump=true,
    TouchControlFrame=true,ClickToMoveController=true,DynamicThumbstick=true,
    LegacyThumbstick=true,Keyboard=true,Gamepad=true,Touch=true,VRNavigation=true,
    CameraInput=true,CameraToggle=true,CameraUI=true,ZoomController=true,
    MouseLockController=true,BaseCamera=true,ClassicCamera=true,
    TransparencyController=true,Poppercam=true,Invisicam=true,OrbitalCamera=true,
    ScriptableCamera=true,FollowCamera=true,VehicleCamera=true,LegacyCamera=true,
    BaseCharacterController=true,UserInput=true,HumanoidController=true,
    DefaultChatSystemChatEvents=true,ChatMain=true,BubbleChat=true,ChatWindow=true,
    ChatBar=true,ChatTypes=true,ChatSettings=true,ChatCommands=true,ChatModules=true,
}

local CHARACTER_CLASSES = {
    Humanoid=true,Head=true,Torso=true,HumanoidRootPart=true,LeftArm=true,RightArm=true,
    LeftLeg=true,RightLeg=true,UpperTorso=true,LowerTorso=true,LeftUpperArm=true,
    LeftLowerArm=true,RightUpperArm=true,RightLowerArm=true,LeftUpperLeg=true,
    LeftLowerLeg=true,RightUpperLeg=true,RightLowerLeg=true,LeftFoot=true,RightFoot=true,
    LeftHand=true,RightHand=true,BodyColors=true,CharacterMesh=true,Accessory=true,
    Accoutrement=true,Hat=true,Shirt=true,Pants=true,ShirtGraphic=true,Face=true,
    FaceControls=true,FaceInstance=true,HumanoidDescription=true,
}

local CRITICAL_PROPS = {
    "Name","Archivable","SourceAssetId","PackageId","AttributesSerialize","Tags",
    "TextureId","TextureID","Texture","Image","MeshId","SoundId","AnimationId",
    "ShirtTemplate","PantsTemplate","Graphic","Decal",
    "Shape","Size","Position","CFrame","Orientation","Rotation","Anchored","CanCollide",
    "CanTouch","CanQuery","CanClimb","CanAutoCollide","Transparency","Reflectance",
    "CastShadow","Material","MaterialVariant","BrickColor","Color","Massless","Locked",
    "CollisionGroup","CollisionGroupId","TopSurface","BottomSurface","LeftSurface",
    "RightSurface","FrontSurface","BackSurface","MeshType","Scale","Offset",
    "VertexColor","LevelOfDetail","RenderFidelity","DoubleSided",
    "CustomPhysicalProperties","FormFactor","RigType","WalkSpeed","JumpPower","JumpHeight",
    "MaxHealth","Health","HipHeight","AutoRotate","AutoJumpEnabled","AutoScalingEnabled",
    "DisplayDistanceType","HealthDisplayDistance","NameDisplayDistance","DisplayName",
    "HeadScale","BodyTypeScale","BodyDepthScale","BodyWidthScale",
    "BodyHeightScale","BodyProportionScale","UniformScale","OriginalSize","Value","Text",
    "Font","FontFace","TextColor3","TextSize","TextScaled","TextWrapped","TextStrokeColor3",
    "TextStrokeTransparency","TextTransparency","RichText","LineHeight","MaxVisibleGraphemes",
    "TextXAlignment","TextYAlignment","TextTruncate","TextFits","PlaceholderText",
    "PlaceholderColor3","ClearTextOnFocus","MultiLine","TextEditable","BackgroundColor3",
    "BackgroundTransparency","BorderSizePixel","BorderColor3","BorderMode","AutomaticSize",
    "ClipsDescendants","ImageColor3","ImageTransparency","ImageRectOffset","ImageRectSize",
    "ResampleMode","ScaleType","SliceCenter","SliceScale","TileSize","Visible","Active",
    "Selectable","AutoButtonColor","Modal","Style","ZIndex","LayoutOrder","SizeConstraint",
    "AnchorPoint","Interactable","CanvasSize","CanvasPosition","ScrollBarThickness",
    "ScrollBarImageColor3","ScrollBarImageTransparency","ElasticBehavior","ScrollingDirection",
    "ScrollingEnabled","VerticalScrollBarInset","HorizontalScrollBarInset","AutomaticCanvasSize",
    "MidImage","TopImage","BottomImage","CellPadding","CellSize","FillDirection",
    "FillDirectionMaxCells","HorizontalAlignment","VerticalAlignment","SortOrder","StartCorner",
    "PaddingTop","PaddingBottom","PaddingLeft","PaddingRight","Padding","Spacing","AspectRatio",
    "AspectType","DominantAxis","MaxSize","MinSize","MaxTextSize","MinTextSize","Enabled",
    "ResetOnSpawn","DisplayOrder","IgnoreGuiInset","ClipToDeviceSafeArea","SafeAreaCompatibility",
    "ScreenInsets","SizingMode","PixelsPerStud","AlwaysOnTop","Adornee","Brightness","ZOffset",
    "MaxDistance","DistanceLowerLimit","DistanceUpperLimit","ExtentsOffset",
    "ExtentsOffsetWorldSpace","StudsOffset","StudsOffsetWorldSpace","SizeOffset","LightColor",
    "LightDirection","Ambient","Range","Angle","Shadows","OutdoorAmbient","ColorShift_Top",
    "ColorShift_Bottom","GeographicLatitude","ClockTime","TimeOfDay","FogColor","FogStart",
    "FogEnd","GlobalShadows","EnvironmentDiffuseScale","EnvironmentSpecularScale",
    "ExposureCompensation","Technology","ShadowSoftness","SkyboxBk","SkyboxDn","SkyboxFt",
    "SkyboxLf","SkyboxRt","SkyboxUp","SkyboxOrientation","SunAngularSize","MoonAngularSize",
    "SunTextureId","MoonTextureId","StarCount","CelestialBodiesShown","Outlines","Volume",
    "Pitch","Looped","PlayOnRemove","TimePosition","PlaybackSpeed","Playing","RollOffMode",
    "RollOffMinDistance","RollOffMaxDistance","EmitterSize","Source","Disabled","RunContext",
    "LinkedSource","Lifetime","Rate","Speed","Drag","Acceleration","LockedToPart",
    "VelocityInheritance","Squash","EmissionDirection","Sequence","TimeScale","TextureMode",
    "RotSpeed","SpreadAngle","SpawnRadius","Width0","Width1","TextureLength","FaceCamera",
    "Segments","CurveSize0","CurveSize1","Attachment0","Attachment1","AttachmentForward",
    "AttachmentRight","AttachmentUp","HeadColor","TorsoColor","LeftArmColor","RightArmColor",
    "LeftLegColor","RightLegColor","Number","TargetRadius","MinRadius","Radius","Gain",
    "Diffuse","Specular","Velocity","Focus","FieldOfView","ReverbType","DistanceFactor",
    "AngularSpeed","Facing","DesiredAngle","CurrentAngle","MotorType","MaxVelocity",
    "MaxTorque","P","D","Coefficient","OuterConeAngle","InnerConeAngle","Depth","Height",
    "Width","DepthMode","FaceMode","Animation","Weight","CollisionFidelity","ClusterId",
    "PhysicalConfigData","PhysicsData","ChildData","MeshSize","InitialSize","InitialCFrame",
    "UnscaledCframe","UnscaledSize","AssetId","SmoothGrid","MaterialColors","WaterColor",
    "WaterWaveSize","WaterWaveSpeed","WaterReflectance","WaterTransparency","Decoration",
    "LeftParamA","LeftParamB","RightParamA","RightParamB","TopParamA","TopParamB",
    "BottomParamA","BottomParamB","FrontParamA","FrontParamB","BackParamA","BackParamB",
    "PrimaryPart","ModelInPrimary","Loop","IsPlaying","Priority","Time","EasingStyle",
    "EasingDirection","Pose","Mode","Grip","GripForward","GripPos","GripRight","GripUp",
    "ToolTip","CanBeDropped","RequiresHandle","ManualActivationOnly","BinType","Whitelist",
    "Blacklist","AutoAssignable","TeamColor","Gravity","FallHeightEnabled",
    "FallenPartsDestroyHeight","StreamingEnabled","StreamingIntegrityMode","StreamingMinRadius",
    "StreamingTargetRadius","TerrainWeldsFixed","DistributedGameTime","AllowThirdPartySales",
    "ResetPlayerGuiOnSpawn","LoadCharacterAppearance","LoadCharacterLayeredClothing",
    "UserEmotesEnabled","CameraMaxZoomDistance","CameraMinZoomDistance","CageMeshId",
    "ReferenceMeshId","AutoSkin","ShrinkFactor","Stiffness","Order","DebugMode","ColorMap",
    "NormalMap","RoughnessMap","MetalnessMap","EmissiveMask","AlphaMode","Metalness",
    "Roughness","TexturePack","OffsetStudsU","OffsetStudsV","StudsPerTileU","StudsPerTileV",
    "BasePartMaterial","Use2022Materials","MaxActivationDistance","HoldDuration","ActionText",
    "ObjectText","KeyboardKeyCode","GamepadKeyCode","RequiresLineOfSight","ClickablePrompt",
    "Exclusivity","UIOffset","FillColor","FillTransparency","OutlineColor",
    "OutlineTransparency","GroupColor3","GroupTransparency","CornerRadius","ApplyStrokeMode",
    "LineJoinMode","LimitsEnabled","UpperAngle","LowerAngle","TwistLimitsEnabled",
    "TwistLowerAngle","TwistUpperAngle","Restitution","Length","Thickness","LimitAngle0",
    "LimitAngle1","FreeLength","Coils","Damping","MaxLength","MinLength",
    "MotorMaxAcceleration","MotorMaxTorque","MotorSpeed","ServoMaxTorque","TargetAngle",
    "Part0","Part1","C0","C1","Axis","SecondaryAxis","LocalTransparencyModifier","Transform",
    "AutoLocalize","RootLocalizationTable","UsePartColor","ScaleTo","AutoResume",
    "PlaybackRegion","RegionDirection","LoopRegion","SoundGroup","AudioEqualizer","AudioFilter",
    "StyleRule","StyleSheet","StyleLink","AdShape","Puffiness","ReferenceOrigin","BindOffset",
    "WorldCageMeshId","Bevel","BevelRoundness","BevelType","PassThrough","Label","ModifierId",
    "LineThickness","SurfaceColor3","SurfaceTransparency","LineColor3","TextureSpeed",
    "LightEmission","LightInfluence","Density","Decay","Glare","Haze","Cover","CloudsEnabled",
    "ForceLimitMode","ForceLimitsEnabled","LineDirection","LineVelocity","MaxForce",
    "MaxAxesForce","PlaneVelocity","PrimaryTangentAxis","RelativeTo","SecondaryTangentAxis",
    "VectorVelocity","VelocityConstraintMode","AngularVelocity","ReactionTorqueEnabled",
    "ApplyAtCenterOfMass","Force","ReactionForceEnabled","Responsiveness","RigidityEnabled",
    "WorldCFrame","WorldPosition","WorldOrientation","WorldAxis","WorldSecondaryAxis",
    "WorldBasis","TransformedCFrame","TransformedWorldCFrame","RenderMesh","CollisionMesh",
}

local INSTANCE_SPECIFIC = {
    Tool={"TextureId","ToolTip","CanBeDropped","RequiresHandle","ManualActivationOnly","Enabled","Grip","GripForward","GripPos","GripRight","GripUp"},
    Part={"Shape","Size","CFrame","Anchored","CanCollide","CanTouch","CanQuery","CanClimb","Transparency","Reflectance","CastShadow","Material","MaterialVariant","BrickColor","Color","Massless","Locked","CollisionGroup","TopSurface","BottomSurface","LeftSurface","RightSurface","FrontSurface","BackSurface","CustomPhysicalProperties","FormFactor","Velocity"},
    WedgePart={"Shape","Size","CFrame","Anchored","CanCollide","CanTouch","CanQuery","CanClimb","Transparency","Reflectance","CastShadow","Material","MaterialVariant","BrickColor","Color","Massless","Locked","CollisionGroup","CustomPhysicalProperties"},
    CornerWedgePart={"Shape","Size","CFrame","Anchored","CanCollide","CanTouch","CanQuery","CanClimb","Transparency","Reflectance","CastShadow","Material","MaterialVariant","BrickColor","Color","Massless","Locked","CollisionGroup","CustomPhysicalProperties"},
    TrussPart={"Size","CFrame","Anchored","CanCollide","CanTouch","CanQuery","Transparency","Reflectance","CastShadow","Material","MaterialVariant","BrickColor","Color","Massless","Locked","CollisionGroup","Style"},
    Platform={"Size","CFrame","Anchored","CanCollide","CanTouch","CanQuery","CanClimb","Transparency","Reflectance","CastShadow","Material","MaterialVariant","BrickColor","Color","Massless","Locked","CollisionGroup"},
    SpawnLocation={"Size","CFrame","Anchored","CanCollide","Transparency","Material","MaterialVariant","BrickColor","Color","Enabled","Duration","Neutral","TeamColor","AllowTeamChangeOnTouch"},
    Seat={"Size","CFrame","Anchored","CanCollide","Material","MaterialVariant","BrickColor","Color","Disabled"},
    VehicleSeat={"Size","CFrame","Anchored","CanCollide","Material","MaterialVariant","BrickColor","Color","MaxSpeed","Torque","TurnSpeed","HeadsUpDisplay","Disabled"},
    MeshPart={"MeshId","TextureID","Size","CFrame","Anchored","CanCollide","CanTouch","CanQuery","CanClimb","Transparency","Reflectance","CastShadow","Material","MaterialVariant","BrickColor","Color","Massless","Locked","CollisionGroup","RenderFidelity","CollisionFidelity","DoubleSided","LevelOfDetail","MeshSize","InitialSize","Texture","CustomPhysicalProperties","RenderMesh"},
    UnionOperation={"AssetId","Size","CFrame","Anchored","CanCollide","CanTouch","CanQuery","CanClimb","Transparency","Reflectance","CastShadow","Material","MaterialVariant","BrickColor","Color","Massless","Locked","CollisionGroup","RenderFidelity","CollisionFidelity","ChildData","PhysicsData","PhysicalConfigData","InitialSize","InitialCFrame","MeshSize","CustomPhysicalProperties"},
    IntersectOperation={"AssetId","Size","CFrame","Anchored","CanCollide","CanTouch","CanQuery","CanClimb","Transparency","Reflectance","CastShadow","Material","MaterialVariant","BrickColor","Color","Massless","Locked","CollisionGroup","RenderFidelity","CollisionFidelity","ChildData","PhysicsData","PhysicalConfigData","InitialSize","InitialCFrame","MeshSize","CustomPhysicalProperties"},
    NegateOperation={"AssetId","Size","CFrame","Anchored","CanCollide","CanTouch","CanQuery","CanClimb","Transparency","Reflectance","CastShadow","Material","MaterialVariant","BrickColor","Color","Massless","Locked","CollisionGroup","ChildData","PhysicsData","PhysicalConfigData","InitialSize","InitialCFrame","MeshSize","CustomPhysicalProperties"},
    PartOperation={"AssetId","Size","CFrame","Anchored","CanCollide","CanTouch","CanQuery","CanClimb","Transparency","Reflectance","CastShadow","Material","MaterialVariant","BrickColor","Color","Massless","Locked","CollisionGroup","RenderFidelity","CollisionFidelity","ChildData","PhysicsData","PhysicalConfigData","InitialSize","InitialCFrame","MeshSize","CustomPhysicalProperties"},
    SpecialMesh={"MeshId","MeshType","Scale","Offset","VertexColor","TextureId","Texture"},
    CylinderMesh={"Scale","Offset","VertexColor"},
    BlockMesh={"Scale","Offset","VertexColor"},
    WedgeMesh={"Scale","Offset","VertexColor"},
    SphereMesh={"Scale","Offset","VertexColor"},
    BevelMesh={"Scale","Offset","VertexColor","Bevel","BevelRoundness","BevelType"},
    FileMesh={"MeshId","TextureId","Scale","Offset","VertexColor"},
    Decal={"Face","Texture","Color3","Transparency","ZIndex","LocalTransparencyModifier"},
    Texture={"Face","Texture","Color3","Transparency","ZIndex","OffsetStudsU","OffsetStudsV","StudsPerTileU","StudsPerTileV","LocalTransparencyModifier"},
    SurfaceAppearance={"ColorMap","NormalMap","RoughnessMap","MetalnessMap","EmissiveMask","AlphaMode","Color3","Metalness","Roughness","TexturePack"},
    Terrain={"SmoothGrid","MaterialColors","WaterColor","WaterWaveSize","WaterWaveSpeed","WaterReflectance","WaterTransparency","Decoration"},
    Lighting={"Ambient","OutdoorAmbient","ColorShift_Top","ColorShift_Bottom","Brightness","ClockTime","TimeOfDay","GeographicLatitude","FogColor","FogStart","FogEnd","GlobalShadows","ShadowSoftness","EnvironmentDiffuseScale","EnvironmentSpecularScale","ExposureCompensation","Technology","SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp","SkyboxOrientation","SunAngularSize","MoonAngularSize","SunTextureId","MoonTextureId","StarCount","CelestialBodiesShown","Outlines","CloudsEnabled"},
    Atmosphere={"Density","Offset","Color","Decay","Glare","Haze"},
    Clouds={"Cover","Density","Color","Enabled"},
    Sky={"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp","SkyboxOrientation","SunAngularSize","MoonAngularSize","SunTextureId","MoonTextureId","StarCount","CelestialBodiesShown"},
    BloomEffect={"Enabled","Intensity","Size","Threshold"},
    BlurEffect={"Enabled","Size"},
    ColorCorrectionEffect={"Enabled","Brightness","Contrast","Saturation","TintColor"},
    DepthOfFieldEffect={"Enabled","FarIntensity","FocusDistance","InFocusRadius","NearIntensity"},
    SunRaysEffect={"Enabled","Intensity","Spread"},
    PointLight={"Enabled","Brightness","Color","Range","Shadows"},
    SpotLight={"Enabled","Brightness","Color","Range","Angle","Face","Shadows"},
    SurfaceLight={"Enabled","Brightness","Color","Range","Angle","Face","Shadows"},
    Sound={"SoundId","Volume","Pitch","Looped","Playing","PlayOnRemove","PlaybackSpeed","TimePosition","RollOffMode","RollOffMinDistance","RollOffMaxDistance","EmitterSize","SoundGroup","ReverbType","DistanceFactor","MaxDistance","PlaybackRegion","LoopRegion","TimeLength","AudioEqualizer","AudioFilter"},
    SoundGroup={"Volume"},
    Animation={"AnimationId"},
    KeyframeSequence={"Loop","Priority"},
    Keyframe={"Time"},
    Pose={"CFrame","Weight","EasingStyle","EasingDirection"},
    Humanoid={"Health","MaxHealth","WalkSpeed","JumpPower","JumpHeight","HipHeight","AutoRotate","AutoJumpEnabled","AutoScalingEnabled","DisplayDistanceType","HealthDisplayDistance","NameDisplayDistance","DisplayName","RigType","BodyTypeScale","BodyDepthScale","BodyWidthScale","BodyHeightScale","HeadScale","BodyProportionScale","UniformScale","OriginalSize","AnimationId"},
    BodyColors={"HeadColor","TorsoColor","LeftArmColor","RightArmColor","LeftLegColor","RightLegColor"},
    CharacterMesh={"BasePart","MeshId","Overlay","BodyPart","TextureId"},
    Attachment={"CFrame","Position","Orientation","Axis","SecondaryAxis","Visible","WorldCFrame","WorldPosition","WorldOrientation","WorldAxis","WorldSecondaryAxis"},
    Bone={"CFrame","Position","Orientation","Transform","TransformedCFrame","TransformedWorldCFrame"},
    Motor6D={"Part0","Part1","C0","C1","CurrentAngle","DesiredAngle","MaxVelocity","Transform"},
    Motor={"Part0","Part1","C0","C1","CurrentAngle","DesiredAngle","MaxVelocity"},
    Weld={"Part0","Part1","C0","C1"},
    WeldConstraint={"Part0","Part1","Enabled"},
    Snap={"Part0","Part1","C0","C1"},
    Rotate={"Part0","Part1","C0","C1"},
    RotateP={"Part0","Part1","C0","C1"},
    RotateV={"Part0","Part1","C0","C1"},
    Glue={"Part0","Part1","C0","C1","F0","F1"},
    HingeConstraint={"Attachment0","Attachment1","MotorMaxAcceleration","MotorMaxTorque","MotorSpeed","ServoMaxTorque","TargetAngle","AngularVelocity","AngularSpeed","ActuatorType","LimitsEnabled","LowerAngle","UpperAngle","Radius","Visible","Enabled"},
    BallSocketConstraint={"Attachment0","Attachment1","LimitsEnabled","UpperAngle","TwistLimitsEnabled","TwistLowerAngle","TwistUpperAngle","Restitution","Radius","Visible","Enabled"},
    RodConstraint={"Attachment0","Attachment1","Length","Thickness","LimitsEnabled","LimitAngle0","LimitAngle1","Visible","Enabled"},
    RopeConstraint={"Attachment0","Attachment1","Length","Thickness","Restitution","Visible","Enabled"},
    SpringConstraint={"Attachment0","Attachment1","FreeLength","Coils","Damping","Stiffness","MaxForce","MaxLength","MinLength","Thickness","Visible","Enabled"},
    TorsionSpringConstraint={"Attachment0","Attachment1","Coils","Damping","MaxAngle","MaxTorque","Radius","Restitution","Stiffness","Visible","Enabled"},
    UniversalConstraint={"Attachment0","Attachment1","LimitsEnabled","MaxAngle","Radius","Restitution","Visible","Enabled"},
    CylindricalConstraint={"Attachment0","Attachment1","AngularActuatorType","AngularLimitsEnabled","AngularRestitution","AngularSpeed","AngularVelocity","InclinationAngle","LinearActuatorType","LinearLimitsEnabled","LinearRestitution","LinearVelocity","LowerAngle","LowerLimit","MotorMaxAcceleration","MotorMaxForce","Radius","ServoMaxForce","UpperAngle","UpperLimit","Visible","Enabled"},
    PrismaticConstraint={"Attachment0","Attachment1","ActuatorType","LimitsEnabled","LowerLimit","UpperLimit","MotorMaxAcceleration","MotorMaxForce","Restitution","ServoMaxForce","Speed","Velocity","Visible","Enabled"},
    PlaneConstraint={"Attachment0","Attachment1","Visible","Enabled"},
    AlignPosition={"Attachment0","Attachment1","ApplyAtCenterOfMass","MaxForce","MaxVelocity","Position","ReactionForceEnabled","Responsiveness","RigidityEnabled","Mode","Enabled"},
    AlignOrientation={"Attachment0","Attachment1","AlignType","CFrame","MaxAngularVelocity","MaxTorque","Mode","PrimaryAxisOnly","ReactionTorqueEnabled","Responsiveness","RigidityEnabled","Enabled"},
    LinearVelocity={"Attachment0","ForceLimitMode","ForceLimitsEnabled","LineDirection","LineVelocity","MaxForce","MaxAxesForce","PlaneVelocity","PrimaryTangentAxis","RelativeTo","SecondaryTangentAxis","VectorVelocity","VelocityConstraintMode","Visible","Enabled"},
    AngularVelocity={"Attachment0","AngularVelocity","MaxTorque","ReactionTorqueEnabled","RelativeTo","Visible","Enabled"},
    VectorForce={"Attachment0","ApplyAtCenterOfMass","Force","RelativeTo","Visible","Enabled"},
    Torque={"Attachment0","RelativeTo","Torque","Visible","Enabled"},
    ParticleEmitter={"Acceleration","Brightness","Color","ColorShift","Drag","EmissionDirection","EmitterSize","Enabled","FlipbookFramerate","FlipbookLayout","FlipbookMode","FlipbookStartRandom","Lifetime","LightEmission","LightInfluence","LockedToPart","Orientation","Rate","RotSpeed","Rotation","Shape","ShapeInOut","ShapePartial","ShapeStyle","Size","Size2","SoftParticlesEnabled","SoftParticlesFar","SoftParticlesNear","Speed","SpreadAngle","Squash","Texture","TimeScale","Transparency","VelocityInheritance","WindAffectsDrag","ZOffset"},
    Beam={"Attachment0","Attachment1","Brightness","Color","CurveSize0","CurveSize1","Enabled","FaceCamera","LightEmission","LightInfluence","Segments","Texture","TextureLength","TextureMode","TextureSpeed","Transparency","Width0","Width1","ZOffset"},
    Trail={"Attachment0","Attachment1","Brightness","Color","Enabled","FaceCamera","Lifetime","LightEmission","LightInfluence","MaxLength","MinLength","Texture","TextureLength","TextureMode","Transparency","WidthScale"},
    Fire={"Enabled","Color","SecondaryColor","Heat","Size"},
    Smoke={"Enabled","Color","Opacity","RiseVelocity","Size"},
    Sparkles={"Enabled","Color","SparkleColor","TimeScale"},
    ScreenGui={"DisplayOrder","Enabled","IgnoreGuiInset","ResetOnSpawn","ScreenInsets","ClipToDeviceSafeArea","SafeAreaCompatibility","ZIndexBehavior"},
    SurfaceGui={"Adornee","AlwaysOnTop","Brightness","CanvasSize","ClipsDescendants","Enabled","Face","LightInfluence","MaxDistance","PixelsPerStud","ResetOnSpawn","SizingMode","ToolPunchThroughDistance","ZOffset","ZIndexBehavior"},
    BillboardGui={"Adornee","AlwaysOnTop","Brightness","ClipsDescendants","DistanceLowerLimit","DistanceUpperLimit","Enabled","ExtentsOffset","ExtentsOffsetWorldSpace","LightInfluence","MaxDistance","ResetOnSpawn","Size","SizeOffset","StudsOffset","StudsOffsetWorldSpace","ZIndexBehavior"},
    Frame={"BackgroundColor3","BackgroundTransparency","BorderColor3","BorderMode","BorderSizePixel","Size","Position","AnchorPoint","ClipsDescendants","Visible","ZIndex","LayoutOrder","Rotation","Selectable","Active","Style","AutomaticSize"},
    ScrollingFrame={"BackgroundColor3","BackgroundTransparency","BorderColor3","BorderMode","BorderSizePixel","Size","Position","AnchorPoint","CanvasSize","CanvasPosition","ScrollBarThickness","ScrollBarImageColor3","ScrollBarImageTransparency","ElasticBehavior","ScrollingDirection","ScrollingEnabled","VerticalScrollBarInset","HorizontalScrollBarInset","AutomaticCanvasSize","ClipsDescendants","Visible","ZIndex","LayoutOrder","Rotation","Selectable","Active","Style"},
    CanvasGroup={"GroupColor3","GroupTransparency","BackgroundColor3","BackgroundTransparency","BorderColor3","BorderMode","BorderSizePixel","Size","Position","AnchorPoint","ClipsDescendants","Visible","ZIndex","LayoutOrder","Rotation","Selectable","Active","AutomaticSize"},
    ViewportFrame={"CurrentCamera","Ambient","LightColor","LightDirection","ImageColor3","ImageTransparency","BackgroundColor3","BackgroundTransparency","BorderColor3","BorderMode","BorderSizePixel","Size","Position","AnchorPoint","Visible","ZIndex","LayoutOrder","Rotation","Selectable","Active"},
    VideoFrame={"Video","Playing","Looped","TimePosition","Volume","PlaybackSpeed","BackgroundColor3","BackgroundTransparency","BorderColor3","BorderMode","BorderSizePixel","Size","Position","AnchorPoint","Visible","ZIndex","LayoutOrder","Rotation","Selectable","Active"},
    TextLabel={"BackgroundColor3","BackgroundTransparency","BorderColor3","BorderMode","BorderSizePixel","Size","Position","AnchorPoint","Text","TextColor3","TextSize","TextScaled","TextWrapped","TextStrokeColor3","TextStrokeTransparency","TextTransparency","RichText","Font","FontFace","LineHeight","MaxVisibleGraphemes","TextXAlignment","TextYAlignment","TextTruncate","TextFits","Visible","ZIndex","LayoutOrder","Rotation","Selectable","Active","AutoLocalize","AutomaticSize"},
    TextButton={"BackgroundColor3","BackgroundTransparency","BorderColor3","BorderMode","BorderSizePixel","Size","Position","AnchorPoint","Text","TextColor3","TextSize","TextScaled","TextWrapped","TextStrokeColor3","TextStrokeTransparency","TextTransparency","RichText","Font","FontFace","LineHeight","MaxVisibleGraphemes","TextXAlignment","TextYAlignment","TextTruncate","TextFits","Visible","ZIndex","LayoutOrder","Rotation","Selectable","Active","AutoButtonColor","Modal","Style","AutoLocalize","AutomaticSize"},
    TextBox={"BackgroundColor3","BackgroundTransparency","BorderColor3","BorderMode","BorderSizePixel","Size","Position","AnchorPoint","Text","TextColor3","TextSize","TextScaled","TextWrapped","TextStrokeColor3","TextStrokeTransparency","TextTransparency","RichText","Font","FontFace","LineHeight","MaxVisibleGraphemes","TextXAlignment","TextYAlignment","TextTruncate","TextFits","PlaceholderText","PlaceholderColor3","ClearTextOnFocus","MultiLine","TextEditable","Visible","ZIndex","LayoutOrder","Rotation","Selectable","Active","AutoLocalize","AutomaticSize"},
    ImageLabel={"BackgroundColor3","BackgroundTransparency","BorderColor3","BorderMode","BorderSizePixel","Size","Position","AnchorPoint","Image","ImageColor3","ImageRectOffset","ImageRectSize","ImageTransparency","ResampleMode","ScaleType","SliceCenter","SliceScale","TileSize","Visible","ZIndex","LayoutOrder","Rotation","Selectable","Active","AutomaticSize"},
    ImageButton={"BackgroundColor3","BackgroundTransparency","BorderColor3","BorderMode","BorderSizePixel","Size","Position","AnchorPoint","Image","ImageColor3","ImageRectOffset","ImageRectSize","ImageTransparency","ResampleMode","ScaleType","SliceCenter","SliceScale","TileSize","Visible","ZIndex","LayoutOrder","Rotation","Selectable","Active","AutoButtonColor","Modal","Style","AutomaticSize"},
    UIListLayout={"Padding","FillDirection","HorizontalAlignment","VerticalAlignment","SortOrder","HorizontalFlex","VerticalFlex","Wraps"},
    UIGridLayout={"CellPadding","CellSize","FillDirection","FillDirectionMaxCells","HorizontalAlignment","VerticalAlignment","SortOrder","StartCorner"},
    UITableLayout={"FillDirection","FillEmptySpaceColumns","FillEmptySpaceRows","HorizontalAlignment","MajorAxis","Padding","SortOrder","VerticalAlignment"},
    UIPageLayout={"Animated","Circular","EasingDirection","EasingStyle","FillDirection","GamepadInputEnabled","HorizontalAlignment","Padding","ScrollWheelInputEnabled","SortOrder","TouchInputEnabled","TweenTime","VerticalAlignment"},
    UIPadding={"PaddingTop","PaddingBottom","PaddingLeft","PaddingRight"},
    UICorner={"CornerRadius"},
    UIStroke={"ApplyStrokeMode","Color","Enabled","LineJoinMode","Thickness","Transparency"},
    UIGradient={"Color","Enabled","Offset","Rotation","Transparency"},
    UIScale={"Scale"},
    UIAspectRatioConstraint={"AspectRatio","AspectType","DominantAxis"},
    UISizeConstraint={"MaxSize","MinSize"},
    UITextSizeConstraint={"MaxTextSize","MinTextSize"},
    Highlight={"Adornee","DepthMode","Enabled","FillColor","FillTransparency","OutlineColor","OutlineTransparency"},
    ClickDetector={"MaxActivationDistance","CursorIcon"},
    ProximityPrompt={"ActionText","ObjectText","HoldDuration","MaxActivationDistance","RequiresLineOfSight","KeyboardKeyCode","GamepadKeyCode","ClickablePrompt","Exclusivity","UIOffset","Style","Enabled","AutoLocalize"},
    Team={"TeamColor","AutoAssignable"},
    Camera={"CameraType","CameraSubject","CFrame","Focus","FieldOfView","CameraMode","FieldOfViewMode","MaxAxisFieldOfView","DiagonalFieldOfView"},
    Model={"PrimaryPart","WorldPivot","ModelInPrimary"},
    Folder={}, Configuration={},
    NumberValue={"Value"}, StringValue={"Value"}, BoolValue={"Value"}, IntValue={"Value"},
    ObjectValue={"Value"}, Vector3Value={"Value"}, CFrameValue={"Value"}, Color3Value={"Value"},
    BrickColorValue={"Value"}, RayValue={"Value"},
    RemoteEvent={}, RemoteFunction={}, BindableEvent={}, BindableFunction={},
    Script={"Source","Disabled","RunContext","LinkedSource"},
    LocalScript={"Source","Disabled","RunContext","LinkedSource"},
    ModuleScript={"Source","Disabled","RunContext","LinkedSource"},
    WrapLayer={"AutoSkin","BindOffset","CageMeshId","ColorMap","Enabled","Order","Puffiness","ReferenceMeshId","ReferenceOrigin","ShrinkFactor","Stiffness"},
    WrapTarget={"AutoSkin","CageMeshId","ColorMap","Depth","Height","ReferenceMeshId","Stiffness","Width"},
    PathfindingModifier={"PassThrough","Label","ModifierId"},
    PathfindingLink={"Attachment0","Attachment1"},
    Actor={"Enabled"},
    StyleRule={"Selector","Properties","Priority"},
    StyleSheet={"Source"},
    StyleLink={"StyleSheet"},
    AudioPlayer={"AssetId","Volume","PlaybackSpeed","Looped","Playing","TimePosition"},
    AudioDeviceOutput={"Player"},
    AudioDeviceInput={"Player"},
}

local ATTR_TYPE_IDS = {string=0x02,boolean=0x03,number=0x04,UDim=0x0D,UDim2=0x10,Vector2=0x12,Vector3=0x13,CFrame=0x10,Color3=0x1A,BrickColor=0x1E,NumberRange=0x1F,NumberSequence=0x20,ColorSequence=0x21,Rect=0x22,Font=0x1C}

local function u32(n) return string.pack("<I4", n) end
local function f32(n) return string.pack("<f", n) end
local function f64(n) return string.pack("<d", n) end
local function i32(n) return string.pack("<i4", n) end
local function wstr(s) return u32(#s) .. s end

local function attrWriteValue(t, v)
    if t == "string" then return wstr(v)
    elseif t == "boolean" then return string.char(v and 1 or 0)
    elseif t == "number" then return f64(v)
    elseif t == "Vector2" then return f32(v.X) .. f32(v.Y)
    elseif t == "Vector3" then return f32(v.X) .. f32(v.Y) .. f32(v.Z)
    elseif t == "UDim" then return f32(v.Scale) .. i32(v.Offset)
    elseif t == "UDim2" then return f32(v.X.Scale) .. i32(v.X.Offset) .. f32(v.Y.Scale) .. i32(v.Y.Offset)
    elseif t == "Color3" then return f32(v.R) .. f32(v.G) .. f32(v.B)
    elseif t == "BrickColor" then return u32(v.Number)
    elseif t == "CFrame" then
        local c = {v:GetComponents()}
        local out = ""
        for i = 1, 12 do out = out .. f32(c[i]) end
        return out
    elseif t == "NumberRange" then return f32(v.Min) .. f32(v.Max)
    elseif t == "Rect" then return f32(v.Min.X) .. f32(v.Min.Y) .. f32(v.Max.X) .. f32(v.Max.Y)
    elseif t == "NumberSequence" then
        local out = u32(#v.Keypoints)
        for _, k in ipairs(v.Keypoints) do
            out = out .. f32(k.Time) .. f32(k.Value) .. f32(k.Envelope)
        end
        return out
    elseif t == "ColorSequence" then
        local out = u32(#v.Keypoints)
        for _, k in ipairs(v.Keypoints) do
            out = out .. f32(k.Time) .. f32(k.Value.R) .. f32(k.Value.G) .. f32(k.Value.B)
        end
        return out
    end
    return nil
end

local function encodeAttributes(inst)
    local ok, attrs = pcall(function() return inst:GetAttributes() end)
    if not ok or not attrs then return nil end
    local names = {}
    for k in pairs(attrs) do table.insert(names, k) end
    if #names == 0 then return nil end
    table.sort(names)
    local out = u32(#names)
    for _, name in ipairs(names) do
        local v = attrs[name]
        local t = typeof(v)
        local typeId = ATTR_TYPE_IDS[t]
        if typeId then
            out = out .. wstr(name) .. string.char(typeId)
            local body = attrWriteValue(t, v)
            if body then out = out .. body else out = out .. string.char(0) end
        end
    end
    return out
end

local function encodeTags(inst)
    local ok, tags = pcall(function() return CollectionService:GetTags(inst) end)
    if not ok or not tags or #tags == 0 then return nil end
    local out = u32(#tags)
    for _, t in ipairs(tags) do out = out .. wstr(t) end
    return out
end

local function clean(s)
    s = tostring(s)
    s = s:gsub("[%z\1-\8\11\12\14-\31]", "")
    s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    s = s:gsub('"', "&quot;"):gsub("'", "&apos;")
    return s
end

local function nm(x)
    if type(x) ~= "number" then return "0" end
    if x ~= x then return "0" end
    if x == math.huge then return "1e308" end
    if x == -math.huge then return "-1e308" end
    if x == math.floor(x) and math.abs(x) < 1e15 then return string.format("%d", x) end
    return string.format("%.10g", x)
end

local function isRealContent(name) return REAL_CONTENT_PROPS[name] == true end

local function shouldSkipProp(name)
    if SKIP_PROP[name] then return true end
    if CONTENT_PROP_EXACT[name] then return true end
    return false
end

local function extractUri(v)
    if v == nil then return nil end
    local tv = type(v)
    if tv == "string" then
        if v == "" then return nil end
        local id = v:match("rbxassetid://(%d+)")
        if id then return "rbxassetid://" .. id end
        local num = v:match("^(%d+)$")
        if num and #num >= 5 then return "rbxassetid://" .. num end
        if v:match("^rbxasset://") or v:match("^rbxgameasset://") or v:match("^rbxthumb://") or v:match("^https?://") or v:match("^rbxfile://") then return v end
        local tail = v:match("(%d+)%s*$")
        if tail and #tail >= 5 then return "rbxassetid://" .. tail end
        return nil
    end
    if tv == "number" then return "rbxassetid://" .. tostring(v) end
    local accessors = {"Source","Uri","Url","URL","Value","Text","String","AssetId","AssetID","Id","ID","Content","source","uri","url","value"}
    for _, key in ipairs(accessors) do
        local ok, s = pcall(function() return v[key] end)
        if ok and type(s) == "string" and s ~= "" then
            local inner = extractUri(s)
            if inner then return inner end
        end
        if ok and type(s) == "number" then return "rbxassetid://" .. tostring(s) end
    end
    local methods = {"ToString","GetSource","GetUri","GetUrl"}
    for _, m in ipairs(methods) do
        local ok, f = pcall(function() return v[m] end)
        if ok and type(f) == "function" then
            local ok2, s = pcall(f, v)
            if ok2 and type(s) == "string" and s ~= "" then
                local inner = extractUri(s)
                if inner then return inner end
            end
        end
    end
    if tv == "table" then
        for _, val in pairs(v) do
            if type(val) == "string" and val ~= "" then
                local inner = extractUri(val)
                if inner then return inner end
            end
        end
    end
    local ok, s = pcall(tostring, v)
    if ok and type(s) == "string" and s ~= "" then
        local id = s:match("rbxassetid://(%d+)")
        if id then return "rbxassetid://" .. id end
        local asset = s:match("rbxasset://([^%s%)%,]+)")
        if asset then return "rbxasset://" .. asset end
        local ga = s:match("rbxgameasset://(%d+)")
        if ga then return "rbxgameasset://" .. ga end
        local thumb = s:match("rbxthumb://[^%s%)]+")
        if thumb then return thumb end
        local http = s:match("(https?://[^%s%)%,]+)")
        if http then return http end
        local inner = s:match("Content%((.-)%)")
        if inner and inner ~= "" and inner ~= s then return extractUri(inner) end
    end
    return nil
end

local function b64(s) return HttpService:Base64Encode(s) end

local function notify(title, text, dur)
    if not Fish.Options.Notify then return end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = dur or 6,
        })
    end)
end

local function serContentTag(name, uri) return '<Content name="' .. clean(name) .. '"><url>' .. clean(uri) .. '</url></Content>' end
local function serString(name, v) if type(v) ~= "string" then return nil end return '<string name="' .. clean(name) .. '">' .. clean(v) .. '</string>' end
local function serProtectedString(name, v) if type(v) ~= "string" then v = "" end return '<ProtectedString name="' .. clean(name) .. '">' .. clean(v) .. '</ProtectedString>' end
local function serBool(name, v) if type(v) ~= "boolean" then v = v and true or false end return '<bool name="' .. clean(name) .. '">' .. (v and "true" or "false") .. '</bool>' end
local function serInt(name, v) return '<int name="' .. clean(name) .. '">' .. string.format("%d", v) .. '</int>' end
local function serInt64(name, v) return '<int64 name="' .. clean(name) .. '">' .. string.format("%d", v) .. '</int64>' end
local function serFloat(name, v) return '<float name="' .. clean(name) .. '">' .. nm(v) .. '</float>' end
local function serDouble(name, v) return '<double name="' .. clean(name) .. '">' .. nm(v) .. '</double>' end
local function serNumber(name, v)
    if v == math.floor(v) and v >= -2147483648 and v <= 2147483647 then return serInt(name, v) end
    if v == math.floor(v) and math.abs(v) < 9007199254740992 then return serInt64(name, v) end
    return serDouble(name, v)
end
local function serVector2(name, v) return '<Vector2 name="' .. clean(name) .. '"><X>' .. nm(v.X) .. '</X><Y>' .. nm(v.Y) .. '</Y></Vector2>' end
local function serVector3(name, v) return '<Vector3 name="' .. clean(name) .. '"><X>' .. nm(v.X) .. '</X><Y>' .. nm(v.Y) .. '</Y><Z>' .. nm(v.Z) .. '</Z></Vector3>' end
local function serCFrame(name, v)
    local ok, r = pcall(function() return {v:GetComponents()} end)
    if not ok or not r then return nil end
    local s = '<CoordinateFrame name="' .. clean(name) .. '"><X>' .. nm(r[1]) .. '</X><Y>' .. nm(r[2]) .. '</Y><Z>' .. nm(r[3]) .. '</Z>'
    for i = 0, 2 do for j = 0, 2 do s = s .. '<R' .. i .. j .. '>' .. nm(r[i * 3 + j + 4]) .. '</R' .. i .. j .. '>' end end
    return s .. '</CoordinateFrame>'
end
local function serColor3(name, v) return '<Color3 name="' .. clean(name) .. '"><R>' .. nm(v.R) .. '</R><G>' .. nm(v.G) .. '</G><B>' .. nm(v.B) .. '</B></Color3>' end
local function serBrickColor(name, v) return '<BrickColor name="' .. clean(name) .. '">' .. tostring(v.Number) .. '</BrickColor>' end
local function serUDim(name, v) return '<UDim name="' .. clean(name) .. '"><S>' .. nm(v.Scale) .. '</S><O>' .. tostring(v.Offset) .. '</O></UDim>' end
local function serUDim2(name, v) return '<UDim2 name="' .. clean(name) .. '"><XS>' .. nm(v.X.Scale) .. '</XS><XO>' .. tostring(v.X.Offset) .. '</XO><YS>' .. nm(v.Y.Scale) .. '</YS><YO>' .. tostring(v.Y.Offset) .. '</YO></UDim2>' end
local function serRect(name, v) return '<Rect name="' .. clean(name) .. '"><min><X>' .. nm(v.Min.X) .. '</X><Y>' .. nm(v.Min.Y) .. '</Y></min><max><X>' .. nm(v.Max.X) .. '</X><Y>' .. nm(v.Max.Y) .. '</Y></max></Rect>' end
local function serNumberRange(name, v) return '<NumberRange name="' .. clean(name) .. '"><Min>' .. nm(v.Min) .. '</Min><Max>' .. nm(v.Max) .. '</Max></NumberRange>' end
local function serNumberSequence(name, v)
    local s = '<NumberSequence name="' .. clean(name) .. '">'
    for _, k in ipairs(v.Keypoints) do s = s .. '<Keypoint><Time>' .. nm(k.Time) .. '</Time><Value>' .. nm(k.Value) .. '</Value><Envelope>' .. nm(k.Envelope) .. '</Envelope></Keypoint>' end
    return s .. '</NumberSequence>'
end
local function serColorSequence(name, v)
    local s = '<ColorSequence name="' .. clean(name) .. '">'
    for _, k in ipairs(v.Keypoints) do s = s .. '<Keypoint><Time>' .. nm(k.Time) .. '</Time><Color><R>' .. nm(k.Value.R) .. '</R><G>' .. nm(k.Value.G) .. '</G><B>' .. nm(k.Value.B) .. '</B></Color></Keypoint>' end
    return s .. '</ColorSequence>'
end
local function serEnumItem(name, v)
    local ok, val = pcall(function() return v.Value end)
    if ok and type(val) == "number" then return '<token name="' .. clean(name) .. '">' .. tostring(val) .. '</token>' end
    return nil
end
local function serTokenNumber(name, v)
    if type(v) == "number" then return '<token name="' .. clean(name) .. '">' .. tostring(v) .. '</token>' end
    local ok, val = pcall(function() return v.Value end)
    if ok and type(val) == "number" then return '<token name="' .. clean(name) .. '">' .. tostring(val) .. '</token>' end
    return nil
end
local function serFaces(name, v)
    local f, base = 0, 1
    for _, k in ipairs({"Top","Bottom","Left","Right","Front","Back"}) do if v[k] then f = f + base end base = base * 2 end
    return '<token name="' .. clean(name) .. '">' .. f .. '</token>'
end
local function serAxes(name, v)
    local f, base = 0, 1
    for _, k in ipairs({"X","Y","Z"}) do if v[k] then f = f + base end base = base * 2 end
    return '<token name="' .. clean(name) .. '">' .. f .. '</token>'
end

local Walker = { refs = {}, refCount = 0, totalInst = 0 }

local function serInstance(name, v)
    if Walker.refs[v] then return '<Ref name="' .. clean(name) .. '">' .. Walker.refs[v] .. '</Ref>' end
    return nil
end
local function serPhysicalProps(name, v)
    local ok, body = pcall(function()
        return '<Density>' .. nm(v.Density) .. '</Density><Friction>' .. nm(v.Friction) .. '</Friction><Elasticity>' .. nm(v.Elasticity) .. '</Elasticity><FrictionWeight>' .. nm(v.FrictionWeight) .. '</FrictionWeight><ElasticityWeight>' .. nm(v.ElasticityWeight) .. '</ElasticityWeight>'
    end)
    if not ok or not body then return nil end
    return '<PhysicalProperties name="' .. clean(name) .. '">' .. body .. '</PhysicalProperties>'
end
local function serBinaryString(name, v)
    if type(v) ~= "string" then return nil end
    local ok, s = pcall(b64, v)
    if ok and s then return '<BinaryString name="' .. clean(name) .. '">' .. s .. '</BinaryString>' end
    return nil
end
local function serRay(name, v)
    local ok, o, d = pcall(function() return v.Origin, v.Direction end)
    if not ok then return nil end
    return '<Ray name="' .. clean(name) .. '"><Origin><X>' .. nm(o.X) .. '</X><Y>' .. nm(o.Y) .. '</Y><Z>' .. nm(o.Z) .. '</Z></Origin><Direction><X>' .. nm(d.X) .. '</X><Y>' .. nm(d.Y) .. '</Y><Z>' .. nm(d.Z) .. '</Z></Direction></Ray>'
end
local function serFont(name, v)
    local parts = {}
    pcall(function() table.insert(parts, '<Family>' .. clean(v.Family) .. '</Family>') end)
    pcall(function() table.insert(parts, '<Weight>' .. tostring(v.Weight.Value) .. '</Weight>') end)
    pcall(function() table.insert(parts, '<Style>' .. tostring(v.Style.Value) .. '</Style>') end)
    if #parts == 0 then return nil end
    return '<Font name="' .. clean(name) .. '">' .. table.concat(parts) .. '</Font>'
end

local serByType = {
    string = serString, ProtectedString = serProtectedString, SharedString = serString,
    boolean = serBool, bool = serBool, number = serNumber, int = serInt, int64 = serInt64,
    float = serFloat, double = serDouble, Vector2 = serVector2, Vector3 = serVector3,
    CFrame = serCFrame, Color3 = serColor3, BrickColor = serBrickColor, UDim = serUDim,
    UDim2 = serUDim2, Rect = serRect, NumberRange = serNumberRange,
    NumberSequence = serNumberSequence, ColorSequence = serColorSequence,
    EnumItem = serEnumItem, Faces = serFaces, Axes = serAxes, Instance = serInstance,
    PhysicalProperties = serPhysicalProps, BinaryString = serBinaryString,
    Ray = serRay, Font = serFont, FontFace = serFont,
}

local specialPropHandlers = { Shape = serTokenNumber, Face = serTokenNumber, Material = serTokenNumber }

local function serializeProp(name, v)
    if v == nil then return nil end
    if shouldSkipProp(name) then return nil end
    if type(v) == "boolean" then return serBool(name, v) end
    local special = specialPropHandlers[name]
    if special then local s = special(name, v) if s then return s end end
    local t = typeof(v)
    if t == "EnumItem" then return serEnumItem(name, v) end
    local fn = serByType[t]
    if not fn and type(v) == "boolean" then fn = serBool end
    if not fn then return nil end
    local ok, s = pcall(fn, name, v)
    if ok and s and s ~= "" then return s end
    return nil
end

local function propsViaGetProperties(inst)
    if not Fish.Options.UseGetProperties or not IO.getproperties then return nil end
    local ok, list = pcall(IO.getproperties, inst)
    if not ok or type(list) ~= "table" then return nil end
    local out = {}
    for _, k in ipairs(list) do
        if type(k) == "string" and not shouldSkipProp(k) then table.insert(out, k) end
    end
    return out
end

local defaultCache = {}
local function getDefault(className)
    if defaultCache[className] ~= nil then return defaultCache[className] end
    local ok, inst = pcall(Instance.new, className)
    if not ok or not inst then defaultCache[className] = false return false end
    defaultCache[className] = inst
    return inst
end

local function valuesEqual(a, b)
    if a == b then return true end
    local ta, tb = typeof(a), typeof(b)
    if ta ~= tb then return false end
    if ta == "number" then return math.abs(a - b) < 1e-6 end
    if ta == "string" or ta == "boolean" then return a == b end
    local ok1, s1 = pcall(tostring, a)
    local ok2, s2 = pcall(tostring, b)
    if ok1 and ok2 then return s1 == s2 end
    return false
end

local function modelIsCharacter(m)
    local ok, h = pcall(function() return m:FindFirstChildOfClass("Humanoid") end)
    if not ok or not h then return false end
    local ok2, hrp = pcall(function() return m:FindFirstChild("HumanoidRootPart") end)
    if ok2 and hrp then return true end
    local ok3, head = pcall(function() return m:FindFirstChild("Head") end)
    local ok4, torso = pcall(function() return m:FindFirstChild("Torso") or m:FindFirstChild("UpperTorso") or m:FindFirstChild("LowerTorso") end)
    if ok3 and head and ok4 and torso then return true end
    return false
end

local function isCharacter(inst, opts, charRefs)
    if not opts.StripCharacters then return false end
    if not inst then return false end
    if charRefs[inst] then return true end
    local cls = inst.ClassName
    if cls == "Model" then
        if modelIsCharacter(inst) then
            charRefs[inst] = true
            local okd, desc = pcall(function() return inst:GetDescendants() end)
            if okd and desc then for _, d in ipairs(desc) do charRefs[d] = true end end
            return true
        end
        return false
    end
    if cls == "Humanoid" then charRefs[inst] = true return true end
    if CHARACTER_CLASSES[cls] then
        local p = inst.Parent
        if p and p.ClassName == "Model" and modelIsCharacter(p) then charRefs[inst] = true return true end
    end
    return false
end

local function nameIsCore(inst, opts, coreRefs)
    if not opts.StripCoreScripts then return false end
    local ok, n = pcall(function() return inst.Name end)
    if not ok or not n then return false end
    if CORE_SCRIPT_NAMES[n] then coreRefs[inst] = true return true end
    return false
end

local function ancestorIsCore(inst, opts, coreRefs)
    if not opts.StripCoreScripts then return false end
    local p = inst
    for _ = 1, 30 do
        p = p.Parent
        if not p then return false end
        if coreRefs[p] then return true end
        if p.ClassName == "PlayerScripts" or p.ClassName == "PlayerGui" or p == Players or p == game:GetService("StarterPlayer") then return true end
        if p == game then return false end
    end
    return false
end

local function keepInst(inst, opts, charRefs, coreRefs)
    if isCharacter(inst, opts, charRefs) then return false end
    if nameIsCore(inst, opts, coreRefs) then return false end
    if ancestorIsCore(inst, opts, coreRefs) then return false end
    if opts.IgnoreNotArchivable then
        local ok, ar = pcall(function() return inst.Archivable end)
        if ok and ar == false then return false end
    end
    local parent = inst.Parent
    if parent and charRefs[parent] then return false end
    if parent and coreRefs[parent] then return false end
    local cls = inst.ClassName
    if SKIP_SVC[cls] and parent == game then return false end
    return true
end

local function walkRef(root, d, opts, refs, charRefs, coreRefs)
    if d > opts.Depth then return end
    if refs[root] then return end
    Walker.refCount = Walker.refCount + 1
    refs[root] = "RBX" .. Walker.refCount
    local ok, kids = pcall(function() return root:GetChildren() end)
    if not ok or not kids then return end
    for _, c in ipairs(kids) do
        if keepInst(c, opts, charRefs, coreRefs) then walkRef(c, d + 1, opts, refs, charRefs, coreRefs) end
    end
end

local function readProp(inst, name)
    local ok, v = pcall(function() return inst[name] end)
    if ok and v ~= nil then return v end
    return nil
end

local function emitContentProp(buf, inst, pad, propName)
    local raw = readProp(inst, propName)
    if raw == nil then return end
    local uri = extractUri(raw)
    if not uri then return end
    table.insert(buf, pad .. '    ' .. serContentTag(propName, uri))
end

local function emitSingleProp(buf, inst, pad, seen, k, opts, defaultInst)
    if seen[k] or shouldSkipProp(k) then return end
    seen[k] = true
    if isRealContent(k) then
        emitContentProp(buf, inst, pad, k)
    else
        local v = readProp(inst, k)
        if v ~= nil then
            local skip = false
            if defaultInst then
                local okd, dv = pcall(function() return defaultInst[k] end)
                if okd and dv ~= nil then
                    local ok1, eq = pcall(valuesEqual, v, dv)
                    if ok1 and eq then skip = true end
                end
            end
            if not skip then
                local s = serializeProp(k, v)
                if s then table.insert(buf, pad .. '    ' .. s) end
            end
        end
    end
end

local function emitPropsFromList(buf, inst, pad, seen, list, opts)
    local cls = inst.ClassName
    local defaultInst = opts.IgnoreDefaultProps and getDefault(cls) or nil
    for _, k in ipairs(list) do
        emitSingleProp(buf, inst, pad, seen, k, opts, defaultInst)
    end
end

local function emitAttributesAndTags(buf, inst, pad, opts)
    if opts.EmitAttributes then
        local ok, encoded = pcall(encodeAttributes, inst)
        if ok and encoded and #encoded > 0 then
            table.insert(buf, pad .. '    <BinaryString name="AttributesSerialize">' .. b64(encoded) .. '</BinaryString>')
        end
    end
    if opts.EmitTags then
        local ok, encoded = pcall(encodeTags, inst)
        if ok and encoded then
            table.insert(buf, pad .. '    <BinaryString name="Tags">' .. b64(encoded) .. '</BinaryString>')
        end
    end
end

local function shouldEmitInMode(cls, mode)
    if mode == "full" then return true end
    if mode == "scripts" then return cls == "Script" or cls == "LocalScript" or cls == "ModuleScript" end
    if mode == "models" then return cls ~= "Script" and cls ~= "LocalScript" and cls ~= "ModuleScript" end
    return true
end

local function emitInst(buf, inst, d, opts, decompileCache, refs)
    local ref = refs[inst]
    if not ref then return end
    local pad = string.rep("  ", d)
    local cls = inst.ClassName

    if not shouldEmitInMode(cls, opts.Mode) then
        local okc, kids = pcall(function() return inst:GetChildren() end)
        if okc and kids then for _, c in ipairs(kids) do if refs[c] then emitInst(buf, c, d, opts, decompileCache, refs) end end end
        return
    end

    Walker.totalInst = Walker.totalInst + 1
    bumpProgress()

    table.insert(buf, pad .. '<Item class="' .. clean(cls) .. '" referent="' .. ref .. '">')
    table.insert(buf, pad .. '  <Properties>')

    local seen = {}
    local specific = INSTANCE_SPECIFIC[cls]
    if specific then emitPropsFromList(buf, inst, pad, seen, specific, opts) end

    emitPropsFromList(buf, inst, pad, seen, CRITICAL_PROPS, opts)

    local dynProps = propsViaGetProperties(inst)
    if dynProps then
        for _, k in ipairs(dynProps) do
            emitSingleProp(buf, inst, pad, seen, k, opts, nil)
        end
    end

    if not seen.Name then
        local name = readProp(inst, "Name")
        if name then
            if opts.Anonymous then
                local ok, p = pcall(function() return Players:GetPlayerFromCharacter(inst) end)
                if ok and p then name = "Player_" .. tostring(p.UserId) end
            end
            table.insert(buf, pad .. '    <string name="Name">' .. clean(name) .. '</string>')
        end
    end

    emitAttributesAndTags(buf, inst, pad, opts)

    if cls == "LocalScript" or cls == "ModuleScript" or cls == "Script" then
        local src = readProp(inst, "Source")
        if decompileCache and decompileCache[inst] then src = decompileCache[inst] end
        if (not src or src == "") and opts.Decompile and opts._decompileFn then
            local okd, decoded = pcall(opts._decompileFn, inst)
            if okd and type(decoded) == "string" and decoded ~= "" then src = decoded end
        end
        if (not src or src == "") and opts.SaveBytecode and opts._bytecodeFn then
            local okb, bc = pcall(opts._bytecodeFn, inst)
            if okb and type(bc) == "string" and bc ~= "" then src = b64(bc) end
        end
        table.insert(buf, pad .. '    <ProtectedString name="Source">' .. clean(src or "") .. '</ProtectedString>')
    end

    if cls == "UnionOperation" or cls == "IntersectOperation" or cls == "NegateOperation" or cls == "PartOperation" then
        for _, bp in ipairs({"ChildData", "PhysicsData", "PhysicalConfigData"}) do
            if not seen[bp] then
                local raw = readProp(inst, bp)
                if raw and type(raw) == "string" then
                    local okc, c = pcall(b64, raw)
                    if okc and c then table.insert(buf, pad .. '    <BinaryString name="' .. bp .. '">' .. c .. '</BinaryString>') end
                end
            end
        end
    end

    if cls == "Terrain" and not seen.SmoothGrid then
        local sg = readProp(inst, "SmoothGrid")
        if sg and type(sg) == "string" then
            local oks, b = pcall(b64, sg)
            if oks and b then table.insert(buf, pad .. '    <BinaryString name="SmoothGrid">' .. b .. '</BinaryString>') end
        end
    end

    table.insert(buf, pad .. '  </Properties>')

    local okc, kids = pcall(function() return inst:GetChildren() end)
    if okc and kids then for _, c in ipairs(kids) do if refs[c] then emitInst(buf, c, d + 1, opts, decompileCache, refs) end end end
    table.insert(buf, pad .. '</Item>')
end

local function resolveDecompile()
    if type(decompile) == "function" then return decompile end
    if type(decompile_script) == "function" then return decompile_script end
    local g = (getgenv and getgenv()) or _G
    if g then
        for _, v in pairs(g) do
            if type(v) == "table" then
                if type(v.decompile) == "function" then return v.decompile end
                if type(v.decompile_script) == "function" then return v.decompile_script end
            end
        end
    end
    return nil
end

local function resolveBytecode()
    if type(getscriptbytecode) == "function" then return getscriptbytecode end
    local g = (getgenv and getgenv()) or _G
    if g then
        for _, v in pairs(g) do
            if type(v) == "table" and type(v.getscriptbytecode) == "function" then
                return v.getscriptbytecode
            end
        end
    end
    return nil
end

local function placeName()
    local pid = game.PlaceId
    local name
    local ok, n = pcall(function() return game.Name end)
    if ok and n and n ~= "" and n ~= "Game" and n:lower() ~= "ugc" then name = n end
    if not name then
        local okp, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(pid) end)
        if okp and info and info.Name and info.Name ~= "" then name = info.Name end
    end
    if not name or name == "" then name = "Place_" .. tostring(pid) end
    name = name:gsub("[^%w_%-%s]", ""):gsub("%s+", "_"):gsub("_+", "_")
    if #name > 80 then name = name:sub(1, 80) end
    if name == "" then name = "Place_" .. tostring(pid) end
    return name
end

local function mergeOptions(userOpts)
    local merged = {}
    for k, v in pairs(Fish.Options) do merged[k] = v end
    if userOpts then for k, v in pairs(userOpts) do merged[k] = v end end
    merged._decompileFn = Fish._decompileFn
    merged._bytecodeFn = Fish._bytecodeFn
    return merged
end

local _pendingRestore = {}

local function moveBackpackToStarter()
    _pendingRestore = {}
    local lp = Players.LocalPlayer
    if not lp then return end
    local bp = lp:FindFirstChildOfClass("Backpack")
    if not bp then return end
    local sp = game:GetService("StarterPack")
    if not sp then return end
    local okL, tools = pcall(function() return bp:GetChildren() end)
    if not okL or not tools then return end
    for _, tool in ipairs(tools) do
        if tool:IsA("Tool") then
            if not sp:FindFirstChild(tool.Name) then
                local origParent = tool.Parent
                local okMove = pcall(function() tool.Parent = sp end)
                if okMove then
                    table.insert(_pendingRestore, {tool = tool, orig = origParent})
                end
            end
        end
    end
end

local function restoreBackpack()
    for i = #_pendingRestore, 1, -1 do
        local entry = _pendingRestore[i]
        pcall(function()
            if entry.tool and entry.tool.Parent == game:GetService("StarterPack") then
                entry.tool.Parent = entry.orig
            end
        end)
    end
    _pendingRestore = {}
end

function Fish.FetchClasses(cacheFile)
    cacheFile = cacheFile or "FishilizerAPIDump.json"
    if IO.isfile and IO.readfile then
        local okI, exists = pcall(IO.isfile, cacheFile)
        if okI and exists then
            local okR, cached = pcall(IO.readfile, cacheFile)
            if okR and cached and #cached > 100 then
                local okD, data = pcall(HttpService.JSONDecode, HttpService, cached)
                if okD and data then
                    Fish.ApplyAPIDump(data)
                    log("Loaded cached API dump")
                    return data
                end
            end
        end
    end
    local okG, raw = pcall(function() return game:HttpGet(Fish.Options.APIDumpURL) end)
    if not okG or not raw then log("Failed to fetch API dump") return nil end
    if IO.writefile then pcall(IO.writefile, cacheFile, raw) end
    local okD, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not okD or not data then log("Failed to parse API dump") return nil end
    Fish.ApplyAPIDump(data)
    return data
end

function Fish.ApplyAPIDump(data)
    if type(data) ~= "table" or type(data.Classes) ~= "table" then return end
    local added = 0
    for _, class in ipairs(data.Classes) do
        local className = class.Name
        if className and not INSTANCE_SPECIFIC[className] then
            local props = {}
            if type(class.Members) == "table" then
                for _, member in ipairs(class.Members) do
                    if member.MemberType == "Property" and member.Name and not shouldSkipProp(member.Name) then
                        table.insert(props, member.Name)
                    end
                end
            end
            if class.Superclass and INSTANCE_SPECIFIC[class.Superclass] then
                for _, p in ipairs(INSTANCE_SPECIFIC[class.Superclass]) do table.insert(props, p) end
            end
            if #props > 0 then
                INSTANCE_SPECIFIC[className] = props
                added = added + 1
            end
        end
    end
    log("API dump: added " .. added .. " classes")
end

function Fish.Init()
    Fish._decompileFn = resolveDecompile()
    Fish._bytecodeFn = resolveBytecode()
    if Fish.Options.FetchDocs then pcall(Fish.FetchClasses) end
    return Fish
end

function Fish.Save(instance, name, userOpts)
    local opts = mergeOptions(userOpts)
    IO.writefile = IO.writefile or resolveIO("writefile")
    IO.makefolder = IO.makefolder or resolveIO("makefolder")
    IO.isfolder = IO.isfolder or resolveIO("isfolder")
    IO.isfile = IO.isfile or resolveIO("isfile")
    IO.delfile = IO.delfile or resolveIO("delfile")
    IO.getproperties = IO.getproperties or resolveIO("getproperties")

    if not opts.Callback and not opts.Clipboard and not IO.writefile then
        log("writefile unavailable")
        notify("Fishilizer: FAILED", "Executor missing writefile", 10)
        return nil
    end

    _progressUI = buildProgressUI()
    showTextStage()

    if opts.KillAllScripts then
        pcall(function()
            for _, s in ipairs(game:GetDescendants()) do
                if s:IsA("Script") or s:IsA("LocalScript") or s:IsA("ModuleScript") then
                    pcall(function() s.Disabled = true end)
                end
            end
        end)
    end

    if opts.Notify then notify("Fishilizer v" .. Fish.VERSION, "Serializing...", 4) end
    log("Serializing...")

    local t0 = tick()
    Walker.refs = {}
    Walker.refCount = 0
    Walker.totalInst = 0
    _progressEmitted = 0
    _progressTotal = 0

    local charRefs = {}
    local coreRefs = {}
    local refs = {}
    Walker.refs = refs

    if opts.RemovePlayerCharacters then
        local okp, plist = pcall(function() return Players:GetPlayers() end)
        if okp and plist then
            for _, p in ipairs(plist) do
                local okc, char = pcall(function() return p.Character end)
                if okc and char then
                    charRefs[char] = true
                    local okd, desc = pcall(function() return char:GetDescendants() end)
                    if okd and desc then for _, d in ipairs(desc) do charRefs[d] = true end end
                end
            end
        end
    end

    local roots = {}
    if type(instance) == "table" then
        for _, r in ipairs(instance) do if typeof(r) == "Instance" then table.insert(roots, r) end end
    elseif typeof(instance) == "Instance" then
        table.insert(roots, instance)
    end

    if #roots == 0 then
        destroyProgressUI()
        notify("Fishilizer: FAILED", "No valid root instance", 10)
        return nil
    end

    local didMoveBackpack = false
    if opts.IncludeBackpack then
        local okM = pcall(moveBackpackToStarter)
        didMoveBackpack = okM
        if okM and #_pendingRestore > 0 then
            log("Moved " .. #_pendingRestore .. " backpack tool(s) into StarterPack for save")
        end
    end

    local okSave, result = pcall(function()
        for _, root in ipairs(roots) do
            if root == game then
                local ok0, kids0 = pcall(function() return game:GetChildren() end)
                if ok0 and kids0 then
                    for _, svc in ipairs(kids0) do
                        if keepInst(svc, opts, charRefs, coreRefs) then walkRef(svc, 1, opts, refs, charRefs, coreRefs) end
                    end
                end
            else
                if keepInst(root, opts, charRefs, coreRefs) then walkRef(root, 1, opts, refs, charRefs, coreRefs) end
            end
        end

        log("Walked " .. Walker.refCount .. " instances")

        _progressTotal = Walker.refCount
        showProgressStage()

        local buf = {}
        local decompileCache = {}

        if opts.Decompile and Fish._decompileFn then
            for inst in pairs(refs) do
                local cls = inst.ClassName
                if cls == "Script" or cls == "LocalScript" or cls == "ModuleScript" then
                    local ok, res = pcall(Fish._decompileFn, inst)
                    if ok and type(res) == "string" and res ~= "" then decompileCache[inst] = res end
                end
            end
        end

        table.insert(buf, '<?xml version="1.0" encoding="utf-8"?>')
        table.insert(buf, '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">')

        for _, root in ipairs(roots) do
            if root == game then
                local ok0, kids0 = pcall(function() return game:GetChildren() end)
                if ok0 and kids0 then
                    for _, svc in ipairs(kids0) do
                        if refs[svc] then emitInst(buf, svc, 1, opts, decompileCache, refs) end
                    end
                end
            else
                if refs[root] then emitInst(buf, root, 1, opts, decompileCache, refs) end
            end
        end

        table.insert(buf, '</roblox>')

        if opts.ReadMe then
            table.insert(buf, #buf, '<!-- Serialized by Fishilizer v' .. Fish.VERSION .. ' -->')
        end

        updateBar(1)

        local xml = table.concat(buf, "\n")
        local finalName = name or placeName()
        local fname = finalName .. ".rbxlx"
        local elapsed = tick() - t0

        log("XML: " .. #xml .. " bytes, " .. Walker.totalInst .. " items emitted in " .. string.format("%.2fs", elapsed))

        if opts.Callback and type(opts.Callback) == "function" then
            pcall(opts.Callback, xml)
            if opts.Notify then notify("Fishilizer: DONE", tostring(Walker.totalInst) .. " inst | " .. math.floor(#xml / 1024) .. "kb", 12) end
            return xml
        end

        if opts.Clipboard then
            pcall(function() if IO.setclipboard then IO.setclipboard(xml) end end)
            if opts.Notify then notify("Fishilizer", "Copied to clipboard", 6) end
            return xml
        end

        local paths = {}
        if opts.FilePath then table.insert(paths, opts.FilePath) end
        table.insert(paths, opts.OUT .. "/" .. fname)
        table.insert(paths, fname)

        if IO.makefolder and IO.isfolder then
            local okF, exists = pcall(IO.isfolder, opts.OUT)
            if not okF or not exists then pcall(IO.makefolder, opts.OUT) end
        end

        local wrote = false
        for _, path in ipairs(paths) do
            if IO.isfile and IO.delfile then
                local okI, exists = pcall(IO.isfile, path)
                if okI and exists and not opts.AvoidFileOverwrite then pcall(IO.delfile, path) end
            end
            local ok, err = pcall(IO.writefile, path, xml)
            if ok then
                log("Wrote: " .. path .. " (" .. #xml .. " bytes)")
                wrote = true
                break
            else
                log("Write fail " .. path .. ": " .. tostring(err))
            end
        end

        if not wrote then
            notify("Fishilizer: FAILED", "writefile failed", 10)
            return xml
        end

        if opts.Notify then
            notify("Fishilizer: DONE in " .. string.format("%.1fs", elapsed), fname .. "\n" .. Walker.totalInst .. " inst | " .. math.floor(#xml / 1024) .. "kb", 12)
        end

        return xml
    end)

    if didMoveBackpack then
        restoreBackpack()
        log("Restored backpack tools")
    end

    destroyProgressUI()

    if not okSave then
        log("Save error: " .. tostring(result))
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Fishilizer: FAILED", Text = tostring(result):sub(1, 100), Duration = 12,
            })
        end)
        return nil
    end

    return result
end

function Fish.SaveGame(name, userOpts)
    return Fish.Save(game, name, userOpts)
end

function Fish.SaveInstance(instance, name, userOpts)
    local merged = userOpts or {}
    merged.Mode = merged.Mode or "full"
    return Fish.Save(instance, name, merged)
end

function Fish.SaveScripts(instance, name, userOpts)
    local merged = userOpts or {}
    merged.Mode = "scripts"
    merged.Decompile = true
    return Fish.Save(instance, name, merged)
end

function Fish.SaveModels(instance, name, userOpts)
    local merged = userOpts or {}
    merged.Mode = "models"
    merged.Decompile = false
    return Fish.Save(instance, name, merged)
end

local genv = (getgenv and getgenv()) or _G or _ENV
local SESSION_KEY = "__FISHILIZER_SESSION_" .. tostring(game.PlaceId)

if genv and type(genv.FISHILIZER_CONFIG) == "table" then
    for k, v in pairs(genv.FISHILIZER_CONFIG) do
        Fish.Options[k] = v
    end
end

if genv and not genv[SESSION_KEY] and not genv.FISHILIZER_NO_AUTORUN then
    local ok, err = pcall(function()
        Fish.Init()
        local result = Fish.Save(game)
        if result then genv[SESSION_KEY] = true end
    end)
    if not ok then
        log("Auto-run failed: " .. tostring(err))
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Fishilizer: FAILED", Text = tostring(err):sub(1, 100), Duration = 12,
            })
        end)
    end
end

return Fish