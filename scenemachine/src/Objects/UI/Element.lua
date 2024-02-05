SceneMachine.UI.Element = {};
local Element = SceneMachine.UI.Element;
Element.__index = Element;

function Element:Show()
    self.visible = true;
    self.frame:Show();
end

function Element:Hide()
    self.visible = false;
    self.frame:Hide();
end

function Element:IsVisible()
    return self.visible;
end

function Element:SetFrameLevel(level)
    self.frame:SetFrameLevel(level);
end

function Element:GetFrameLevel()
    return self.frame:GetFrameLevel();
end

function Element:SetFrameStrata(strata)
    self.frame:SetFrameStrata(strata);
end

function Element:GetFrameStrata()
    return self.frame:GetFrameStrata();
end

function Element:SetParent(parent)
    self.parent = parent;
    self.frame:SetParent(parent);
end

function Element:GetParent()
	return self.parent;
end

function Element:SetSinglePoint(point, ofsx, ofsy)
    self.frame:ClearAllPoints();
    self.frame:SetPoint(point, ofsx, ofsy);
end

function Element:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy)
    self.frame:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy);
end

function Element:GetPoint(index)
    return self.frame:GetPoint(index);
end

function Element:ClearAllPoints()
    self.frame:ClearAllPoints();
end

function Element:SetAllPoints(frame)
    self.frame:SetAllPoints(frame);
end

function Element:SetWidth(w)
    self.w = w;
    self.frame:SetWidth(w);
end

function Element:SetHeight(h)
    self.h = h;
    self.frame:SetHeight(h);
end

function Element:SetSize(w, h)
    self.frame:SetSize(w, h);
end

function Element:GetWidth()
    return self.w;
end

function Element:GetHeight()
    return self.h;
end

function Element:GetFrame()
    return self.frame;
end

function Element:SetAlpha(alpha)
    self.frame:SetAlpha(alpha);
end

function Element:GetAlpha()
    return self.frame:GetAlpha();
end

function Element:GetLeft()
    return self.frame:GetLeft();
end

function Element:GetRight()
    return self.frame:GetRight();
end

function Element:GetTop()
    return self.frame:GetTop();
end

function Element:GetBottom()
    return self.frame:GetBottom();
end

function Element:SetScale(scale)
    self.frame:SetScale(scale);
end

function Element:GetEffectiveScale()
    return self.frame:GetEffectiveScale();
end

function Element:SetClipsChildren(on)
    self.frame:SetClipsChildren(on);
end