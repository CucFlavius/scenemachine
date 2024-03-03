local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local Editor = SceneMachine.Editor;
UI.TabGroup = {};
local TabGroup = UI.TabGroup;
TabGroup.__index = TabGroup;
setmetatable(TabGroup, UI.Element)

function TabGroup:New(x, y, w, h, parent, point, parentPoint, startLevel, editable)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        point = point or "TOPLEFT",
        parentPoint = parentPoint or "TOPLEFT",
        viewportWidth = 0;
        visible = true,
        startLevel = startLevel,
        position = 0,
        usedItems = 0,
        editable = editable,
        selectedIndex = 0,
    };

	setmetatable(v, TabGroup);
    v:Build();
	return v;
end

function TabGroup:Build()
    self.frame = UI.Rectangle:New(self.x, self.y, self.w, self.h, self.parent, self.point, self.parentPoint, 1, 1, 1, 0);
	self.frame:GetFrame():SetScript("OnMouseWheel", function(_, delta)
        if (self.scrollbar.enabled) then
            local value = math.min(math.max(0, self.scrollbar.currentValue - (delta / (#self.data * 2))), 1);
            self.scrollbar:SetValue(value);
        end
    end);
    if (self.startLevel) then
        self.frame:SetFrameLevel(self.startLevel);
    end

    self.dropdownButton = UI.Button:New(0, 0, self.h, self.h, self.frame:GetFrame(), "TOPRIGHT", "TOPRIGHT", nil, Resources.textures["ArrowDown"], nil);
    self.dropdownButton.icon:SetSize(7, 7);
    self.dropdownButton:SetColor(UI.Button.State.Normal, 0, 0, 0, 0);

    self.dropdownButton:SetScript("OnClick", function()
        local menuOptions = {};
        for i = 1, #self.data, 1 do
            menuOptions[i] = { ["Name"] = self.data[i].name, ["Action"] = function()
                self.selectedIndex = i;
                if (self.template.lmbAction) then
                    self.template.lmbAction(i);
                end
            end };
        end
        local rx = (self.dropdownButton:GetLeft() - SceneMachine.mainWindow:GetLeft()) - SceneMachine.mainWindow.popup.menu:GetWidth() + self.h;
        local ry = (self.dropdownButton:GetTop() - SceneMachine.mainWindow:GetTop()) - self.h;
        SceneMachine.mainWindow:PopupWindowMenu(rx, ry, menuOptions);
    end);

    local buttonSpace = self.h;
    if (self.editable) then
        buttonSpace = buttonSpace + self.h;
        self.addButton = UI.Button:New(-self.h, 0, self.h, self.h, self.frame:GetFrame(), "TOPRIGHT", "TOPRIGHT", nil, Resources.textures["Add"], nil);
        self.addButton.icon:SetSize(7, 7);
        self.addButton:SetColor(UI.Button.State.Normal, 0, 0, 0, 0);

        self.addButton:SetScript("OnClick", function()
            local onRename = function(text, index) if (self.template.addAction) then self.template.addAction(text); end end
            self:RenameTab(-1, nil, onRename);
        end);
    end

    if (self.editable) then
        self.editBox = UI.TextBox:New(0, 0, 100, tabButtonHeight, self.frame:GetFrame(), "TOPLEFT", "TOPLEFT", "Rename");
        self.editBox.frame.texture:SetColorTexture(0,0,0,1);
        self.editBox:Hide();
    end

    self.viewport = UI.Rectangle:New(self.x, self.y, self.w, self.h - 5, self.frame:GetFrame(), "TOPLEFT", "TOPLEFT", 1, 0, 1, 0);
    self.viewport:SetPoint("TOPRIGHT", self.frame:GetFrame(), "TOPRIGHT", -buttonSpace, 0);
    self.viewport:SetClipsChildren(true);
    self.viewport:GetFrame():SetScript("OnSizeChanged", function(_, width, height)
        self.viewportWidth = width;
        self.scrollbar:Resize(self.viewportWidth, self.totalWidth);
        self.scrollbar:SetValue(self.scrollbar.currentValue);
    end);
    if (self.startLevel) then
        self.viewport:SetFrameLevel(self.startLevel + 1);
    end

    self.scrollbar = UI.ScrollbarHorizontal:New(0, 0, 300, 5, self.frame:GetFrame(), function(v) self:SetPosition(v); end);
    self.scrollbar:SetPoint("BOTTOMRIGHT", self.frame:GetFrame(), "BOTTOMRIGHT", -buttonSpace, 0);
    if (self.startLevel) then
        self.scrollbar:SetFrameLevel(self.startLevel + 4);
    end

    self.data = {};
    self.itemPool = {};
    self.poolSize = 0;
    self.dataStartIdx = 1;

    -- create a font string used for calculating all text size
    self.stringCalc = self.frame:GetFrame():CreateFontString("stringCalc");
	self.stringCalc:SetFont(Resources.defaultFont, 9, "NORMAL");
	self.stringCalc:SetAllPoints(self.frame:GetFrame());
	self.stringCalc:SetJustifyV("CENTER");
	self.stringCalc:SetJustifyH("LEFT");
    self.stringCalc:Hide();
end

function TabGroup:SetItemTemplate(template)
    self.template = template;
end

function TabGroup:ScrollStep(value)
    self.dataStartIdx = self.dataStartIdx - value;
    --self.scrollbar:SetValueWithoutAction(self.dataStartIdx / (#self.data - (#self.itemPool - 4)));
    self:Refresh(0);
end

function TabGroup:RenameTab(index, item, onRename)
    self.editBox:Show();
    local previousName = "";
    if (index > 0) then
        -- Rename --
        self.editBox:SetParent(item:GetFrame());
        self.editBox:ClearAllPoints();
        self.editBox:SetAllPoints(item:GetFrame());
        previousName = item.components[2]:GetText();
        item.components[2]:SetText("");
    else
        -- Add --
        self.editBox:SetParent(self.frame:GetFrame());
        self.editBox:ClearAllPoints();
        self.editBox:SetAllPoints(self.frame:GetFrame());
        self.editBox:SetFrameLevel(self.startLevel + 100);
        previousName = self.template.defaultTabName or "Add";
    end
    self.editBox:SetText(previousName);
    self.editBox:SetFocus();

    self.editBox:SetScript('OnEscapePressed', function(selft) 
        selft:ClearFocus();
        Editor.ui.focused = false;
        selft:Hide();
        if (item) then
            item.components[2]:SetText(previousName);
        end
    end);
    self.editBox:SetScript('OnEnterPressed', function(selft)
        selft:ClearFocus();
        Editor.ui.focused = false;
        local text = selft:GetText();
        onRename(text, index);
        selft:Hide();
    end);
end

function TabGroup:SetPosition(value)
    if (value >= 1) then value = 0.999; end -- this fixes my bad logic which causes a pop when scrolling to the end
    local offs = (value * self.totalWidth) - (value * self.viewportWidth);
    local dif = 0;
    local start = 0;
    local total = 0;
    for i = 1, #self.data, 1 do
        if (total > offs) then
            break;
        end
        start = start + 1;
        total = total + self.data[i].width;
    end
    dif = total - offs;
    start = max(start, 1);
    dif = self.data[start].width - dif;

    self.dataStartIdx = start;
    self.position = value;
    self:Refresh(dif);
end

function TabGroup:SetData(data)
    self.data = data;

    --- calc sizes
    local tw = 0;
    self.dataEndIdx = #self.data;
    for i = self.dataStartIdx, #self.data, 1 do
        self.stringCalc:SetText(self.data[i].name);
        local w = self.stringCalc:GetStringWidth() + 20;
        self.data[i].width = w;
        tw = tw + w;
    end

    self.totalWidth = tw;

    self.scrollbar:Resize(self.viewportWidth, self.totalWidth);
    self:Refresh(0);
end

function TabGroup:GetItem()
    local i = self.usedItems + 1;
    self.usedItems = self.usedItems + 1;

    if (i > #self.itemPool) then
        self.itemPool[i] = UI.Rectangle:New(0, 0, 50, self.template.height - 5, self.viewport:GetFrame(), "TOPLEFT", "TOPLEFT", 0, 0, 0, 0);
        self.itemPool[i]:SetSinglePoint("TOPLEFT", 0, 0);
        self.itemPool[i]:SetWidth(50);
        
        self.itemPool[i].components = {};
        -- main button --
        self.itemPool[i].components[1] = UI.Button:New(0, 0, 10, self.template.height, self.itemPool[i]:GetFrame(), "CENTER", "CENTER", "");
        self.itemPool[i].components[1]:ClearAllPoints();
        self.itemPool[i].components[1]:SetAllPoints(self.itemPool[i]:GetFrame());

        -- scene name text --
        self.itemPool[i].components[2] = UI.Label:New(10, 0, 100, self.template.height, self.itemPool[i].components[1]:GetFrame(), "LEFT", "LEFT", "", 9);

        if (self.startLevel) then
            self.itemPool[i]:SetFrameLevel(self.startLevel + 2 + i);
        end
        self.itemPool[i]:Hide();
        self.itemPool[i].built = true;
    end

    return self.itemPool[i];
end

function TabGroup:Refresh(dif)
    self.usedItems = 0;

    if (self.dataStartIdx < 1) then
        self.dataStartIdx = 1;
    end

    --- calc data end idx
    local vpw = self.viewportWidth;
    local tw = 0;
    self.dataEndIdx = #self.data;
    for i = self.dataStartIdx, #self.data, 1 do
        local w = self.data[i].width;
        tw = tw + w;
        if (vpw < tw) then
            self.dataEndIdx = i + 1;
            break;
        end
    end

    if (self.dataEndIdx > #self.data) then
        self.dataEndIdx = #self.data;
    end
    
    --local range = self.dataEndIdx - self.dataStartIdx;
    --print(self.dataStartIdx, self.dataEndIdx, range);


    --if (self.dataEndIdx == #self.data) then
    --    print(range)
    --    self.dataStartIdx = range;
    --end

    local pidx = 1;
    local xOffs = 0;

    for d = self.dataStartIdx, self.dataEndIdx, 1 do
        local item = self:GetItem();
        if (item.built) then
            item:Show();
            local width = self.template.refreshItem(self.data[d], item, d);
            item:SetSinglePoint("TOPLEFT", xOffs - dif, 0);

            if (d == self.selectedIndex) then
                item.components[1]:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
            else
                item.components[1]:SetColor(UI.Button.State.Normal, 0, 0, 0, 0);
            end

            item.components[1].frame:RegisterForClicks("LeftButtonUp", "RightButtonUp");
            item.components[1]:SetScript("OnClick", function(_, button, down)
                if (button == "LeftButton") then
                    self.selectedIndex = d;
                    if (self.template.lmbAction) then
                        self.template.lmbAction(d);
                    end
                elseif (button == "RightButton") then
                    self.selectedIndex = d;
                    if (self.template.rmbAction) then
                        self.template.rmbAction(d, item);
                    end
                end
            end);

            xOffs = xOffs + width;
            pidx = pidx + 1;
        end
    end

    for p = pidx, #self.itemPool, 1 do
        if (self.itemPool[p]) then
            self.itemPool[p]:Hide();
        end
    end

end

TabGroup.__tostring = function(self)
	return string.format("TabGroup( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end