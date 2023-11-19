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

Input.mouseState =
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
                if Input.Keys[key].OnKeyDown ~= nil then
				    Input.Keys[key].OnKeyDown();
                end
                self:SetPropagateKeyboardInput(false);
			end
        end);
		Input.KeyboardListener:SetScript("OnKeyUp", function(self, key)
			if Input.Keys[key] ~= nil then
                if Input.Keys[key].OnKeyUp ~= nil then
				    Input.Keys[key].OnKeyUp();
                end
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

    -- MOUSE UP --
    -- mouse up state needs to be handled outside of the renderer frame too
    if (Input.mouseState.LMB ~= LMB) then
        if (LMB == false) then
            -- LMB UP
            Input.mouseState.isDragging = false;
            Input.OnDragStop();
        end
    end

    if (Input.mouseState.RMB ~= RMB) then
        if (RMB == false) then
            -- RMB UP
            Input.mouseState.isDragging = false;
            Input.OnDragStop();
        end
    end

    if (Input.mouseState.MMB ~= MMB) then
        if (MMB == false) then
            -- MMB UP
            Input.mouseState.isDragging = false;
            Input.OnDragStop();
        end
    end

    -- MOUSE DOWN --
    -- filter mouse down to only in renderer frame
    if (x < frameXMin or x > frameXMax or y < frameYMin or y > frameYMax) then
        return;
    end

    local relativeX, relativeY = x - frameXMin, y - frameYMin;

    if (Input.mouseState.LMB ~= LMB) then
        if (LMB == true) then
            -- LMB DOWN
            Input.mouseState.dragStartX = x;
            Input.mouseState.dragStartY = y;
        end
    end

    if (Input.mouseState.RMB ~= RMB) then
        if (RMB == true) then
            -- RMB DOWN
            Input.mouseState.dragStartX = x;
            Input.mouseState.dragStartY = y;
        end
    end

    if (Input.mouseState.MMB ~= MMB) then
        if (MMB == true) then
            -- MMB DOWN
            Input.mouseState.dragStartX = x;
            Input.mouseState.dragStartY = y;
        end
    end

    local dragDiffMin = 3;  -- how many pixels does the mouse need to move to register as a drag
    -- determine if draging
    if (Input.mouseState.isDragging == false) then
        if (LMB or RMB or MMB) then
            local dragDistX = math.abs(x - Input.mouseState.dragStartX);
            local dragDistY = math.abs(x - Input.mouseState.dragStartX);
            if (dragDistX > dragDiffMin or dragDistY > dragDiffMin) then
                -- started dragging
                Input.mouseState.isDragging = true;
                Input.OnDragStart(LMB, RMB, MMB);
            else
                -- regular click
                Input.OnClick(LMB, RMB, MMB, relativeX, relativeY);
            end
        end
    end

    -- save to previous state --
    Input.mouseState.LMB = LMB;
    Input.mouseState.RMB = RMB;
    Input.mouseState.MMB = MMB;

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
        end
    end
end

function Input.OnDragStop()
    CC.OnRMBUp();
    if (Gizmos.isUsed) then
        Gizmos.isUsed = false;
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