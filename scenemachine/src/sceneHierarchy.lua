local Editor = SceneMachine.Editor;
local PM = Editor.ProjectManager;
local SM = Editor.SceneManager;
local SH = Editor.SceneHierarchy;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local L = Editor.localization;
local Input = SceneMachine.Input;
local OP = Editor.ObjectProperties;

SH.inputState = {
	dragging = false;
	mousePosStartX = 0;
    mousePosStartY = 0;
	startedMovingObject = nil;
	movingObject = nil;
	viewportXMin = 0;
	viewportYMin = 0;
	viewportXMax = 0;
	viewportYMax = 0;
	viewportScale = 1;
	insertIndex = -1;
};

function SH.CreatePanel(w, h, leftPanel, startLevel)
    --local group = Editor.CreateGroup("Hierarchy", h, leftPanel:GetFrame());
	local groupBG = UI.Rectangle:New(6, -6, w, h, leftPanel:GetFrame(), "TOPLEFT", "TOPLEFT",  0.1757, 0.1757, 0.1875, 1);
    groupBG:SetPoint("BOTTOMRIGHT", Editor.horizontalSeparatorL:GetFrame(), "BOTTOMRIGHT", -6, 6);
	groupBG:SetFrameLevel(startLevel);
    local groupTitleText = UI.Label:New(0, 0, w - 30, 20, groupBG:GetFrame(), "TOPLEFT", "TOPLEFT", "   " .. L["SH_TITLE"], 9);
    groupTitleText:SetPoint("TOPRIGHT", groupBG:GetFrame(), "TOPRIGHT", 0, 0);
	groupTitleText:SetFrameLevel(startLevel + 1);
    local groupContent = UI.Rectangle:New(0, -20, w - 12, h - 20, groupBG:GetFrame(), "TOPLEFT", "TOPLEFT", 0.1445, 0.1445, 0.1445, 1);
    groupContent:SetPoint("BOTTOMRIGHT", groupBG:GetFrame(), "BOTTOMRIGHT", 0, 0);
	groupContent:SetFrameLevel(startLevel + 2);

	SH.eyeIconVisibleTexCoord = { 0, 1, 0, 0.5 };
	SH.eyeIconInvisibleTexCoord = { 0, 1, 0.5, 1 };

	SH.scrollList = UI.PooledScrollList:New(1, -1, w - 12, h - 22, groupContent:GetFrame(), "TOPLEFT", "TOPLEFT");
	SH.scrollList:SetPoint("BOTTOMRIGHT", groupContent:GetFrame(), "BOTTOMRIGHT", 0, 0);
	SH.scrollList:SetFrameLevel(startLevel + 3);
	SH.scrollList:SetItemTemplate(
		{
			height = 20,
			buildItem = function(item)
				-- main button --
				item.components[1] = UI.Button:New(0, 0, 50, 18, item:GetFrame(), "CENTER", "CENTER", "");
				item.components[1]:GetFrame():RegisterForClicks("LeftButtonUp", "RightButtonUp", "LeftButtonDown");
				item.components[1]:ClearAllPoints();
				item.components[1]:SetAllPoints(item:GetFrame());
				item.components[1]:SetColor(UI.Button.State.Highlight, 0, 0, 0, 0);	-- disable button highlight

				-- object name text --
				item.components[2] = UI.Label:New(10, 0, 200, 18, item.components[1]:GetFrame(), "LEFT", "LEFT", "", 9);

				-- visibility icon --
				item.components[3] = UI.Button:New(-10, 0, 18, 18, item.components[1]:GetFrame(), "RIGHT", "RIGHT", nil, Resources.textures["EyeIcon"]);
				item.components[3]:SetColor(UI.Button.State.Normal, 0, 0, 0, 0);
				item.components[3]:SetAlpha(0.6);
			end,
			refreshItem = function(data, item, d)
				-- main button --
				item.dataIndex = d;
				item.components[1]:SetScript("OnClick", function(self, button, down)
					if (button == "LeftButton") then
						SM.SelectObject(data);
						SM.ApplySelectionEffects();
						if (down) then
							SH.inputState.startedMovingObject = data;
							SH.inputState.mousePosStartX = Input.mouseXRaw;
							SH.inputState.mousePosStartY = Input.mouseYRaw;
						end
					elseif(button == "RightButton") then
						SM.SelectObject(data);
						SM.ApplySelectionEffects();
						SH.OpenItemContextMenu(data);
					end

					if (not down) then
						SH.inputState.startedMovingObject = nil;
						SH.OnFinishedDraggingItem();
						SH.inputState.movingObject = nil;
					end
				end);
				item.components[1]:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
				if (SH.inputState.dragging) then
					item.components[1]:SetColor(UI.Button.State.Pressed, 0.1757, 0.1757, 0.1875, 1);	-- disable button pressed
				else
					item.components[1]:SetColor(UI.Button.State.Pressed, 0, 0.4765, 0.7968, 1);	-- enable button pressed
					for i = 1, #SM.selectedObjects, 1 do
						if (data == SM.selectedObjects[i]) then
							item.components[1]:SetColor(UI.Button.State.Normal, 0, 0.4765, 0.7968, 1);
						end
					end
				end

				-- frozen --
				if (data.frozen) then
					item.components[2]:SetTextColor(1, 1, 1, 0.5);
				else
					item.components[2]:SetTextColor(1, 1, 1, 1);
				end

				-- object name text --
				item.components[2]:SetText(data.name);

				-- visibility icon --
				if (data.visible) then
					item.components[3]:SetTexCoords(SH.eyeIconVisibleTexCoord);
				else
					item.components[3]:SetTexCoords(SH.eyeIconInvisibleTexCoord);
				end
				item.components[3]:SetScript("OnClick", function(_, button, down) SM.ToggleObjectVisibility(data); end);
			end,
		});

	SH.scrollList:MakePool();

	SH.draggableItem = UI.Rectangle:New(0, 0, 50, 20, nil, "TOPLEFT", "TOPLEFT", 0.1757, 0.1757, 0.1875, 1);
	SH.draggableItem:SetWidth(SH.scrollList.viewport:GetWidth());
	SH.draggableItem:SetFrameLevel(SH.scrollList.viewport:GetFrameLevel() + 100);
	SH.draggableItem:SetFrameStrata(Editor.MESSAGE_BOX_FRAME_STRATA);
	SH.draggableItem:Hide();

	SH.insertMarker = UI.ImageBox:New(0, 0, 50, 40, nil, "TOPLEFT", "TOPLEFT", Resources.textures["LinearHighlight"]);
	SH.insertMarker:SetVertexColor(0, 0.4765, 0.7968, 1);
	SH.insertMarker:SetWidth(SH.scrollList.viewport:GetWidth());
	SH.insertMarker:SetFrameLevel(SH.scrollList.viewport:GetFrameLevel() + 99);
	SH.insertMarker:SetFrameStrata(Editor.MESSAGE_BOX_FRAME_STRATA);
	SH.insertMarker:Hide();

	-- object name text --
	SH.draggableItem.label = UI.Label:New(10, 0, 200, 18, SH.draggableItem:GetFrame(), "LEFT", "LEFT", "", 9);

    SH.RefreshHierarchy();
