local Win = ZWindowAPI;
local Editor = SceneMachine.Editor;
local PM = Editor.ProjectManager;
local SM = Editor.SceneManager;
local SH = Editor.SceneHierarchy;
local Gizmos = SceneMachine.Gizmos;

function SH.CreatePanel(w, h, c4)
    local leftPanelHeight = Editor.height - Editor.toolbarHeight;
    local leftPanel = Win.CreateRectangle(0, -Editor.toolbarHeight, w, h, SceneMachine.mainWindow, "TOPLEFT", "TOPLEFT", c4[1], c4[2], c4[3], 1);
    local group = Editor.CreateGroup("Hierarchy", h, leftPanel);

    SH.scrollList = Win.CreateScrollList(5, -5, w - 20, h - 30, group, "TOPLEFT", "TOPLEFT");
    SH.list = SH.ItemList(w - 45, 20, SH.scrollList.ContentFrame);

    SH.RefreshHierarchy();
end


function SH.ItemList(itemSizeX, itemSizeY, parent)
	local itemList = {
		selectedIndex = -1,
		pool = {},
		SetItem = function(self, index, text)
			if (self.pool[index] == nil) then
				self.pool[index] = SH.ItemList_CreateNewItem(0, -(index - 1) * (itemSizeY + 1.0001), itemSizeX, itemSizeY, parent);
				self.pool[index].text:SetText(text);
                self.pool[index]:SetScript("OnClick", function(self2)
                    SH.SelectObject(index);
                end);
                --[[
				self.pool[index]:SetScript("OnClick", function(self2) 
				    -- deselect all other --
					for idx in pairs(self.pool) do
						self.pool[idx].ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
					end

					-- select current --
					self.pool[index].ntex:SetColorTexture(0, 0.4765, 0.7968,1);
				
					-- set index --
					self.selectedIndex = index;

					-- trigger action --
					onSelect(index);
				end);
                --]]
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

function SH.ItemList_CreateNewItem(x, y, w, h, parent)
	local ButtonFont = Win.defaultFont;
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

	return item;
end

function SH.RefreshHierarchy()
    if (PM.currentProject == nil) then
        return
    end
        
    SH.list:Clear();

    local index = 1;
    local scene = PM.currentProject.scenes[SM.loadedSceneIndex];
    for i in pairs(scene.objects) do
        local object = scene.objects[i];
        SH.list:SetItem(index, object.name);
        if (object == SM.selectedObject) then
            SH.list.pool[index].ntex:SetColorTexture(0, 0.4765, 0.7968,1);
        end
        index = index + 1;
    end

    -- resize --
    SH.scrollList.Scrollbar:SetMinMaxValues(0, max((index * 20) - (150), 1));
	SH.scrollList.Scrollbar:SetValueStep(1);

    Gizmos.refresh = true;
end

function SH.SelectObject(index)
    print(index);
    local scene = PM.currentProject.scenes[SM.loadedSceneIndex];
    SM.selectedObject = scene.objects[index];
    SH.RefreshHierarchy()
end