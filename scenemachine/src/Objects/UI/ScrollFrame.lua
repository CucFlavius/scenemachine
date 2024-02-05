local UI = SceneMachine.UI;
UI.ScrollFrame = {};
local ScrollFrame = UI.ScrollFrame;
ScrollFrame.__index = ScrollFrame;
setmetatable(ScrollFrame, UI.Element)

function ScrollFrame:New(x, y, w, h, parent, point, parentPoint)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        point = point or "TOPLEFT",
        parentPoint = parentPoint or "TOPLEFT",
        visible = true,
    };

	setmetatable(v, ScrollFrame);
    v:Build();
	return v;
end

function ScrollFrame:Build()
	self.frame = CreateFrame("Frame", "SceneMachine.UI.ScrollFrame.frame", self.parent);
	self.frame:SetPoint(self.point, self.parent, self.parentPoint, self.x, self.y);
	self.frame:SetSize(self.w, self.h);
	self.frame_texture = self.frame:CreateTexture("SceneMachine.UI.ScrollFrame.frame_texture", "BACKGROUND");
	self.frame_texture:SetColorTexture(0, 0, 0, 0.4);
	self.frame_texture:SetAllPoints(self.frame);

	-- ScrollFrame scroll frame 
	self.scrollFrame = CreateFrame("ScrollFrame", "SceneMachine.UI.ScrollFrame.scrollFrame", self.frame);
	self.scrollFrame:SetPoint("TOPLEFT", 4, -4);
	self.scrollFrame:SetPoint("BOTTOMRIGHT", -4, 4);

	-- ScrollFrame content frame 
	self.contentFrame = CreateFrame("Frame", "SceneMachine.UI.ScrollFrame.contentFrame", self.scrollFrame);
	self.contentFrame:SetSize(self.w, 380);
	self.contentFrame:SetPoint("TOPLEFT",25,0);
	self.contentFrame:EnableMouse();
	self.contentFrame:SetFrameLevel(100);
	self.contentFrame:SetToplevel(true);
	self.scrollFrame:SetScrollChild(self.contentFrame);

	-- ScrollFrame scrollbar 
	self.scrollbar = UI.Scrollbar:New(0, 0, 16, self.h - 22, self.frame,
		function(value)
			-- on scroll
			self.contentFrame:ClearAllPoints();
			local height = self.contentFrame:GetHeight() - self.frame:GetHeight();
			local pos = value * height;
			self.contentFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, math.floor(pos));
		end);
		
	local scrollbar = self.scrollbar;
	local scrollFrame = self.scrollFrame;
	local contentFrame = self.contentFrame;

	self.scrollFrame:SetScript("OnMouseWheel",
		function(self, delta)
			scrollbar:SetValue(scrollFrame:GetVerticalScroll() - (delta * (20 / contentFrame:GetHeight())));
		end);
end

ScrollFrame.__tostring = function(self)
	return string.format("ScrollFrame( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end