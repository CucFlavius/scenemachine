local Camera = SceneMachine.Camera;
local Renderer = SceneMachine.Renderer;
local CameraController = SceneMachine.CameraController;
local GM = SceneMachine.GizmoManager
local Input = SceneMachine.Input;
local Editor = SceneMachine.Editor;
local AM = SceneMachine.Editor.AnimationManager;
local SH = Editor.SceneHierarchy;
local Resources = SceneMachine.Resources;
local Network = SceneMachine.Network;

local TimeSinceLastUpdate = 0;
SceneMachine.time = 0;

------------------------
--	 	  Start  	  --
------------------------
function SceneMachine.Start()

	SceneMachine.Libs = {};
	SceneMachine.Libs.LibSerialize = LibStub("LibSerialize", true);
	SceneMachine.Libs.LibDeflate = LibStub("LibDeflate", true);

	Resources.Initialize("Interface\\AddOns\\scenemachine\\res");
    Editor.Initialize();
    CameraController.Initialize();
	GM.Create();
	Network.Initialize();
	if (Debug) then Debug.Init(); end
end

--- Using this function to start the editor after the player has logged in.
--- This is in order to get a correct UIParent scale, which is usually not available in the ADDON_LOADED event.
function SceneMachine.LateStart()
	-- open if it was left open
	if (scenemachine_settings.editor_is_open) then
		Editor.Show();
	end
end

function SceneMachine.End()
	Editor.PreprocessSavedVars();
end

SceneMachine.prefix = "sceneMachine123";

local f = CreateFrame("Frame");

local function onevent(self, event, ...)
	local addonName = ...;
    if(event == "ADDON_LOADED" and addonName == "scenemachine") then
        f:UnregisterEvent("ADDON_LOADED");
		C_ChatInfo.RegisterAddonMessagePrefix(SceneMachine.prefix);
		SceneMachine.Start();
	elseif (event == "PLAYER_LOGIN") then
		f:UnregisterEvent("PLAYER_LOGIN");
		SceneMachine.LateStart();
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
f:RegisterEvent("PLAYER_LOGIN");
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
		Editor.Update(SceneMachine.deltaTime);
		Camera.Update();
		CameraController.Update(SceneMachine.deltaTime);
		Input.Update();
		GM.Update();
		Renderer.Update();
		AM.Update(SceneMachine.deltaTime);
		SH.Update(SceneMachine.deltaTime);
		Network.Update(SceneMachine.deltaTime);
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