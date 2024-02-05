local Editor = SceneMachine.Editor;
local PM = Editor.ProjectManager;
local SM = Editor.SceneManager;
local SH = Editor.SceneHierarchy;
local Gizmos = SceneMachine.Gizmos;
local CC = SceneMachine.CameraController;
local OP = Editor.ObjectProperties;
local AM = SceneMachine.Editor.AnimationManager;
local UI = SceneMachine.UI;

function SH.CreatePanel(x, y, w, h, c4)
    local leftPanel = UI.Rectangle:New(x, y, w, h, SceneMachine.mainWindow:GetFrame(), "TOPLEFT", "TOPLEFT", c4[1], c4[2], c4[3], 1);
    local group = Editor.CreateGroup("Hierarchy", h, leftPanel:GetFrame());

    SH.scrollList = UI.ScrollFrame:New(1, -1, w - 2, h - 22, group, "TOPLEFT", "TOPLEFT");
    SH.list = SH.ItemList(w - 45, 20, SH.scrollList.contentFrame);
    SH.RefreshHierarchy();
end

function SH.ItemList(itemSizeX, itemSizeY, parent)
	local itemList = {
		selectedIndex = -1,
		pool = {},
		SetItem = function(self, index, text)
			if (self.pool[index] == nil) then
				self.pool[index] = SH.ItemList_CreateNewItem(0, -(index - 1) * (itemSizeY + Editor.pmult), itemSizeX, itemSizeY, parent, #self.pool + 1);
				self.pool[index].text:SetText(text);
                self.pool[index]:SetScript("OnClick", function(self2)
                    SH.SelectObject(index);
                end);
				self.pool[index]:SetScript("OnDoubleClick", function(self2)
                    SH.SelectObject(index);
					CC.FocusObject(SM.selectedObject);
                end);
			else
				self.pool[index]:Show();
				self.pool[index].text:SetText(text);
			end
		end,
		GetSelected = function(self)
			return self.selectedIndex;
		end,
		Clear = function(self)
			for idx in pairs(self.pool) do
				self.pool[idx]:Hide();
			end
			selectedIndex = -1;
			-- deselect all other --
			for idx in pairs(self.pool) do
				self.pool[idx].ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
			end
		end,
		GetSize = function(self)
			
		end,
	};

	return itemList;
end

function SH.ItemList_CreateNewItem(x, y, w, h, parent, index)
	local ButtonFont = Editor.ui.defaultFont;
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
	item.text:SetText(name);

	-- visibility icon --
	SH.eyeIconVisibleTexCoord = { 0, 1, 0, 0.5 };
	SH.eyeIconInvisibleTexCoord = { 0, 1, 0.5, 1 };
	item.visibilityButton = UI.Button:New(0, 0, h, h, item, "RIGHT", "RIGHT", nil,
		"Interface\\Addons\\scenemachine\\static\\textures\\eyeIcon.png", SH.eyeIconVisibleTexCoord);
	item.visibilityButton:SetColor(UI.Button.State.Normal, 0, 0, 0, 0);
	item.visibilityButton:SetAlpha(0.6);
	item.visibilityButton:SetScript("OnClick", function (self, button, down) SH.VisibilityButton_OnClick(index) end);
	return item;
end

function SH.VisibilityButton_OnClick(index)
	local object = SM.loadedScene.objects[index];

	if (object) then
		SM.ToggleObjectVisibility(object);
	end
end

function SH.RefreshHierarchy()
    if (PM.currentProject == nil) then
        return
    end
        
    SH.list:Clear();

    local index = 1;
    for i in pairs(SM.loadedScene.objects) do
        local object = SM.loadedScene.objects[i];
        SH.list:SetItem(index, object.name);

        if (object == SM.selectedObject) then
            SH.list.pool[index].ntex:SetColorTexture(0, 0.4765, 0.7968,1);
        end

		if (object.frozen) then
			SH.list.pool[index].text:SetTextColor(1, 1, 1, 0.5);
		else
			SH.list.pool[index].text:SetTextColor(1, 1, 1, 1);
		end

		if (object.visible) then
			SH.list.pool[index].visibilityButton:SetTexCoords(SH.eyeIconVisibleTexCoord[1], SH.eyeIconVisibleTexCoord[2], SH.eyeIconVisibleTexCoord[3], SH.eyeIconVisibleTexCoord[4]);
		else
			SH.list.pool[index].visibilityButton:SetTexCoords(SH.eyeIconInvisibleTexCoord[1], SH.eyeIconInvisibleTexCoord[2], SH.eyeIconInvisibleTexCoord[3], SH.eyeIconInvisibleTexCoord[4]);
		end

        index = index + 1;
    end

    -- resize --
    --SH.scrollList.Scrollbar:SetMinMaxValues(0, max((index * 20) - (150), 1));
	--SH.scrollList.Scrollbar:SetValueStep(1);
end

function SH.SelectObject(index)
    SM.selectedObject = SM.loadedScene.objects[index];
    SH.RefreshHierarchy();
	OP.Refresh();

    -- also select track if available
    if (SM.selectedObject ~= nil) then
        AM.SelectTrackOfObject(SM.selectedObject);
    end
end