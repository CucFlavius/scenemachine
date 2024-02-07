local Resources = SceneMachine.Resources;
local UI = SceneMachine.UI;
UI.ItemList = {};
local ItemList = UI.ItemList;
ItemList.__index = ItemList;
setmetatable(ItemList, UI.Element)

function ItemList:New(w, h, parent, onSelect)
	local v = 
    {
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        onSelect = onSelect or nil,
        visible = true,
    };

	setmetatable(v, ItemList);
    v:Build();
	return v;
end

function ItemList:Build()
    --[[
    self.frame = CreateFrame("Frame", "SceneMachine.UI.ItemList.frame", self.parent);
	self.frame:SetPoint(self.point, self.parent, self.parentPoint, self.x, self.y);
	self.frame:SetSize(self.w, self.h);
	self.frame.texture = self.frame:CreateTexture("ItemList Frame Texture", "BACKGROUND");
	self.frame.texture:SetColorTexture(self.R, self.G, self.B, self.A);
	self.frame.texture:SetAllPoints(self.frame);
    --]]
    
    self.selectedIndex = -1;
    self.pool = {};
end

function ItemList:GetSelected()
    return self.selectedIndex;
end

function ItemList:Clear()
    for idx in pairs(self.pool) do
        self.pool[idx]:Hide();
    end
    self.selectedIndex = -1;
    -- deselect all other --
    for idx in pairs(self.pool) do
        self.pool[idx].ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
    end
end

function ItemList:SetItem(index, text)
    if (self.pool[index] == nil) then
        self.pool[index] = self:CreateNewItem(0, -(index - 1) * (self.h), self.w, self.h, self.parent);
        self.pool[index].text:SetText(text);
        self.pool[index]:SetScript("OnClick", function()
            -- deselect all other --
            for idx in pairs(self.pool) do
                self.pool[idx].ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
            end

            -- select current --
            self.pool[index].ntex:SetColorTexture(0, 0.4765, 0.7968,1);
        
            -- set index --
            self.selectedIndex = index;

            -- trigger action --
            if (self.onSelect) then
                self.onSelect(index);
            end
        end);
    else
        self.pool[index]:Show();
        self.pool[index].text:SetText(text);
    end
end

function ItemList:CreateNewItem(x, y, w, h, parent)
	local ButtonFont = Resources.defaultFont;
	local ButtonFontSize = 9;

	-- main button frame --
	local item = CreateFrame("Button", "Zee.WindowAPI.Button", parent)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
	item:SetWidth(w);
	item:SetHeight(h)
	item.ntex = item:CreateTexture()
	item.htex = item:CreateTexture()
	item.ptex = item:CreateTexture()
	item.ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
	item.htex:SetColorTexture(0.242, 0.242, 0.25,1);
	item.ptex:SetColorTexture(0, 0.4765, 0.7968,1);
	item.ntex:SetAllPoints()	
	item.ptex:SetAllPoints()
	item.htex:SetAllPoints()
	item:SetNormalTexture(item.ntex)
	item:SetHighlightTexture(item.htex)
	item:SetPushedTexture(item.ptex)

	-- project name text --
	item.text = item:CreateFontString("Zee.WindowAPI.Button Text");
	item.text:SetFont(ButtonFont, ButtonFontSize, "NORMAL");
	item.text:SetPoint("LEFT", item, "LEFT", 10, 0);

	return item;
end

ItemList.__tostring = function(self)
	return string.format("ItemList( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end