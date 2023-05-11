SceneMachine.CameraController = SceneMachine.CameraController or {}
local CC = SceneMachine.CameraController;
SceneMachine.Player = SceneMachine.Player or {}
SceneMachine.Gizmos = SceneMachine.Gizmos or {}
SceneMachine.Input = SceneMachine.Input or {}
local Player = SceneMachine.Player;
local Renderer = SceneMachine.Renderer;
local Gizmos = SceneMachine.Gizmos;
local Input = SceneMachine.Input;
CC.RMBPressed = false;
CC.RMBStartPos = {}
CC.RMBPrevious = {}

local cameraTurnSpeed = 0.2;
function CC.Update()
    SceneMachine.Camera.X = Player.Position.x;
    SceneMachine.Camera.Y = Player.Position.y;
    SceneMachine.Camera.Z = Player.Position.z;
    
    if (CC.RMBPressed == true) then
		local x, y = GetCursorPosition();
		local xDiff = x - CC.RMBPrevious.x;
		local yDiff = y - CC.RMBPrevious.y;
		CC.RMBPrevious.x = x;
		CC.RMBPrevious.y = y;

		-- if camera is in flight mode then handle that --
		SceneMachine.Camera.Yaw = SceneMachine.Camera.Yaw - rad(xDiff * cameraTurnSpeed);
		SceneMachine.Camera.Pitch = SceneMachine.Camera.Pitch - rad(yDiff * cameraTurnSpeed);
        Player.Direction = Player.Direction - xDiff * cameraTurnSpeed;
        Player.Pitch = Player.Pitch - yDiff * cameraTurnSpeed;
	else
        SceneMachine.Camera.Yaw = rad(Player.Direction);
    end
end

function CC.OnRMBDown()
	local x, y = GetCursorPosition();
	CC.RMBStartPos.x = x;
	CC.RMBStartPos.y = y;
	CC.RMBPressed = true;
	CC.RMBPrevious.x = x;
	CC.RMBPrevious.y = y;
end

function CC.OnRMBUp()
	CC.RMBPressed = false;
end