end

function SH.RefreshHierarchy()
    if (PM.currentProject == nil) then
        return
    end

	if (not SH.inputState.dragging) then
		SH.scrollList:SetData(SM.loadedScene.objects);
	else
		SH.scrollList:SetData(SH.tempDraggingData);
	end
end

function SH.OpenItemContextMenu(object)

	local menuOptions = {};

	table.insert(menuOptions, { ["Name"] = L["CM_DELETE"], ["Action"] = function() SM.DeleteObjects(object); end });

	if (object:IsVisible()) then
		table.insert(menuOptions, { ["Name"] = L["CM_HIDE"], ["Action"] = function() object:Hide(); end });
	else
		table.insert(menuOptions, { ["Name"] = L["CM_SHOW"], ["Action"] = function() object:Show(); end });
	end

	if (object:IsFrozen()) then
		table.insert(menuOptions, { ["Name"] = L["CM_UNFREEZE"], ["Action"] = function() object:Unfreeze(); end });
	else
		table.insert(menuOptions, { ["Name"] = L["CM_FREEZE"], ["Action"] = function() object:Freeze();
			if (#SM.selectedObjects > 0) then
				for i= #SM.selectedObjects, 1, -1 do
					if (SM.selectedObjects[i].frozen) then
						table.remove(SM.selectedObjects, i);
					end
				end
				SH.RefreshHierarchy();
				OP.Refresh();
			end
		end });
	end

	local renameAction = function(text) object:Rename(text); SH.RefreshHierarchy(); end
	table.insert(menuOptions, { ["Name"] = L["CM_RENAME"], ["Action"] = function() Editor.OpenQuickTextbox(renameAction, object:GetName(), L["CM_RENAME"]); end });

	local scale = SceneMachine.mainWindow:GetEffectiveScale();
	local rx = Input.mouseXRaw / scale - SceneMachine.mainWindow:GetLeft();
	local ry = Input.mouseYRaw / scale - SceneMachine.mainWindow:GetTop();

	SceneMachine.mainWindow:PopupWindowMenu(rx * scale, ry * scale, menuOptions);
end

function SH.Update(deltaTime)
	if (SH.inputState.startedMovingObject) then
		-- determine if it moved enough for a drag
		local moveDelta = math.max(math.abs(Input.mouseXRaw - SH.inputState.mousePosStartX), math.abs(Input.mouseYRaw - SH.inputState.mousePosStartY));

		-- start dragging
		if (moveDelta > 20) then
			SH.inputState.movingObject = SH.inputState.startedMovingObject;
			SH.inputState.startedMovingObject = nil;
			SH.OnStartedDraggingItem();
		end
	end

	if (SH.inputState.movingObject) then
		-- force check if finished dragging (can't rely on mouse up event)
        if (not Input.mouseState.LMB) then
			SH.inputState.startedMovingObject = nil;
			SH.OnFinishedDraggingItem();
			SH.inputState.movingObject = nil;
            return;
        end

		-- dragging (loop)
		SH.OnDraggingItem();
	end
end

function SH.OnStartedDraggingItem()
	SH.inputState.dragging = true;
	SH.draggableItem:SetWidth(SH.scrollList.viewport:GetWidth());
	SH.draggableItem:Show();
	SH.draggableItem.label:SetText(SH.inputState.movingObject:GetName());

	SH.insertMarker:SetWidth(SH.scrollList.viewport:GetWidth());

	-- calculate viewport location in relation to the mouse
	SH.inputState.viewportScale = SH.scrollList.viewport:GetEffectiveScale();
	SH.inputState.viewportXMin = SH.scrollList.viewport:GetLeft() * SH.inputState.viewportScale;
	SH.inputState.viewportYMin = SH.scrollList.viewport:GetBottom() * SH.inputState.viewportScale;
	SH.inputState.viewportXMax = SH.inputState.viewportXMin + (SH.scrollList.viewport:GetWidth() * SH.inputState.viewportScale);
	SH.inputState.viewportYMax = SH.inputState.viewportYMin + (SH.scrollList.viewport:GetHeight() * SH.inputState.viewportScale);

	-- exclude current item from data
	SH.GenerateDraggingData();
end

function SH.GenerateDraggingData()
	SH.tempDraggingData = {};
	local idx = 1;
	for i = 1, #SM.loadedScene.objects, 1 do
		if (SM.loadedScene.objects[i] ~= SH.inputState.movingObject) then
			SH.tempDraggingData[idx] = SM.loadedScene.objects[i];
			idx = idx + 1;
		end
	end

	SH.RefreshHierarchy();
end

function SH.InsertSpacing(x, y, index)
	if (x and y) then
		local h = SH.insertMarker:GetHeight();
		SH.insertMarker:Show();
		SH.insertMarker:SetSinglePoint("BOTTOMLEFT", x, y - (h/2));
		SH.inputState.insertIndex = index;
	else
		SH.insertMarker:Hide();
		SH.inputState.insertIndex = -1;
	end
end

function SH.OnDraggingItem()
	-- move the item to the mouse cursor
	SH.draggableItem:SetSinglePoint("BOTTOMLEFT", Input.mouseXRaw, Input.mouseYRaw);

	-- determine if the mouse is over the viewport
	if (Input.mouseXRaw > SH.inputState.viewportXMin and
	Input.mouseXRaw < SH.inputState.viewportXMax and
	Input.mouseYRaw > SH.inputState.viewportYMin and
	Input.mouseYRaw < SH.inputState.viewportYMax) then
		-- mouse over viewport
		SH.draggableItem:SetColor(0.1757, 0.1757, 0.1875, 1);

		-- determine which item the mouse is over
		local scale = SH.inputState.viewportScale;
		local mouseOverItem;
		local itemBuf;
		for i = 1, #SH.scrollList.itemPool, 1 do
			itemBuf = SH.scrollList.itemPool[i];
			if (itemBuf:IsVisible()) then
				local xmin = itemBuf:GetLeft() * scale;
				local ymin = itemBuf:GetBottom() * scale;
				local xmax = xmin + (itemBuf:GetWidth() * scale);
				local ymax = ymin + (itemBuf:GetHeight() * scale);
				itemBuf.components[1]:SetColor(UI.Button.State.Highlight, 0, 0, 0, 0);	-- disable button highlight
				
				if (Input.mouseXRaw > xmin and Input.mouseXRaw < xmax and Input.mouseYRaw > ymin and Input.mouseYRaw < ymax) then
					mouseOverItem = itemBuf;
				end
			else
				break;
			end
		end

		if (not mouseOverItem) then
			-- use last visible, if mouse is blow it
			mouseOverItem = itemBuf;
			local xmin = mouseOverItem:GetLeft() * scale;
			local ymin = mouseOverItem:GetBottom() * scale;
			if (Input.mouseYRaw < ymin) then
				SH.InsertSpacing(xmin, ymin + SH.scrollList.template.height, mouseOverItem.dataIndex);
			end
		else
			if (mouseOverItem) then
				local xmin = mouseOverItem:GetLeft() * scale;
				local ymin = mouseOverItem:GetBottom() * scale;
				local ymax = ymin + (mouseOverItem:GetHeight() * scale);

				-- if closer to top edge
				if (math.abs(Input.mouseYRaw - ymin) < 5) then
					-- insert above
					SH.InsertSpacing(xmin, ymin, mouseOverItem.dataIndex + 1);
				-- if closer to bottom edge
				elseif (math.abs(Input.mouseYRaw - ymax) < 5) then
					-- insert below
					SH.InsertSpacing(xmin, ymin + SH.scrollList.template.height, mouseOverItem.dataIndex);
				-- if closer to center
				else
					SH.InsertSpacing();
					mouseOverItem.components[1]:SetColor(UI.Button.State.Highlight, 0, 0.4765, 0.7968, 1);	-- enable button highlight
				end
			end
		end
	else
		-- mouse not over viewport
		SH.draggableItem:SetColor(0.1, 0.1, 0.1, 1);
		SH.InsertSpacing();
	end
end

function SH.OnFinishedDraggingItem()
	SH.inputState.dragging = false;
	SH.draggableItem:Hide();
	SH.insertMarker:Hide();

	if (SH.inputState.insertIndex ~= -1) then
		table.insert(SH.tempDraggingData, SH.inputState.insertIndex, SH.inputState.movingObject);
		SM.loadedScene.objects = SH.tempDraggingData;
	end

	SH.scrollList:SetData(SM.loadedScene.objects);
end