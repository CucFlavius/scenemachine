local Editor = SceneMachine.Editor;
local PM = Editor.ProjectManager;
local SM = Editor.SceneManager;
local SH = Editor.SceneHierarchy;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local L = Editor.localization;
local Input = SceneMachine.Input;
local OP = Editor.ObjectProperties;

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
				item.components[1]:GetFrame():RegisterForClicks("LeftButtonUp", "RightButtonUp");
				item.components[1]:ClearAllPoints();
				item.components[1]:SetAllPoints(item:GetFrame());

				-- object name text --
				item.components[2] = UI.Label:New(10, 0, 200, 18, item.components[1]:GetFrame(), "LEFT", "LEFT", "", 9);

				-- visibility icon --
				item.components[3] = UI.Button:New(-10, 0, 18, 18, item.components[1]:GetFrame(), "RIGHT", "RIGHT", nil, Resources.textures["EyeIcon"]);
				item.components[3]:SetColor(UI.Button.State.Normal, 0, 0, 0, 0);
				item.components[3]:SetAlpha(0.6);
			end,
			refreshItem = function(data, item)
				-- main button --
				item.components[1]:SetScript("OnClick", function(self, button, down)
					if (button == "LeftButton") then
						SM.SelectObject(data);
						SM.ApplySelectionEffects();
					elseif(button == "RightButton") then
						SM.SelectObject(data);
						SM.ApplySelectionEffects();

						local point, relativeTo, relativePoint, xOfs, yOfs = item:GetPoint(1);
						local x = -(item:GetLeft() - Input.mouseXRaw);
						local y = -(item:GetTop() - Input.mouseYRaw);
			
						local rx = x + xOfs + (SH.scrollList:GetLeft() - SceneMachine.mainWindow:GetLeft());
						local ry = y + yOfs + (SH.scrollList:GetTop() - SceneMachine.mainWindow:GetTop());
			
						local menuOptions = {
							{ ["Name"] = L["CM_DELETE"], ["Action"] = function() SM.DeleteObjects(SM.selectedObjects); end },
							{ ["Name"] = L["CM_HIDE_SHOW"], ["Action"] = function() SM.ToggleObjectsVisibility(SM.selectedObjects); end },
							{ ["Name"] = L["CM_FREEZE_UNFREEZE"], ["Action"] = function()
								SM.ToggleObjectsFreezeState(SM.selectedObjects);
								if (#SM.selectedObjects > 0) then
									for i= #SM.selectedObjects, 1, -1 do
										if (SM.selectedObjects[i].frozen) then
											table.remove(SM.selectedObjects, i);
										end
									end
									SH.RefreshHierarchy();
									OP.Refresh();
								end
							end },
						};
			
						SceneMachine.mainWindow:PopupWindowMenu(rx, ry, menuOptions);
					end
				end);
				item.components[1]:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
				for i = 1, #SM.selectedObjects, 1 do
					if (data == SM.selectedObjects[i]) then
						item.components[1]:SetColor(UI.Button.State.Normal, 0, 0.4765, 0.7968, 1);
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

	--SH.scrollList:Hide();

    SH.RefreshHierarchy();
end

function SH.RefreshHierarchy()
    if (PM.currentProject == nil) then
        return
    end

	SH.scrollList:SetData(SM.loadedScene.objects);
end