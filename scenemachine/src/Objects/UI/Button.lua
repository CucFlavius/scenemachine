local Resources = SceneMachine.Resources;
local UI = SceneMachine.UI;
local Editor = SceneMachine.Editor;
UI.Button = {};

--- @class Button : Element
local Button = UI.Button;

Button.__index = Button;
setmetatable(Button, UI.Element)

--- @enum Button.State
Button.State = {
    Normal = 0,
    Highlight = 1,
    Pressed = 2
}

function Button:GetFrameType()
    return "Button";
end

--- Builds the button by creating and configuring its textures, icon, and text.
function Button:Build()
    self.text = self.values[1] or nil;
    self.iconTexture = self.values[2] or nil;
    self.texcoords = self.values[3] or {0, 1, 0, 1};

    -- normal texture
    self.ntex = self.frame:CreateTexture();
    self.ntex:SetColorTexture(0.1757, 0.1757, 0.1875, 1);
    self.ntex:SetAllPoints();
    self.frame:SetNormalTexture(self.ntex);
    
    -- highlight texture
    self.htex = self.frame:CreateTexture();
    self.htex:SetColorTexture(0.242, 0.242, 0.25, 1);
    self.htex:SetAllPoints();
    self.frame:SetHighlightTexture(self.htex);

    -- pressed texture
    self.ptex = self.frame:CreateTexture();
    self.ptex:SetColorTexture(0, 0.4765, 0.7968, 1);
    self.ptex:SetAllPoints();
    self.frame:SetPushedTexture(self.ptex);

    -- icon
    if (self.iconTexture) then
        local iconSize = self:GetWidth() - 4;    -- icon padding 4
        self.icon = UI.ImageBox:New(0, 0, iconSize, iconSize, self.frame, "CENTER", "CENTER", self.iconTexture, self.texcoords);
    end

    -- text
    if (self.text) then
        self.textField = self.frame:CreateFontString("Zee.WindowAPI.Button.textField");
        self.textField:SetFont(Resources.defaultFont, 9, "NORMAL");
        self.textField:SetAllPoints(self.frame);
        self.textField:SetText(self.text);
    end

    -- tooltip
    self.frame:SetScript("OnEnter", function ()
        if (self.tooltip) then
            self.holdTimer = C_Timer.NewTimer(Editor.ui.tooltipDelay, function()
                Editor.ui:ShowTooltip(self:GetWidth() / 2, 0, self.frame, self.tooltip, self.tooltipDetailed);
            end);
        end
    end);
    self.frame:SetScript("OnLeave", function ()
        if (self.holdTimer) then
            self.holdTimer:Cancel();
            Editor.ui:HideTooltip();
        end
    end);
end

--- Sets the text of the button.
--- @param text string The text to set.
function Button:SetText(text)
        self.text = text;

        if (not self.textField) then
		self.textField = self.frame:CreateFontString("Zee.WindowAPI.Button.textField");
		self.textField:SetFont(Resources.defaultFont, 9, "NORMAL");
		self.textField:SetAllPoints(self.frame);
        end
        
        self.textField:SetText(text);
end

--- Sets the font and size for the button's text field.
--- @param font string The font to set.
--- @param size number The size of the font.
function Button:SetFont(font, size)
    self.textField:SetFont(font, size, "NORMAL");
end

--- Sets the color of the button based on its state.
---@param state Button.State The state of the button (Normal, Highlight, or Pressed).
---@param R number The red component of the color.
---@param G number The green component of the color.
---@param B number The blue component of the color.
---@param A number The alpha component of the color.
function Button:SetColor(state, R, G, B, A)
    if (state == UI.Button.State.Normal) then
        self.ntex:SetColorTexture(R, G, B, A);
    elseif (state == UI.Button.State.Highlight) then
        self.htex:SetColorTexture(R, G, B, A);
    elseif (state == UI.Button.State.Pressed) then
        self.ptex:SetColorTexture(R, G, B, A);
    end
end

--- Sets the texture coordinates for the button.
--- @param texcoords table The table containing the texture coordinates.
function Button:SetTexCoords(texcoords)
    self.texcoords = texcoords;
    self.icon:SetTexCoords(self.texcoords);
end

--- Gets the text of the button.
--- @return string: The text of the button.
function Button:GetText()
    return self.text;
end

--- Sets the script handler and function for the button.
--- @param handler string The name of the script handler.
--- @param func function The function to be executed when the event occurs.
function Button:SetScript(handler, func)
    self.frame:SetScript(handler, func);
end

--- Hooks a script handler to the button frame.
--- @param handler string The name of the script handler to hook.
--- @param func function The function to be executed when the script handler is triggered.
function Button:HookScript(handler, func)
    self.frame:HookScript(handler, func);
end

--- Sets the horizontal justification of the button's text field.
--- @param justifyH string The horizontal justification value ("LEFT", "CENTER", or "RIGHT").
function Button:SetJustifyH(justifyH)
    self.textField:SetJustifyH(justifyH);
end

--- Enables or disables mouse interaction for the button.
--- @param on boolean Whether to enable or disable mouse interaction.
function Button:EnableMouse(on)
    self.frame:EnableMouse(on);
end

Button.__tostring = function(self)
	return string.format("Button( %.3f, %.3f, %.3f, %.3f )", self.x, self.y, self.w, self.h);
end