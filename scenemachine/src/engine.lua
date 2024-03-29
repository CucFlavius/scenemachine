local Camera = SceneMachine.Camera;
local Renderer = SceneMachine.Renderer;
local CameraController = SceneMachine.CameraController;
local Gizmos = SceneMachine.Gizmos;
local Input = SceneMachine.Input;
local Editor = SceneMachine.Editor;
local AM = SceneMachine.Editor.AnimationManager;
local SH = Editor.SceneHierarchy;

print("Running SceneMachine")

local TimeSinceLastUpdate = 0;
SceneMachine.time = 0;

------------------------
--	 	  Start  	  --
------------------------
function SceneMachine.Start()

	SceneMachine.Libs = {};
	SceneMachine.Libs.LibSerialize = LibStub("LibSerialize", true);
	SceneMachine.Libs.LibDeflate = LibStub("LibDeflate", true);

	SceneMachine.Resources.Initialize("Interface\\AddOns\\scenemachine\\res");
    SceneMachine.Editor.Initialize();
    CameraController.Initialize();
	Gizmos.Create();
	SceneMachine.Network.Initialize();
	if (Debug) then Debug.Init(); end
end

function SceneMachine.End()
	SceneMachine.Editor.PreprocessSavedVars();
end

SceneMachine.prefix = "sceneMachine123";

local f = CreateFrame("Frame");

local function onevent(self, event, ...)
	local addonName = ...;
    if(event == "ADDON_LOADED" and addonName == "scenemachine") then
        f:UnregisterEvent("ADDON_LOADED");
		C_ChatInfo.RegisterAddonMessagePrefix(SceneMachine.prefix);
		SceneMachine.Start();
	elseif (event == "ADDONS_UNLOADING") then
		f:UnregisterEvent("ADDONS_UNLOADING");
		SceneMachine.End();
	elseif(event == "CHAT_MSG_ADDON") then
		local prefix = ...;
		if (prefix == SceneMachine.prefix) then
			SceneMachine.Network.MessageReceive(...);
		end
	end
end

f:RegisterEvent("ADDON_LOADED");
f:RegisterEvent("ADDONS_UNLOADING");
f:RegisterEvent("CHAT_MSG_ADDON");
f:SetScript("OnEvent", onevent);

------------------------
-------- UPDATE --------
------------------------
local function SG_UpdateLoop ()
    Renderer.active = true;
	
	if SceneMachine.preRenderUpdateAction ~= nil then
		SceneMachine.preRenderUpdateAction();
	end

	if (Editor.isOpen) then
		Editor.Update();
		Camera.Update();
		CameraController.Update(SceneMachine.deltaTime);
		Input.Update();
		Gizmos.Update();
		Renderer.Update();
		AM.Update(SceneMachine.deltaTime);
		SH.Update(SceneMachine.deltaTime);
		SceneMachine.Network.Update(SceneMachine.deltaTime);
		if (Debug) then Debug.FlushLinePool(); end
	end
end

local function SG_OnUpdate(self, elapsed)
	TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed;
	SceneMachine.deltaTime = elapsed;
	SceneMachine.time = SceneMachine.time + SceneMachine.deltaTime;
	SG_UpdateLoop();
end

local SG_UpdateFrame = CreateFrame("frame");
SG_UpdateFrame:SetScript("OnUpdate", SG_OnUpdate);

function SceneMachine.SetPreRenderUpdate(action)
	SceneMachine.preRenderUpdateAction = action;
end