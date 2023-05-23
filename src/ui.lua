SceneMachine.Editor = SceneMachine.Editor or {};
local Win = ZWindowAPI;
local Editor = SceneMachine.Editor;
local Camera = SceneMachine.Camera;
local Renderer = SceneMachine.Renderer;
Editor.Input = {}

function SceneMachine.CreateWindow(name, width, height)
	SceneMachine.mainWindow = Win.CreateWindow(0, 0, width, height, nil, nil, nil, true, name);
	--SceneMachine.mainWindow.texture:SetColorTexture(0.9,0.9,1,1);
	SceneMachine.mainWindow:SetFrameStrata("BACKGROUND");
	SceneMachine.WINDOW_WIDTH = width;
	SceneMachine.WINDOW_HEIGHT = height;
	SceneMachine.mainWindow:SetIgnoreParentScale(true);		-- This way the camera doesn't get offset when the wow window or UI changes size/aspect

    local dropShadow = Win.CreateImageBox(0, 0, width * 1.2, height * 1.2, SceneMachine.mainWindow, "CENTER", "CENTER",
	"Interface\\Addons\\scenemachine\\static\\textures\\dropShadowSquare.png");

	local menu = {};
	menu[1] = {
		["Name"] = "File",
		["Options"] = {
			[1] = { ["Name"] = "New Project", ["Action"] = function() print("NewProject()") end },
			[2] = { ["Name"] = "Open Project", ["Action"] = function() print("OpenProject()") end },
			[3] = { ["Name"] = "Save", ["Action"] = function() print("Save()") end },
		},
	};
	menu[2] = {
		["Name"] = "Tools",
		["Options"] = {
		},
	};
	menu[3] = {
		["Name"] = "Help",
		["Options"] = {
			[1] = { ["Name"] = "About", ["Action"] = nil },
		},
	};
	Win.WindowCreateMenuBar(SceneMachine.mainWindow, menu);
end

function SceneMachine.CreateStatsFrame()
	SceneMachine.StatsFrame = CreateFrame("Frame", nil, Renderer.projectionFrame);
	SceneMachine.StatsFrame:SetPoint("TOPRIGHT", Renderer.projectionFrame, "TOPRIGHT", 0, 0);
	SceneMachine.StatsFrame:SetWidth(200);
	SceneMachine.StatsFrame:SetHeight(200);
	SceneMachine.StatsFrame:SetFrameStrata("LOW");
	SceneMachine.StatsFrame.text = SceneMachine.StatsFrame:CreateFontString(nil, "BACKGROUND", "GameTooltipText");
	SceneMachine.StatsFrame.text:SetFont(Win.defaultFont, 9, "NORMAL");

	SceneMachine.StatsFrame.text:SetPoint("TOPRIGHT",-5,-5);
	SceneMachine.StatsFrame.text:SetJustifyV("TOP");
	SceneMachine.StatsFrame.text:SetJustifyH("LEFT");
	SceneMachine.StatsFrame:Show();
end