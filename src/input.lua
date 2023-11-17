SceneMachine.Input = SceneMachine.Input or {}
SceneMachine.CameraController = SceneMachine.CameraController or {}
SceneMachine.Gizmos = SceneMachine.Gizmos or {};
local Editor = SceneMachine.Editor;
Editor.SceneManager = Editor.SceneManager or {};
local SM = Editor.SceneManager;
Editor.ProjectManager = Editor.ProjectManager or {};
local PM = Editor.ProjectManager;
local Input = SceneMachine.Input;
local CC = SceneMachine.CameraController;
local Renderer = SceneMachine.Renderer;
local Gizmos = SceneMachine.Gizmos;
local Camera = SceneMachine.Camera;
Editor.MousePick = Editor.MousePick or {};
local MousePick = Editor.MousePick;

Input.Keys = {}

function Input.AddKeyBind(key, downAction, upAction)
	Input.Keys[key] = {};
	Input.Keys[key].OnKeyUp = upAction;
	Input.Keys[key].OnKeyDown = downAction;
end

function Input.Initialize()
    Input.KeyboardListener = SceneMachine.Input.KeyboardListener or CreateFrame("Frame","SceneMachine.Input.KeyboardListener",UIParent);
    Input.KeyboardListener:EnableKeyboard(true);
    Input.KeyboardListener:SetPropagateKeyboardInput(true);
    Input.KeyboardListener:SetScript("OnKeyDown", function(self, key)
			if Input.Keys[key] ~= nil then
				Input.Keys[key].OnKeyDown();
                self:SetPropagateKeyboardInput(false);
			end
        end);
		Input.KeyboardListener:SetScript("OnKeyUp", function(self, key)
			if Input.Keys[key] ~= nil then
				Input.Keys[key].OnKeyUp();
                self:SetPropagateKeyboardInput(true);
            end
        end);

    Input.CreateMouseInputFrame();
end

function Input.CreateMouseInputFrame()
    local uiScale, x, y = UIParent:GetEffectiveScale();
    Input.mouseInputFrame = CreateFrame("Button", "Input.mouseInputFrame", SM.groupBG);
    --Input.mouseInputFrame:SetAllPoints(SM.groupBG);
	Input.mouseInputFrame:SetPoint("CENTER", SM.groupBG, "CENTER", 0, 0);
    local w, h = SM.groupBG:GetSize();
	Input.mouseInputFrame:SetWidth(w);
	Input.mouseInputFrame:SetHeight(h);
	Input.mouseInputFrame:EnableMouse(true);
	Input.mouseInputFrame:RegisterForDrag("RightButton", "LeftButton");
    Input.mouseInputFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	Input.mouseInputFrame:SetScript("OnDragStart", Input.OnDragStart);
	Input.mouseInputFrame:SetScript("OnDragStop", Input.OnDragStop);
    Input.mouseInputFrame:SetScript("OnClick", Input.OnClick);
end

function Input.OnDragStart(info)
    local LMB = IsMouseButtonDown("LeftButton");
    local RMB = IsMouseButtonDown("RightButton");

    if LMB and RMB then return end

    if RMB then
        CC.OnRMBDown();
    elseif LMB then
        if Gizmos.isHighlighted then
            local x, y = GetCursorPosition();
            Gizmos.OnLMBDown(x, y);
            return;
        end
    end
end

function Input.OnDragStop()
    CC.OnRMBUp();

    if (Gizmos.isUsed) then
        Gizmos.OnLMBUp();
        return;
    end
end

function Input.OnClick(self, button, down)
    if (button == "LeftButton") then
        -- mouse pick --
        MousePick.Pick();
    elseif (button == "RightButton") then
        -- open RMB context menu --
    end
end