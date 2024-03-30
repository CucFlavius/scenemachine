SceneMachine.UI.Element = {};

--- @class Element
local Element = SceneMachine.UI.Element;

Element.__index = Element;

--- Shows the UI element
function Element:Show()
    self.visible = true;
    self.frame:Show();
end

--- Hides the UI element
function Element:Hide()
    self.visible = false;
    self.frame:Hide();
end

--- Checks if the element is visible.
--- @return boolean: True if the element is visible, false otherwise.
function Element:IsVisible()
    return self.visible;
end

--- Sets the frame level of the UI element.
--- @param level number The new frame level.
function Element:SetFrameLevel(level)
    self.frame:SetFrameLevel(level);
end

--- Retrieves the frame level of the element.
--- @return number: The frame level of the element.
function Element:GetFrameLevel()
    return self.frame:GetFrameLevel();
end

--- Sets the frame strata for the element.
--- @param strata string The frame strata to set.
function Element:SetFrameStrata(strata)
    self.frame:SetFrameStrata(strata);
end

--- Retrieves the frame strata of the element.
--- @return string: The frame strata of the element.
function Element:GetFrameStrata()
    return self.frame:GetFrameStrata();
end

--- Sets the parent frame of the element.
--- @param parent table The parent frame to set.
function Element:SetParent(parent)
    self.parent = parent;
    self.frame:SetParent(parent);
end

--- Retrieves the parent frame of the element.
--- @return table: The parent frame of the element.
function Element:GetParent()
    return self.parent;
end

--- Sets a single point position for the frame, clearing all other points.
--- @param point string The anchor point for the element.
--- @param ofsx number The horizontal offset from the anchor point.
--- @param ofsy number The vertical offset from the anchor point.
function Element:SetSinglePoint(point, ofsx, ofsy)
    self.frame:ClearAllPoints();
    self.frame:SetPoint(point, ofsx, ofsy);
end

--- Sets the position of the element's frame relative to another frame.
---@param point string The anchor point of the element's frame.
---@param relativeFrame table The frame to which the element's frame will be positioned relative to.
---@param relativePoint string The anchor point of the relative frame.
---@param ofsx number The horizontal offset from the anchor point.
---@param ofsy number The vertical offset from the anchor point.
function Element:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy)
    self.frame:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy);
end

--- Retrieves the position of a point on the element.
--- @param index number The index of the point to retrieve.
--- @return table: The position of the point as a table with x and y coordinates.
function Element:GetPoint(index)
    return self.frame:GetPoint(index);
end

--- Clears all anchor points from the element.
function Element:ClearAllPoints()
    self.frame:ClearAllPoints();
end

--- Sets the position and size of the element's frame to match another frame.
--- @param frame table The frame to match the position and size to.
function Element:SetAllPoints(frame)
    self.frame:SetAllPoints(frame);
end

--- Sets the width of the element.
--- @param w number The new width of the element.
function Element:SetWidth(w)
    self.w = w;
    self.frame:SetWidth(w);
end

--- Sets the height of the UI element.
--- @param h number The new height value.
function Element:SetHeight(h)
    self.h = h;
    self.frame:SetHeight(h);
end

--- Sets the size of the element.
--- @param w number The width of the element.
--- @param h number The height of the element.
function Element:SetSize(w, h)
    self.frame:SetSize(w, h);
end

--- Retrieves the width of the element.
--- @return number: The width of the element.
function Element:GetWidth()
    return self.frame:GetWidth();
end

--- Retrieves the height of the element.
--- @return number: The height of the element.
function Element:GetHeight()
    return self.frame:GetHeight();
end

--- Retrieves the frame of the element.
--- @return table: The frame of the element.
function Element:GetFrame()
    return self.frame;
end

--- Sets the alpha value of the element.
--- @param alpha number The new alpha value (0-1).
function Element:SetAlpha(alpha)
    self.frame:SetAlpha(alpha);
end

--- Retrieves the alpha value of the element.
--- @return number: The alpha value of the element.
function Element:GetAlpha()
    return self.frame:GetAlpha();
end

--- Retrieves the left position of the element.
--- @return number: The left position of the element.
function Element:GetLeft()
    return self.frame:GetLeft();
end

--- Retrieves the right coordinate of the element.
--- @return number: The right coordinate of the element.
function Element:GetRight()
    return self.frame:GetRight();
end

--- Retrieves the top position of the element's frame.
--- @return number: The top position of the frame.
function Element:GetTop()
    return self.frame:GetTop();
end

--- Retrieves the bottom position of the element.
--- @return number: The bottom position of the element.
function Element:GetBottom()
    return self.frame:GetBottom();
end

--- Sets the scale of the element.
--- @param scale: number The scale value to set.
function Element:SetScale(scale)
    self.frame:SetScale(scale);
end

--- Retrieves the effective scale of the UI element.
--- @return number: The effective scale of the element.
function Element:GetEffectiveScale()
    return self.frame:GetEffectiveScale();
end

--- Sets whether the element should clip its children.
---@param on boolean Whether to clip the children or not.
function Element:SetClipsChildren(on)
    self.frame:SetClipsChildren(on);
end