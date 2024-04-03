local Resources = SceneMachine.Resources;
local UI = SceneMachine.UI;
local Editor = SceneMachine.Editor;
UI.SplitButton = {};

--- @class SplitButton : Element
local SplitButton = UI.SplitButton;

SplitButton.__index = SplitButton;
setmetatable(SplitButton, UI.Element)

--- @enum SplitButton.State
UI.SplitButton.State = {
    Normal = 0,
    Highlight = 1,
    Pressed = 2
}

--- Builds the SplitButton UI element.
function SplitButton:Build()
    self.iconTextures = self.values[1] or {};
    self.texcoords = self.values[2] or {};
    self.splitaction = self.values[3];
    self.action = self.values[4];
    self.currentOption = 1;
    -- main SplitButton frame

    -- Create the splitButton using the UI.Button class.
    self.splitButton = UI.Button:New(self.x, self.y, self.w, self.h, self.parent, self.point, self.parentPoint, nil, self.iconTextures[1], self.texcoords[1]);
    self.frame = self.splitButton:GetFrame();

    -- Create a corner rectangle for visual effect.
    local corner = UI.Rectangle:New(-2, 2, 5, 5, self.frame, "BOTTOMRIGHT", "BOTTOMRIGHT", 1, 1, 1, 1);
    corner:SetFrameLevel(self.frame:GetFrameLevel() + 2);
    corner:SetVertexOffset(1, 5, 0);

    -- Create the popup rectangle for displaying options.
    self.popup = UI.Rectangle:New(self.x, 0, self.w, self.h * #self.iconTextures, self.parent:GetParent(), "TOPLEFT", "BOTTOMLEFT", 0, 0, 0, 1);
    self.popup:SetFrameLevel(self.frame:GetFrameLevel() + 100);
    self.popup:Hide();

    -- Create the option buttons within the popup rectangle.
    self.options = {};
    for b = 1, #self.iconTextures, 1 do
        self.options[b] = UI.Button:New(0, -(b - 1) * self.h, self.w, self.h, self.popup:GetFrame(), "TOPLEFT", "TOPLEFT", nil, self.iconTextures[b], self.texcoords[b]);
    end

    -- Set the OnMouseDown script for the splitButton.
    self.splitButton:SetScript("OnMouseDown", function()
        -- Create a hold timer to delay showing the popup.
        self.holdTimer = C_Timer.NewTimer(0.5, function()
            self.popup:ClearAllPoints();
            self.popup:SetPoint("TOPLEFT", self.parent:GetParent(), "BOTTOMLEFT", self.x, 0);
            self.popup:Show();
        end);
    end);

    -- Set the OnMouseUp script for the splitButton.
    self.splitButton:SetScript("OnMouseUp", function()
        if (self.holdTimer) then
            self.holdTimer:Cancel();
            for b = 1, #self.iconTextures, 1 do
                if (MouseIsOver(self.options[b]:GetFrame())) then
                    self.splitButton.icon:SetTexCoords(self.texcoords[b]);
                    self.currentOption = b;
                    self.popup:Hide();
                    self.splitaction(self.currentOption);
                    return;
                end
            end
        end
        
        self.popup:Hide();
        self.action(self.currentOption);
    end);

    -- Set the OnEnter script for the splitButton.
    self.splitButton:SetScript("OnEnter", function ()
        if (self.tooltip) then
            -- Create a hold timer to delay showing the tooltip.
            self.holdTimer = C_Timer.NewTimer(Editor.ui.tooltipDelay, function()
                Editor.ui:ShowTooltip(self.w / 2, 0, self.splitButton:GetFrame(), self.tooltip, self.tooltipDetailed);
            end);
        end
    end);

    -- Set the OnLeave script for the splitButton.
    self.splitButton:SetScript("OnLeave", function ()
        if (self.holdTimer) then
            self.holdTimer:Cancel();
            Editor.ui:HideTooltip();
        end
    end);
end

--- Sets the color of a specific state of the SplitButton.
--- @param state SplitButton.State The state of the SplitButton.
--- @param R number The red component of the color.
--- @param G number The green component of the color.
--- @param B number The blue component of the color.
--- @param A number The alpha component of the color.
function SplitButton:SetColor(state, R, G, B, A)
    if (state == UI.SplitButton.State.Normal) then
        self.ntex:SetColorTexture(R, G, B, A);
    elseif (state == UI.SplitButton.State.Highlight) then
        self.htex:SetColorTexture(R, G, B, A);
    elseif (state == UI.SplitButton.State.Pressed) then
        self.ptex:SetColorTexture(R, G, B, A);
    end
end

--- Sets the texture coordinates for the SplitButton.
--- @param texcoords table The texture coordinates to set.
function SplitButton:SetTexCoords(texcoords)
    self.texcoords = texcoords;
    self.splitButton.icon:SetTexCoords(self.texcoords);
end

--- Gets the text of the SplitButton.
--- @return string: The text of the SplitButton.
function SplitButton:GetText()
    return self.splitButton.text;
end

--- Sets the script handler and function for the SplitButton.
--- @param handler string The name of the script handler.
--- @param func function The function to be executed when the script handler is triggered.
function SplitButton:SetScript(handler, func)
    self.splitButton:SetScript(handler, func);
end

--- Hooks a script handler function to the SplitButton frame.
--- @param handler string The name of the script handler.
--- @param func function The function to be executed when the event occurs.
function SplitButton:HookScript(handler, func)
    self.splitButton:HookScript(handler, func);
end

--- Enables or disables mouse interaction for the SplitButton.
---@param on boolean Whether to enable or disable mouse interaction.
function SplitButton:EnableMouse(on)
    self.splitButton:EnableMouse(on);
end

SplitButton.__tostring = function(self)
	return string.format("SplitButton( %.3f, %.3f, %.3f, %.3f )", self.x, self.y, self.w, self.h);
end