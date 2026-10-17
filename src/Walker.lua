-- Walker.lua
-- Instance walking, reference generation and filtering.

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
}

local CONTENT_PROP_EXACT = { MeshContent=true,ImageContent=true,SoundContent=true }
local REAL_CONTENT_PROPS = { Texture=true,TextureId=true,TextureID=true,Image=true,MeshId=true,SoundId=true }

local CORE_SCRIPT_NAMES = { PlayerModule=true,CameraModule=true,ControlModule=true,Common=true,Utils=true }
local CHARACTER_CLASSES = { Humanoid=true,Head=true,Torso=true,HumanoidRootPart=true }

local INSTANCE_SPECIFIC = { -- trimmed for readability
    Tool={"TextureId","ToolTip","CanBeDropped"},
    Part={"Shape","Size","CFrame"},
    Script={"Source","Disabled","RunContext"},
}

local Walker = { refs = {}, refCount = 0, totalInst = 0 }

local function shouldSkipProp(name)
    if SKIP_PROP[name] then return true end
    if CONTENT_PROP_EXACT[name] then return true end
    return false
end

local function isRealContent(name) return REAL_CONTENT_PROPS[name] == true end

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

Fish.Walker = Walker
Fish.walkRef = walkRef
Fish.keepInst = keepInst

return Fish
