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