SceneMachine.Input = SceneMachine.Input or {}
SceneMachine.CameraController = SceneMachine.CameraController or {}
SceneMachine.Gizmos = SceneMachine.Gizmos or {};
local Input = SceneMachine.Input;
local CC = SceneMachine.CameraController;
local Renderer = SceneMachine.Renderer;
local Gizmos = SceneMachine.Gizmos;

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
    Input.mouseInputFrame = CreateFrame("Frame", "Input.mouseInputFrame", Renderer.projectionFrame);
	Input.mouseInputFrame:SetPoint("CENTER", Renderer.projectionFrame, "CENTER", 0, 0);
	Input.mouseInputFrame:SetWidth(SceneMachine.WINDOW_WIDTH);
	Input.mouseInputFrame:SetHeight(SceneMachine.WINDOW_HEIGHT);
	Input.mouseInputFrame:EnableMouse(true)
	Input.mouseInputFrame:RegisterForDrag("RightButton", "LeftButton")
	Input.mouseInputFrame:SetScript("OnDragStart", Input.OnDragStart)
	Input.mouseInputFrame:SetScript("OnDragStop", Input.OnDragStop)
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