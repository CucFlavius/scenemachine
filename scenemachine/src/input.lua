local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;
local PM = Editor.ProjectManager;
local Input = SceneMachine.Input;
local CC = SceneMachine.CameraController;
local Renderer = SceneMachine.Renderer;
local Gizmos = SceneMachine.Gizmos;
local Camera = SceneMachine.Camera;
local MousePick = Editor.MousePick;
local AssetBrowser = SceneMachine.Editor.AssetBrowser;

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
    isDraggingAssetFromUI = false,
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
                    if (Editor.isOpen) then
				        Input.Keys[key].OnKeyDown();
                        self:SetPropagateKeyboardInput(false);
                    end
                end
			end
        end);
		Input.KeyboardListener:SetScript("OnKeyUp", function(self, key)
			if Input.Keys[key] ~= nil then
                if Input.Keys[key].OnKeyUp ~= nil then
                    if (Editor.isOpen) then
				        Input.Keys[key].OnKeyUp();
                        self:SetPropagateKeyboardInput(true);
                    end
                end
            end
        end);
end

function Input.Update()
    if (Renderer.projectionFrame == nil) then return end

    local LMB = IsMouseButtonDown("LeftButton");
    local MMB = IsMouseButtonDown("MiddleButton");
    local RMB = IsMouseButtonDown("RightButton");
    
    local x, y = GetCursorPosition();
    
    -- need to verify that the click was done in the editor render frame
    -- otherwise any ui click will deselect whatever object is selected
    local scale = Renderer.projectionFrame:GetEffectiveScale();
    local frameXMin = Renderer.projectionFrame:GetLeft() * scale;
    local frameYMin = Renderer.projectionFrame:GetBottom() * scale;
    local frameXMax = Renderer.projectionFrame:GetRight() * scale;
    local frameYMax = Renderer.projectionFrame:GetTop() * scale;
    local relativeX, relativeY = x - frameXMin, y - frameYMin;

    Input.mouseX = relativeX
    Input.mouseXRaw = x;
    Input.mouseY = relativeY;
    Input.mouseYRaw = y;
    
    -- MOUSE UP --
    -- mouse up state needs to be handled outside of the renderer frame too
    if (Input.mouseState.LMB ~= LMB) then
        if (LMB == false) then
            -- LMB UP
            if (not Input.mouseState.isDragging) then
                Input.OnClickUp(true, false, false, relativeX, relativeY);
            end

            if (Input.mouseState.isDraggingAssetFromUI) then
                Input.mouseState.LMB = false;
                Input.mouseState.isDraggingAssetFromUI = false;
                
                -- Check if mouse is over asset browser, then delete object instead of placing it
                local frameXMin = AssetBrowser.tabs[1]:GetLeft();
                local frameYMin = AssetBrowser.tabs[1]:GetBottom();
                local frameXMax = AssetBrowser.tabs[1]:GetRight();
                local frameYMax = AssetBrowser.tabs[1]:GetTop();
                if (Input.mouseXRaw > frameXMin and Input.mouseXRaw < frameXMax and Input.mouseYRaw > frameYMin and Input.mouseYRaw < frameYMax) then
                    SM.DeleteObject(SM.selectedObject);
                end

            end

            Input.mouseState.isDragging = false;
            Input.OnDragStop();
        end
    end

    if (Input.mouseState.RMB ~= RMB) then
        if (RMB == false) then
            -- RMB UP
            if (not Input.mouseState.isDragging) then
                Input.OnClickUp(false, true, false, relativeX, relativeY);
            end

            Input.mouseState.isDragging = false;
            Input.OnDragStop();
        end
    end

    if (Input.mouseState.MMB ~= MMB) then
        if (MMB == false) then
            -- MMB UP
            if (not Input.mouseState.isDragging) then
                Input.OnClickUp(false, false, true, relativeX, relativeY);
            end

            Input.mouseState.isDragging = false;
            Input.OnDragStop();
        end
    end

    -- MOUSE DOWN --
    -- filter mouse down to only in renderer frame
    if (x < frameXMin or x > frameXMax or y < frameYMin or y > frameYMax) then
        return;
    end

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

    local dragDiffMin = 2;  -- how many pixels does the mouse need to move to register as a drag
    -- determine if draging
    if (Input.mouseState.isDragging == false) then
        if (LMB or RMB or MMB) then
            local dragDistX = math.abs(x - Input.mouseState.dragStartX);
            local dragDistY = math.abs(y - Input.mouseState.dragStartY);
            if (dragDistX > dragDiffMin or dragDistY > dragDiffMin) then
                -- started dragging
                Input.mouseState.isDragging = true;
                Input.OnDragStart(LMB, RMB, MMB);
            else
                -- regular click
                if (Input.mouseState.LMB ~= LMB or Input.mouseState.RMB ~= RMB or Input.mouseState.MMB ~= MMB) then
                    -- also filter the context menu out
                    if (not SceneMachine.mainWindow.menuIsOpen) then
                        Input.OnClick(LMB, RMB, MMB, relativeX, relativeY);
                    end
                end
            end
        end
    end

    -- save to previous state --
    Input.mouseState.LMB = LMB;
    Input.mouseState.RMB = RMB;
    Input.mouseState.MMB = MMB;
end

function Input.OnDragStart(LMB, RMB, MMB)
    if (not Editor.isOpen) then return end
    if LMB and RMB then return end

    if RMB then
        CC.OnRMBDown();
    elseif LMB then
        if (Gizmos.isHighlighted) then
            if (SceneMachine.Input.ShiftModifier) then
                -- clone object first
                SM.CloneObject(SM.selectedObject, true);
            end

            Gizmos.OnLMBDown(Input.mouseXRaw, Input.mouseYRaw);
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
    if (not Editor.isOpen) then return end
    if (LMB) then
        -- mouse pick --
        if (not Gizmos.isHighlighted) or (SM.selectedObject == nil) then
            MousePick.Pick(x, y);
        end
    elseif (RMB) then
    elseif (MMB) then
    end
end

function Input.OnClickUp(LMB, RMB, MMB, x, y)
    if (not Editor.isOpen) then return end
    if (LMB) then
    elseif (RMB) then
        -- open RMB context menu --
        local scale = SceneMachine.mainWindow:GetEffectiveScale();
        --local rx = Input.mouseX - SceneMachine.mainWindow:GetLeft() - Renderer.projectionFrame:GetLeft()) * scale;
        --local ry = Input.mouseY - SceneMachine.mainWindow:GetTop() * scale;
        print(Renderer.projectionFrame:GetBottom() .. " " .. SceneMachine.mainWindow:GetBottom())
        local rx = (Input.mouseX * Renderer.scale) + (Renderer.projectionFrame:GetLeft() - SceneMachine.mainWindow:GetLeft());--SceneMachine.mainWindow:GetWidth();
        local ry = (Input.mouseY * Renderer.scale) - 485;--SceneMachine.mainWindow:GetWidth();
        Editor.OpenContextMenu(rx, ry);
    elseif (MMB) then
    end
end