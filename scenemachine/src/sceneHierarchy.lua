local Editor = SceneMachine.Editor;
local PM = Editor.ProjectManager;
local SM = Editor.SceneManager;
local SH = Editor.SceneHierarchy;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local L = Editor.localization;
local Input = SceneMachine.Input;
local OP = Editor.ObjectProperties;
local Actions = SceneMachine.Actions;
local CC = SceneMachine.CameraController;

SH.inputState = {
	dragging = false;
	mousePosStartX = 0;
    mousePosStartY = 0;
	startedmovingObjects = nil;
	movingObject = nil;
	viewportXMin = 0;
	viewportYMin = 0;
	viewportXMax = 0;
	viewportYMax = 0;
	viewportScale = 1;
	insertAboveIndex = -1;
	insertBelowIndex = -1;
	insertAsChildIndex = -1;
	previousIndex = -1;
};

function SH.CreatePanel(w, h, leftPanel, startLevel)
    --local group = Editor.CreateGroup("Hierarchy", h, leftPanel:GetFrame());
	SH.groupBG = UI.Rectangle:New(6, -6, w, h, leftPanel:GetFrame(), "TOPLEFT", "TOPLEFT",  0.1757, 0.1757, 0.1875, 1);
    SH.groupBG:SetPoint("BOTTOMRIGHT", Editor.horizontalSeparatorL:GetFrame(), "BOTTOMRIGHT", -6, 6);
	SH.groupBG:SetFrameLevel(startLevel);
    SH.groupTitleText = UI.Label:New(0, 0, w - 30, 20, SH.groupBG:GetFrame(), "TOPLEFT", "TOPLEFT", "   " .. L["SH_TITLE"], 9);
    SH.groupTitleText:SetPoint("TOPRIGHT", SH.groupBG:GetFrame(), "TOPRIGHT", 0, 0);
	SH.groupTitleText:SetFrameLevel(startLevel + 1);
    local groupContent = UI.Rectangle:New(0, -20, w - 12, h - 20, SH.groupBG:GetFrame(), "TOPLEFT", "TOPLEFT", 0.1445, 0.1445, 0.1445, 1);
    groupContent:SetPoint("BOTTOMRIGHT", SH.groupBG:GetFrame(), "BOTTOMRIGHT", 0, 0);
	groupContent:SetFrameLevel(startLevel + 2);

	SH.eyeIconVisibleTexCoord = { 0, 0.25, 0, 0.25 };
	SH.eyeIconInvisibleTexCoord = { 0, 0.25, 0.25, 0.5 };
	SH.openIconTexCoord = { 0.25, 0.5, 0, 0.25 };
	SH.closeIconTexCoord = { 0.25, 0.5, 0.25, 0.5 };
	SH.modelIconTexCoord = { 0, 0.25, 0.5, 0.75 };
	SH.groupIconTexCoord = { 0.25, 0.5, 0.5, 0.75 };
	SH.creatureIconTexCoord = { 0, 0.25, 0.75, 1 };
	SH.characterIconTexCoord = { 0.25, 0.5, 0.75, 1 };
	SH.cameraIconTexCoord = { 0.5, 0.75, 0.5, 0.75 };
	SH.lightIconTexCoord = { 0.5, 0.75, 0.75, 1 };

	SH.scrollList = UI.PooledScrollList:New(1, -1, w - 12, h - 22, groupContent:GetFrame(), "TOPLEFT", "TOPLEFT");
	SH.scrollList:SetPoint("BOTTOMRIGHT", groupContent:GetFrame(), "BOTTOMRIGHT", 0, 0);
	SH.scrollList:SetFrameLevel(startLevel + 3);
	SH.scrollList:SetItemTemplate(
		{
			useHorizontalScrollbar = true,
			height = 16,
			buildItem = function(item)
				item:SetColor(0, 0, 0, 0);

				-- main button --
				item.components[1] = UI.Button:New(0, 0, 50, 18, item:GetFrame(), "CENTER", "CENTER", "");
				item.components[1]:GetFrame():RegisterForClicks("LeftButtonUp", "RightButtonUp", "LeftButtonDown");
				item.components[1]:ClearAllPoints();
				item.components[1]:SetAllPoints(item:GetFrame());
				item.components[1]:SetColor(UI.Button.State.Normal, 0, 0, 0, 0);
				item.components[1]:SetColor(UI.Button.State.Highlight, 0, 0, 0, 0);	-- disable button highlight

				-- object name text --
				item.components[2] = UI.Label:New(0, 0, 200, 18, item.components[1]:GetFrame(), "LEFT", "LEFT", "", 9);

				-- object icon --
				item.components[3] = UI.Button:New(-16, 0, 16, 16, item.components[1]:GetFrame(), "LEFT", "LEFT", nil, Resources.textures["Hierarchy"]);
				item.components[3]:SetColor(UI.Button.State.Normal, 0, 0, 0, 0);
				item.components[3]:SetAlpha(0.7);

				-- open close button --
				item.components[4] = UI.Button:New(0, 0, 16, 16, item:GetFrame(), "LEFT", "LEFT", nil, Resources.textures["Hierarchy"]);
				item.components[4]:SetColor(UI.Button.State.Normal, 0, 0, 0, 0);
			end,
			refreshItem = function(hdata, item, d)
				if (hdata) then
					local data = SM.GetObjectByID(hdata.id);
					local level = hdata.level;
					if (data) then
						if (#hdata.childObjects > 0) then
							item.components[4]:Show();
							item.components[4]:SetSinglePoint("LEFT", level * 16, 0);
							item.components[4]:SetScript("OnClick", function(self, button, down)
								hdata.open = not hdata.open;
								SH.RefreshHierarchy();
							end);
						else
							item.components[4]:Hide();
						end

						item.components[1]:ClearAllPoints();
						item.components[1]:SetPoint("TOPLEFT", item:GetFrame(), "TOPLEFT", level * 16 + 32, 0);
						item.components[1]:SetHeight(16);
						--item.components[1]:SetPoint("BOTTOMRIGHT", item:GetFrame(), "BOTTOMRIGHT", 0, 0);
						--item.components[1]:SetWidth(200);

						-- main button --
						item.dataIndex = d;
						item.components[1]:SetScript("OnClick", function(self, button, down)
							if (button == "LeftButton") then
								-- if the object is not selected, select it
								if (not SM.IsObjectSelected(data)) then
									SH.SelectHierarchyObjectByID(hdata.id);
									SM.ApplySelectionEffects();
								-- if the object is selected, then only select it on mouse up
								else
									if (not down) then
										SH.SelectHierarchyObjectByID(hdata.id);
										SM.ApplySelectionEffects();
									end
								end

								if (down) then
									SH.inputState.startedmovingObjects = true;
									SH.inputState.mousePosStartX = Input.mouseXRaw;
									SH.inputState.mousePosStartY = Input.mouseYRaw;
								end
							elseif(button == "RightButton") then
								if (not SM.IsObjectSelected(data)) then
									SH.SelectHierarchyObjectByID(hdata.id);
									SM.ApplySelectionEffects();
								end
								SH.OpenItemContextMenu(data);
							end

							if (not down) then
								SH.inputState.startedmovingObjects = nil;
								SH.OnFinishedDraggingItem();
								SH.inputState.movingObjects = nil;
							end
						end);
						--item.components[1]:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
						item.components[1]:SetColor(UI.Button.State.Normal, 0, 0, 0, 0);
						if (SH.inputState.dragging) then
							item.components[1]:SetColor(UI.Button.State.Pressed, 0.1757, 0.1757, 0.1875, 1);	-- disable button pressed
						else
							item.components[1]:SetColor(UI.Button.State.Pressed, 0, 0.4765, 0.7968, 1);	-- enable button pressed
							for i = 1, #SM.selectedObjects, 1 do
								if (hdata.id == SM.selectedObjects[i].id) then
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
						local w = (item.components[2]:GetStringWidth())
						item.components[1]:SetWidth(w);
						item.width = w + ((level * 16) + 16) + 16;

						-- visibility icon --
						local objectType = data:GetType();
						if (objectType == SceneMachine.GameObjects.Object.Type.Model) then
							item.components[3]:SetTexCoords(SH.modelIconTexCoord);
						elseif (objectType == SceneMachine.GameObjects.Object.Type.Group) then
							item.components[3]:SetTexCoords(SH.groupIconTexCoord);
						elseif (objectType == SceneMachine.GameObjects.Object.Type.Creature) then
							item.components[3]:SetTexCoords(SH.creatureIconTexCoord);
						elseif (objectType == SceneMachine.GameObjects.Object.Type.Character) then
							item.components[3]:SetTexCoords(SH.characterIconTexCoord);
						elseif (objectType == SceneMachine.GameObjects.Object.Type.Camera) then
							item.components[3]:SetTexCoords(SH.cameraIconTexCoord);
						--elseif (data:GetType() == SceneMachine.GameObjects.Object.Type.Light) then
						--	item.components[3]:SetTexCoords(SH.lightIconTexCoord);
						end
						if (data.visible) then
							item.components[3]:SetAlpha(0.7);
							--item.components[3]:SetTexCoords(SH.eyeIconVisibleTexCoord);
						else
							item.components[3]:SetAlpha(0.3);
							--item.components[3]:SetTexCoords(SH.eyeIconInvisibleTexCoord);
						end
						item.components[3]:SetScript("OnClick", function(_, button, down) SM.ToggleObjectVisibility(data); end);

						if (hdata.open) then
							item.components[4]:SetTexCoords(SH.closeIconTexCoord);
						else
							item.components[4]:SetTexCoords(SH.openIconTexCoord);
						end
					else
						item.components[2]:SetText("<<corrupted data>>");
					end
				end
			end,
		});

	SH.scrollList:MakePool();

	SH.draggableItem = UI.Rectangle:New(0, 0, 50, 20, nil, "TOPLEFT", "TOPLEFT", 0.1757, 0.1757, 0.1875, 1);
	SH.draggableItem:SetWidth(SH.scrollList.viewport:GetWidth());
	SH.draggableItem:SetFrameLevel(SH.scrollList.viewport:GetFrameLevel() + 100);
	SH.draggableItem:SetFrameStrata(Editor.MESSAGE_BOX_FRAME_STRATA);
	SH.draggableItem:Hide();

	SH.insertMarker = UI.ImageBox:New(0, 0, 50, 40, nil, "TOPLEFT", "TOPLEFT", Resources.textures["Hierarchy"], { 0.75, 1, 0.5, 1 });
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
	
	-- create linear tree from data
	SH.linearData = {};
	if (SM.loadedScene) then
		SH.GenerateLinearTree(SM.loadedScene.objectHierarchy, SH.linearData, 0, -1);
	end
	SH.scrollList:SetData(SH.linearData);
end

function SH.GenerateLinearTree(objectBuffer, data, level, parentID)
	if (not objectBuffer) then
		return;
	end
	
	for i = 1, #objectBuffer, 1 do
		objectBuffer[i].level = level;
		objectBuffer[i].parentID = parentID;
		if (objectBuffer[i].open == nil) then
			objectBuffer[i].open = false;
		end
		table.insert(data, objectBuffer[i]);
		if (objectBuffer[i].open) then
			SH.GenerateLinearTree(objectBuffer[i].childObjects, data, level + 1, objectBuffer[i].id);
		end
	end
end

function SH.OpenItemContextMenu(object)

	local menuOptions = {};

	table.insert(menuOptions, { ["Name"] = L["CM_DELETE"], ["Action"] = function() SM.DeleteObjects(object); end });

	if (object:IsVisible()) then
		table.insert(menuOptions, { ["Name"] = L["CM_HIDE"], ["Action"] = function()
			if (#SM.selectedObjects == 1) then
				object:Hide();
			elseif (#SM.selectedObjects > 1) then
				for i = 1, #SM.selectedObjects, 1 do
					SM.selectedObjects[i]:Hide();
				end
			end
			SH.RefreshHierarchy();
		end });
	else
		table.insert(menuOptions, { ["Name"] = L["CM_SHOW"], ["Action"] = function()
			if (#SM.selectedObjects == 1) then
				object:Show();
			elseif (#SM.selectedObjects > 1) then
				for i = 1, #SM.selectedObjects, 1 do
					SM.selectedObjects[i]:Show();
				end
			end
			SH.RefreshHierarchy();
		end });
	end

	if (object:IsFrozen()) then
		table.insert(menuOptions, { ["Name"] = L["CM_UNFREEZE"], ["Action"] = function()
			if (#SM.selectedObjects == 1) then
				object:Unfreeze();
			elseif (#SM.selectedObjects > 1) then
				for i = 1, #SM.selectedObjects, 1 do
					SM.selectedObjects[i]:Unfreeze();
				end
			end
			SH.RefreshHierarchy();
		end });
	else
		table.insert(menuOptions, { ["Name"] = L["CM_FREEZE"], ["Action"] = function() object:Freeze();
			if (#SM.selectedObjects == 1) then
				object:Freeze();
			elseif (#SM.selectedObjects > 1) then
				for i = 1, #SM.selectedObjects, 1 do
					SM.selectedObjects[i]:Freeze();
				end
			end
			SM.SelectObject(nil);
			SH.RefreshHierarchy();
		end });
	end

	if (#SM.selectedObjects == 1) then
		local renameAction = function(text) object:Rename(text); SH.RefreshHierarchy(); end
		table.insert(menuOptions, { ["Name"] = L["CM_RENAME"], ["Action"] = function() Editor.OpenQuickTextbox(renameAction, object:GetName(), L["CM_RENAME"]); end });
	end

	table.insert(menuOptions, { ["Name"] = L["CM_FOCUS"], ["Action"] = function() CC.FocusObjects({object}); end });
	table.insert(menuOptions, { ["Name"] = L["CM_GROUP"], ["Action"] = function() SM.GroupObjects(SM.selectedObjects); end });
	local scale = SceneMachine.mainWindow:GetEffectiveScale();
	local rx = Input.mouseXRaw / scale - SceneMachine.mainWindow:GetLeft();
	local ry = Input.mouseYRaw / scale - SceneMachine.mainWindow:GetTop();

	SceneMachine.mainWindow:PopupWindowMenu(rx * scale, ry * scale, menuOptions);
end

function SH.GetSelectedHierarchyObjects(currentList, rawIDs)
	if (not rawIDs) then
		rawIDs = {};
	end
	local selectedObjects = {};

	for i = 1, #currentList, 1 do
		for s = 1, #SM.selectedObjects, 1 do
			if (currentList[i].id == SM.selectedObjects[s].id) then
				rawIDs[currentList[i].id] = true;
				table.insert(selectedObjects, currentList[i]);
			end
		end

		local results = SH.GetSelectedHierarchyObjects(currentList[i].childObjects, rawIDs);
		if (results) then
			for j = 1, #results, 1 do
				rawIDs[results[j].id] = true;
				table.insert(selectedObjects, results[j]);
			end
		end
	end

	for i = #currentList, 1, -1 do
		if (rawIDs[currentList[i].id]) then
			table.remove(currentList, i);
		end
	end

	return selectedObjects;
end

function SH.Update(deltaTime)
	if (SH.inputState.startedmovingObjects) then
		-- determine if it moved enough for a drag
		local moveDelta = math.max(math.abs(Input.mouseXRaw - SH.inputState.mousePosStartX), math.abs(Input.mouseYRaw - SH.inputState.mousePosStartY));

		-- start dragging
		if (moveDelta > 20) then
			Editor.StartAction(Actions.Action.Type.HierarchyChange, SM.loadedScene.objectHierarchy);
			SH.inputState.savedHierarchyPositions = SH.CopyObjectHierarchy(SM.loadedScene.objectHierarchy);
			SH.inputState.movingObjects = SH.GetSelectedHierarchyObjects(SM.loadedScene.objectHierarchy);
			SH.inputState.startedmovingObjects = nil;
			SH.OnStartedDraggingItem();
		end
	end

	if (SH.inputState.movingObjects) then
		-- force check if finished dragging (can't rely on mouse up event)
        if (not Input.mouseState.LMB) then
			SH.inputState.startedmovingObjects = nil;
			SH.OnFinishedDraggingItem();
			SH.inputState.movingObjects = nil;
            return;
        end

		-- dragging (loop)
		SH.OnDraggingItem(deltaTime);
	end
end

function SH.ShowInsert(x, y)
	if (x and y) then
		local h = SH.insertMarker:GetHeight();
		SH.insertMarker:Show();
		SH.insertMarker:SetSinglePoint("BOTTOMLEFT", x, y - (h/2));
	end
end

function SH.HideInsert()
	SH.insertMarker:Hide();
end

function SH.InsertInLinearList(index, below)
	if (below) then
		SH.inputState.insertBelowIndex = index;
		SH.inputState.insertAboveIndex = -1;
	else
		SH.inputState.insertAboveIndex = index;
		SH.inputState.insertBelowIndex = -1;
	end
	SH.inputState.insertAsChildIndex = -1;
end

function SH.InsertChild(index)
	SH.insertMarker:Hide();
	SH.inputState.insertAboveIndex = -1;
	SH.inputState.insertBelowIndex = -1;
	SH.inputState.insertAsChildIndex = index;
end

function SH.InsertRestorePosition()
	SH.insertMarker:Hide();
	SH.inputState.insertAboveIndex = -1;
	SH.inputState.insertBelowIndex = -1;
	SH.inputState.insertAsChildIndex = -1;
end

function SH.OnStartedDraggingItem()
	SH.inputState.dragging = true;
	SH.draggableItem:SetWidth(SH.scrollList.viewport:GetWidth());
	SH.draggableItem:Show();
	if (#SH.inputState.movingObjects == 1) then
		local obj = SM.GetObjectByID(SH.inputState.movingObjects[1].id);
		SH.draggableItem.label:SetText(obj:GetName());
	else
		SH.draggableItem.label:SetText(#SH.inputState.movingObjects .. " Objects");
	end

	SH.inputState.viewportScale = SH.scrollList.viewport:GetEffectiveScale();
	SH.insertMarker:SetWidth(SH.scrollList.viewport:GetWidth() * SH.inputState.viewportScale);

	-- calculate viewport location in relation to the mouse
	SH.inputState.viewportXMin = SH.scrollList.viewport:GetLeft() * SH.inputState.viewportScale;
	SH.inputState.viewportYMin = SH.scrollList.viewport:GetBottom() * SH.inputState.viewportScale;
	SH.inputState.viewportXMax = SH.scrollList.viewport:GetRight() * SH.inputState.viewportScale;
	SH.inputState.viewportYMax = SH.scrollList.viewport:GetTop() * SH.inputState.viewportScale;

	-- exclude current item from data, but remember the position in hierarchy
	SH.inputState.savedWorldPositions = {};
	SH.inputState.savedWorldRotations = {};
	SH.inputState.savedWorldScales = {};
	for i = 1, #SH.inputState.movingObjects, 1 do
		local object = SM.GetObjectByID(SH.inputState.movingObjects[i].id)
		local wPosition = object:GetWorldPosition();
		SH.inputState.savedWorldPositions[SH.inputState.movingObjects[i].id] = wPosition;
		local wRotation = object:GetWorldRotation();
		SH.inputState.savedWorldRotations[SH.inputState.movingObjects[i].id] = wRotation;
		local wScale = object:GetWorldScale();
		SH.inputState.savedWorldScales[SH.inputState.movingObjects[i].id] = wScale;
		SH.RemoveIDFromHierarchy(SH.inputState.movingObjects[i].id, SM.loadedScene.objectHierarchy);
	end
	SH.RefreshHierarchy();
end

function SH.CopyObjectHierarchy(hierarchy)
	local copy = {};
	for i = 1, #hierarchy, 1 do
		local hobject = { id = hierarchy[i].id, childObjects = {}, open = hierarchy[i].open, parentID = hierarchy[i].parentID};
		if (#hierarchy[i].childObjects > 0) then
			hobject.childObjects = SH.CopyObjectHierarchy(hierarchy[i].childObjects);
		end
		table.insert(copy, hobject);
	end
	return copy;
end

function SH.SetHierarchy(hierarchy)
	SM.loadedScene.objectHierarchy = SH.CopyObjectHierarchy(hierarchy);
end

function SH.GetIDParentAndIndexFromHierarchy(id, parentList)
	local parentID = -1;
	local index = -1;
	for i = 1, #parentList, 1 do
		if (parentList[i].id == id) then
			parentID = parentList[i].parentID;
			index = i;
			break;
		end

		local result = SH.GetIDParentAndIndexFromHierarchy(id, parentList[i].childObjects);
		if (result.parentID ~= -1) then
			parentID = result.parentID;
			index = result.index;
			break;
		end
	end

	return { parentID = parentID, index = index };
end

function SH.RemoveIDFromHierarchy(id, currentList)
	for i = 1, #currentList, 1 do
		if (currentList[i].id == id) then
			table.remove(currentList, i);
			return;
		end

		SH.RemoveIDFromHierarchy(id, currentList[i].childObjects);
	end
end

function SH.InsertIDChildInHierarchy(hobject, intoId, currentList)
	for i = 1, #currentList, 1 do
		if (currentList[i].id == intoId) then
			--print(hobject.id .. " inserted into " .. intoId)
			table.insert(currentList[i].childObjects, hobject);
			hobject.parentID = intoId;
			local object = SM.GetObjectByID(hobject.id)
			local wPosition = SH.inputState.savedWorldPositions[hobject.id];
			local wRotation = SH.inputState.savedWorldRotations[hobject.id];
			local wScale = SH.inputState.savedWorldScales[hobject.id];
			object:SetWorldPosition(wPosition.x, wPosition.y, wPosition.z);
			object:SetWorldRotation(wRotation.x, wRotation.y, wRotation.z);
			object:SetWorldScale(wScale);
			return;
		end

		SH.InsertIDChildInHierarchy(hobject, intoId, currentList[i].childObjects);
	end
end

function SH.InsertIDAboveInHierarchy(hobject, aboveID, currentList)
	for i = 1, #currentList, 1 do
		if (currentList[i].id == aboveID) then
			-- insert above current id in id's parent
			table.insert(currentList, i, hobject);
			local object = SM.GetObjectByID(hobject.id)
			local wPosition = SH.inputState.savedWorldPositions[hobject.id];
			local wRotation = SH.inputState.savedWorldRotations[hobject.id];
			local wScale = SH.inputState.savedWorldScales[hobject.id];
			object:SetWorldPosition(wPosition.x, wPosition.y, wPosition.z);
			object:SetWorldRotation(wRotation.x, wRotation.y, wRotation.z);
			object:SetWorldScale(wScale);
			hobject.parentID = aboveID;
			return;
		end

		SH.InsertIDAboveInHierarchy(hobject, aboveID, currentList[i].childObjects);
	end
end

function SH.InsertIDBelowInHierarchy(hobject, belowID, currentList)
	for i = 1, #currentList, 1 do
		if (currentList[i].id == belowID) then
			-- if current has child objects
			if (#currentList[i].childObjects > 0) then
				-- if open
				if (currentList[i].open) then
					-- insert as first child
					table.insert(currentList[i].childObjects, 1, hobject);
					hobject.parentID = belowID;
				-- if closed
				else
					-- insert below current id in id's parent
					table.insert(currentList, i + 1, hobject);
					hobject.parentID = currentList[i].parentID;
				end
			-- if current doesn't have child objects
			else
				-- insert below current id in id's parent
				table.insert(currentList, i + 1, hobject);
				hobject.parentID = currentList[i].parentID;
			end
			local object = SM.GetObjectByID(hobject.id)
			local wPosition = SH.inputState.savedWorldPositions[hobject.id];
			local wRotation = SH.inputState.savedWorldRotations[hobject.id];
			local wScale = SH.inputState.savedWorldScales[hobject.id];
			object:SetWorldPosition(wPosition.x, wPosition.y, wPosition.z);
			object:SetWorldRotation(wRotation.x, wRotation.y, wRotation.z);
			object:SetWorldScale(wScale);
			return;
		end

		SH.InsertIDBelowInHierarchy(hobject, belowID, currentList[i].childObjects);
	end
end

function SH.OnDraggingItem(deltaTime)
	
	local mx, my = Input.mouseXRaw, Input.mouseYRaw;

	-- move the item to the mouse cursor
	SH.draggableItem:SetSinglePoint("BOTTOMLEFT", mx, my);

	-- determine if the mouse is over the viewport
	--if (MouseIsOver(SH.scrollList.viewport:GetFrame())) then
	if (mx > SH.inputState.viewportXMin and mx < SH.inputState.viewportXMax and my > SH.inputState.viewportYMin and my < SH.inputState.viewportYMax) then
		-- mouse over viewport
		SH.draggableItem:SetColor(0.1757, 0.1757, 0.1875, 1);

		-- determine if we should scroll the list
		local scrollIncrement = deltaTime;
		if (my > SH.inputState.viewportYMax - 20) then
			SH.scrollList.scrollbar:SetValue(max(0, SH.scrollList.currentPos - scrollIncrement));
		elseif (my < SH.inputState.viewportYMin + 20) then
			SH.scrollList.scrollbar:SetValue(min(1, SH.scrollList.currentPos + scrollIncrement));
		end

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
				
				if (mx > xmin and mx < xmax and my > ymin and my < ymax) then
					mouseOverItem = itemBuf;
				end
			else
				break;
			end
		end

		if (not mouseOverItem) then
			-- use last visible, if mouse is below it
			mouseOverItem = itemBuf;
			local xmin = mouseOverItem:GetLeft() * scale;
			local ymin = mouseOverItem:GetBottom() * scale;
			if (my < ymin) then
				SH.ShowInsert(xmin, ymin + SH.scrollList.template.height * SH.inputState.viewportScale);
				SH.InsertInLinearList(#SH.linearData, true);
				--SH.InsertSpacing(xmin, ymin + SH.scrollList.template.height, mouseOverItem.dataIndex);
			end
		else
			if (mouseOverItem) then
				local xmin = mouseOverItem:GetLeft() * scale;
				local ymin = mouseOverItem:GetBottom() * scale;
				local ymax = ymin + (mouseOverItem:GetHeight() * scale);

				-- if closer to top edge
				if (math.abs(my - ymin) < 4) then
					-- insert above
					SH.ShowInsert(xmin, ymin);
					SH.InsertInLinearList(mouseOverItem.dataIndex, true);
				-- if closer to bottom edge
				elseif (math.abs(my - ymax) < 4) then
					-- insert below
					SH.ShowInsert(xmin, ymin + SH.scrollList.template.height* SH.inputState.viewportScale);
					SH.InsertInLinearList(mouseOverItem.dataIndex, false);
				-- if closer to center
				else
					SH.HideInsert();
					SH.InsertChild(mouseOverItem.dataIndex);
					mouseOverItem.components[1]:SetColor(UI.Button.State.Highlight, 0, 0.4765, 0.7968, 1);	-- enable button highlight
				end
			end
		end
	else
		-- mouse not over viewport
		SH.draggableItem:SetColor(0.1, 0.1, 0.1, 1);
		SH.InsertRestorePosition();
		SH.HideInsert();
	end
end

function SH.OnFinishedDraggingItem()
	SH.inputState.dragging = false;
	SH.draggableItem:Hide();
	SH.insertMarker:Hide();

	if (SH.inputState.insertAboveIndex == -1 and SH.inputState.insertBelowIndex == -1 and SH.inputState.insertAsChildIndex == -1 and SH.inputState.movingObjects) then
		-- not over any item, restore previous hierarchy
		SH.SetHierarchy(SH.inputState.savedHierarchyPositions);
	end

	if (SH.inputState.insertAboveIndex ~= -1 and SH.inputState.movingObjects) then
		if (SH.inputState.insertAboveIndex <= #SH.linearData) then
			for i = 1, #SH.inputState.movingObjects, 1 do
				local hobject = SH.inputState.movingObjects[i];
				local aboveLinearID = SH.linearData[SH.inputState.insertAboveIndex].id;
				SH.InsertIDAboveInHierarchy(hobject, aboveLinearID, SM.loadedScene.objectHierarchy);
			end
		end
		SH.inputState.insertAboveIndex = -1;
	end

	if (SH.inputState.insertBelowIndex ~= -1 and SH.inputState.movingObjects) then
		if (SH.inputState.insertBelowIndex <= #SH.linearData) then
			for i = 1, #SH.inputState.movingObjects, 1 do
				local hobject = SH.inputState.movingObjects[i];
				if (SH.inputState.insertBelowIndex == 0) then
					-- this is the only scene object
					-- just place it back
					SH.SetHierarchy(SH.inputState.savedHierarchyPositions);
				else
					local belowLinearID = SH.linearData[SH.inputState.insertBelowIndex].id;
					SH.InsertIDBelowInHierarchy(hobject, belowLinearID, SM.loadedScene.objectHierarchy);
				end
			end
		end
		SH.inputState.insertBelowIndex = -1;
	end

	if (SH.inputState.insertAsChildIndex ~= -1 and SH.inputState.movingObjects) then
		for i = 1, #SH.inputState.movingObjects, 1 do
			local hobject = SH.inputState.movingObjects[i];
			local intoId = SH.linearData[SH.inputState.insertAsChildIndex].id;
			SH.InsertIDChildInHierarchy(hobject, intoId, SM.loadedScene.objectHierarchy);
		end
		SH.inputState.insertAsChildIndex = -1;
	end

	Editor.FinishAction(SM.loadedScene.objectHierarchy);
	SH.RefreshHierarchy();
	OP.Refresh();
end

function SH.SelectHierarchyObjectByID(ID)
	local object = SM.GetObjectByID(ID);
	if (object) then
		SM.SelectObject(object);
	end
end

function SH.AddNewObject(ID)
	table.insert(SM.loadedScene.objectHierarchy, { id = ID, childObjects = {} });
end

function SH.GetHierarchyObject(objectBuffer, ID)
    for i = 1, #objectBuffer do
        if objectBuffer[i].id == ID then
            return objectBuffer[i]
        elseif objectBuffer[i].childObjects then
            local result = SH.GetHierarchyObject(objectBuffer[i].childObjects, ID)
            if result then
                return result
            end
        end
    end
    return nil
end

function SH.GetChildObjects(ID)
	local hobject = SH.GetHierarchyObject(SM.loadedScene.objectHierarchy, ID);
	if (not hobject) then
		return nil;
	end
	
	local childObjects = {};
	for i = 1, #hobject.childObjects, 1 do
		local object = SM.GetObjectByID(hobject.childObjects[i].id);
		if (object) then
			table.insert(childObjects, object);
		end
	end
	
	return childObjects;
end

function SH.GetChildObjectsRecursive(ID)
	local hobject = SH.GetHierarchyObject(SM.loadedScene.objectHierarchy, ID);
	if (not hobject) then
		return nil;
	end
	
	local childObjects = {};
	for i = 1, #hobject.childObjects, 1 do
		local object = SM.GetObjectByID(hobject.childObjects[i].id);
		if (object) then
			table.insert(childObjects, object);
			local childChildObjects = SH.GetChildObjectsRecursive(hobject.childObjects[i].id);
			if (childChildObjects) then
				for j = 1, #childChildObjects, 1 do
					table.insert(childObjects, childChildObjects[j]);
				end
			end
		end
	end
	
	return childObjects;
end

function SH.GetParentObject(ID)
	local hobject = SH.GetHierarchyObject(SM.loadedScene.objectHierarchy, ID);
	if (not hobject) then
		return nil;
	end

	if (hobject.parentID == -1) then
		return nil;
	end

	local parentObject = SM.GetObjectByID(hobject.parentID);
	return parentObject;
end

function SH.VerifyIntegrityRecursive(objectBuffer)
	if (objectBuffer) then
		for i = 1, #objectBuffer, 1 do
			if (objectBuffer[i]) then
				local object = SM.GetObjectByID(objectBuffer[i].id);
				if (not object) then
					table.remove(objectBuffer, i);
					i = i - 1;
				end
				if (i > 0) then
					SH.VerifyIntegrityRecursive(objectBuffer[i].childObjects);
				end
			end
		end
	end
end