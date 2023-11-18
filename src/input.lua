local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;
local PM = Editor.ProjectManager;
local Input = SceneMachine.Input;
local CC = SceneMachine.CameraController;
local Renderer = SceneMachine.Renderer;
local Gizmos = SceneMachine.Gizmos;
local Camera = SceneMachine.Camera;
local MousePick = Editor.MousePick;

Input.Keys = {}

Input.PreviousMouseState =
{
    X = 0,
    Y = 0,
    dragStartX = 0,
    dragStartY = 0,
    LMB = false,
    MMB = false,
    RMB = false,
    isDragging = false,
};

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
end

function Input.Update()
    local LMB = IsMouseButtonDown("LeftButton");
    local MMB = IsMouseButtonDown("MiddleButton");
    local RMB = IsMouseButtonDown("RightButton");

    local x, y = GetCursorPosition();

    -- need to verify that the click was done in the editor render frame
    -- otherwise any ui click will deselect whatever object is selected
    local frameXMin = Renderer.projectionFrame:GetLeft();
    local frameYMin = Renderer.projectionFrame:GetBottom();
    local frameXMax = Renderer.projectionFrame:GetRight();
    local frameYMax = Renderer.projectionFrame:GetTop();
    if (x < frameXMin or x > frameXMax or y < frameYMin or y > frameYMax) then
        return;
    end

    local relativeX, relativeY = x - frameXMin, y - frameYMin;

    if (Input.PreviousMouseState.LMB ~= LMB) then
        if (LMB == true) then
            -- LMB DOWN
            Input.PreviousMouseState.dragStartX = x;
            Input.PreviousMouseState.dragStartY = y;
        else
            -- LMB UP
            Input.PreviousMouseState.isDragging = false;
            Input.OnDragStop();
        end
    end

    if (Input.PreviousMouseState.RMB ~= RMB) then
        if (RMB == true) then
            -- RMB DOWN
            Input.PreviousMouseState.dragStartX = x;
            Input.PreviousMouseState.dragStartY = y;
        else
            -- RMB UP
            Input.PreviousMouseState.isDragging = false;
            Input.OnDragStop();
        end
    end

    if (Input.PreviousMouseState.MMB ~= MMB) then
        if (MMB == true) then
            -- MMB DOWN
            Input.PreviousMouseState.dragStartX = x;
            Input.PreviousMouseState.dragStartY = y;
        else
            -- MMB UP
            Input.PreviousMouseState.isDragging = false;
            Input.OnDragStop();
        end
    end

    local dragDiffMin = 3;  -- how many pixels does the mouse need to move to register as a drag
    -- determine if draging
    if (Input.PreviousMouseState.isDragging == false) then
        if (LMB or RMB or MMB) then
            local dragDistX = math.abs(x - Input.PreviousMouseState.dragStartX);
            local dragDistY = math.abs(x - Input.PreviousMouseState.dragStartX);
            if (dragDistX > dragDiffMin or dragDistY > dragDiffMin) then
                -- started dragging
                Input.PreviousMouseState.isDragging = true;
                Input.OnDragStart(LMB, RMB, MMB);
            else
                -- regular click
                Input.OnClick(LMB, RMB, MMB, relativeX, relativeY);
            end
        end
    end

    -- save to previous state --
    Input.PreviousMouseState.LMB = LMB;
    Input.PreviousMouseState.RMB = RMB;
    Input.PreviousMouseState.MMB = MMB;

    Input.mouseX = relativeX
    Input.mouseY = relativeY;
end

function Input.OnDragStart(LMB, RMB, MMB)
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

function Input.OnClick(LMB, RMB, MMB, x, y)
    if (LMB) then
        -- mouse pick --
        if not Gizmos.isHighlighted then
            MousePick.Pick(x, y);
        end
    elseif (RMB) then
        -- open RMB context menu --
    elseif (MMB) then
        -- mouse pan maybe --
    end
end