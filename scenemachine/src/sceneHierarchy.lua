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

	SH.eyeIconVisibleTexCoord = { 0, 1, 0, 0.5 };
	SH.eyeIconInvisibleTexCoord = { 0, 1, 0.5, 1 };

	SH.scrollList = UI.PooledScrollList:New(1, -1, w - 2, h - 22, group, "TOPLEFT", "TOPLEFT");
	SH.scrollList:SetItemTemplate(
		{
			height = 20,
			buildItem = function(item)
				-- main button --
				item.components[1] = UI.Button:New(0, 0, 50, 18, item:GetFrame(), "CENTER", "CENTER", "");
				item.components[1]:ClearAllPoints();
				item.components[1]:SetAllPoints(item:GetFrame());

				-- object name text --
				item.components[2] = UI.Label:New(10, 0, 200, 18, item.components[1]:GetFrame(), "LEFT", "LEFT", "", 9);

				-- visibility icon --
				item.components[3] = UI.Button:New(-10, 0, 18, 18, item.components[1]:GetFrame(), "RIGHT", "RIGHT", nil,
					"Interface\\Addons\\scenemachine\\static\\textures\\eyeIcon.png");
				item.components[3]:SetColor(UI.Button.State.Normal, 0, 0, 0, 0);
				item.components[3]:SetAlpha(0.6);
			end,
			refreshItem = function(data, item)
				-- main button --
				item.components[1]:SetScript("OnClick", function() SH.SelectObject(data); end);
				if (data == SM.selectedObject) then
					item.components[1]:SetColor(UI.Button.State.Normal, 0, 0.4765, 0.7968, 1);
				else
					item.components[1]:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
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
	

    SH.RefreshHierarchy();
end

function SH.RefreshHierarchy()
    if (PM.currentProject == nil) then
        return
    end

	SH.scrollList:SetData(SM.loadedScene.objects);
end

function SH.SelectObject(object)
	SM.selectedObject = object;
    SH.RefreshHierarchy();
	OP.Refresh();

    -- also select track if available
    if (SM.selectedObject ~= nil) then
        AM.SelectTrackOfObject(SM.selectedObject);
    end
end