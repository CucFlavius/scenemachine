SceneMachine.CameraController = SceneMachine.CameraController or {}
local CC = SceneMachine.CameraController;
SceneMachine.Player = SceneMachine.Player or {}
SceneMachine.Gizmos = SceneMachine.Gizmos or {}
local Player = SceneMachine.Player;
local Renderer = SceneMachine.Renderer;
local Gizmos = SceneMachine.Gizmos;
CC.LMBPressed = false;
CC.LMBStartPos = {}
CC.LMBPrevious = {}

function CC.CreateMouseInputFrame()
    CC.mouseInputFrame = CreateFrame("Frame", "CC.mouseInputFrame", Renderer.projectionFrame);
	CC.mouseInputFrame:SetPoint("CENTER", Renderer.projectionFrame, "CENTER", 0, 0);
	CC.mouseInputFrame:SetWidth(SceneMachine.WINDOW_WIDTH);
	CC.mouseInputFrame:SetHeight(SceneMachine.WINDOW_HEIGHT);
    --CC.mouseInputFrame:SetFrameStrata("MEDIUM");
    --CC.mouseInputFrame.texture = CC.mouseInputFrame:CreateTexture("texture", "ARTWORK")
    --CC.mouseInputFrame.texture:SetColorTexture(1,1,1,1  );

	CC.mouseInputFrame:EnableMouse(true)
	CC.mouseInputFrame:RegisterForDrag("LeftButton")
	CC.mouseInputFrame:SetScript("OnDragStart", function(s) CC.OnLMBDown(); end)
	CC.mouseInputFrame:SetScript("OnDragStop", function(s) CC.OnLMBUp(); end)
end

local cameraTurnSpeed = 0.2;
function CC.Update()
    SceneMachine.Camera.X = Player.Position.x;
    SceneMachine.Camera.Y = Player.Position.y;
    SceneMachine.Camera.Z = Player.Position.z;
    
    if (CC.LMBPressed == true) then
		local x, y = GetCursorPosition();
		local xDiff = x - CC.LMBPrevious.x;
		local yDiff = y - CC.LMBPrevious.y;
		CC.LMBPrevious.x = x;
		CC.LMBPrevious.y = y;

		-- if camera is in flight mode then handle that --
		SceneMachine.Camera.Yaw = SceneMachine.Camera.Yaw - rad(xDiff * cameraTurnSpeed);
		SceneMachine.Camera.Pitch = SceneMachine.Camera.Pitch - rad(yDiff * cameraTurnSpeed);
        Player.Direction = Player.Direction - xDiff * cameraTurnSpeed;
        Player.Pitch = Player.Pitch - yDiff * cameraTurnSpeed;
	else
        SceneMachine.Camera.Yaw = rad(Player.Direction);
    end
end

function CC.OnLMBDown()
	local x, y = GetCursorPosition();
    if (Gizmos.isHighlighted) then
        Gizmos.OnLMBDown(x, y);
        CC.LMBPressed = false;
        return;
    end
	CC.LMBStartPos.x = x;
	CC.LMBStartPos.y = y;
	CC.LMBPressed = true;
	CC.LMBPrevious.x = x;
	CC.LMBPrevious.y = y;
end

function CC.OnLMBUp()
    if (Gizmos.isUsed) then
        Gizmos.OnLMBUp();
        return;
    end
	CC.LMBPressed = false;
end
