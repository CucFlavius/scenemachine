local CC = SceneMachine.CameraController;
local Player = SceneMachine.Player;
local Renderer = SceneMachine.Renderer;
local Gizmos = SceneMachine.Gizmos;
local Input = SceneMachine.Input;

----------------------------------
--			CC State	 		--
----------------------------------
CC.Action = {};						-- the collection of player action booleans
CC.RMBStartPos = {}
CC.RMBPrevious = {}
CC.RMBPressed = false;
CC.Action.TurnLeft = false;			-- true if turn right key is pressed
CC.Action.TurnRight = false;		-- true if turn right key is pressed
CC.Action.MoveForward = false;		-- true if move forward key pressed
CC.Action.MoveBackward = false;		-- true if move backward key is pressed
CC.Action.StrafeLeft = false;		-- true if strafe left key is pressed
CC.Action.StrafeRight = false;		-- true if strafe right key is pressed
CC.Action.ShiftSpeed = false;

----------------------------------
--			Variables	 		--
----------------------------------
CC.FoV = 70;						-- Field of View in degrees
CC.Direction = 180;					-- The start angle at which the player is looking in degrees ( in degrees )
CC.Pitch = 0;
CC.Position = {};					-- the position table
CC.Position.x = 0; 					-- start position
CC.Position.y = 0; 					-- start position
CC.Position.z = 1;					-- start position
CC.keyboardTurnSpeed = 1;
CC.moveSpeed = 0.1;
CC.acceleration = 1.0;
CC.maxAcceleration = 12.0;
CC.mouseTurnSpeed = 0.2;

--------------------------------------
--			Keyboard Input			--
--------------------------------------
function CC.Initialize()
    SceneMachine.Input.AddKeyBind("W", function() CC.Action.MoveForward = true end, function() CC.Action.MoveForward = false end);
    SceneMachine.Input.AddKeyBind("S", function() CC.Action.MoveBackward = true end, function() CC.Action.MoveBackward = false end);
    SceneMachine.Input.AddKeyBind("A", function() CC.Action.TurnLeft = true end, function() CC.Action.TurnLeft = false end);
    SceneMachine.Input.AddKeyBind("D", function() CC.Action.TurnRight = true end, function() CC.Action.TurnRight = false end);
    SceneMachine.Input.AddKeyBind("Q", function() CC.Action.StrafeLeft = true end, function() CC.Action.StrafeLeft = false end);
    SceneMachine.Input.AddKeyBind("E", function() CC.Action.StrafeRight = true end, function() CC.Action.StrafeRight = false end);
	SceneMachine.Input.AddKeyBind("LSHIFT", function() CC.Action.ShiftSpeed = true end, function() CC.Action.ShiftSpeed = false end);
    SceneMachine.Input.Initialize();

	-- calculate speeds based on update interval --
	CC.keyboardTurnSpeed = CC.keyboardTurnSpeed * (SceneMachine.UPDATE_INTERVAL * 100);
	CC.moveSpeed = CC.moveSpeed * (SceneMachine.UPDATE_INTERVAL * 100);
end

function CC.Update()
	if (CC.Action.ShiftSpeed == true) then
		CC.acceleration = CC.acceleration + (SceneMachine.UPDATE_INTERVAL * 3.0);
		CC.acceleration = math.min(CC.maxAcceleration, CC.acceleration);
	else
		CC.acceleration = 1.0;
	end

    if CC.RMBPressed == false then
	    if CC.Action.TurnLeft then
            CC.Direction = CC.Direction + CC.keyboardTurnSpeed;
            if CC.Direction > 360 then CC.Direction = CC.Direction - 360; end
            if CC.Direction < 0 then CC.Direction = CC.Direction + 360; end
        end
        
        if CC.Action.TurnRight then
            CC.Direction = CC.Direction - CC.keyboardTurnSpeed;
            if CC.Direction > 360 then CC.Direction = CC.Direction - 360; end
            if CC.Direction < 0 then CC.Direction = CC.Direction + 360; end	
        end
    end

	if CC.Action.MoveForward then
		local xf, yf, zf = SceneMachine.Renderer.projectionFrame:GetCameraForward();
		CC.Position.x = CC.Position.x + (xf * CC.moveSpeed * CC.acceleration)
		CC.Position.y = CC.Position.y + (yf * CC.moveSpeed * CC.acceleration)
		CC.Position.z = CC.Position.z + (zf  * CC.moveSpeed * CC.acceleration)
	end

	if CC.Action.MoveBackward then
		local xf, yf, zf = SceneMachine.Renderer.projectionFrame:GetCameraForward();
		CC.Position.x = CC.Position.x - (xf * CC.moveSpeed * CC.acceleration);
		CC.Position.y = CC.Position.y - (yf * CC.moveSpeed * CC.acceleration);
		CC.Position.z = CC.Position.z - (zf * CC.moveSpeed * CC.acceleration);
	end
	if CC.Action.StrafeLeft then
		CC.Position.x = CC.Position.x + (CC.moveSpeed * CC.acceleration * math.cos(DegreeToRadian(CC.Direction + 90)));
		CC.Position.y = CC.Position.y + (CC.moveSpeed * CC.acceleration * math.sin(DegreeToRadian(CC.Direction + 90)));
	end
	if CC.Action.StrafeRight then
		CC.Position.x = CC.Position.x + (CC.moveSpeed * CC.acceleration * math.cos(DegreeToRadian(CC.Direction - 90)));
		CC.Position.y = CC.Position.y + (CC.moveSpeed * CC.acceleration * math.sin(DegreeToRadian(CC.Direction - 90)));
	end

    SceneMachine.Camera.X = CC.Position.x;
    SceneMachine.Camera.Y = CC.Position.y;
    SceneMachine.Camera.Z = CC.Position.z;
    
    if (CC.RMBPressed == true) then
		local x, y = GetCursorPosition();
		local xDiff = x - CC.RMBPrevious.x;
		local yDiff = y - CC.RMBPrevious.y;
		CC.RMBPrevious.x = x;
		CC.RMBPrevious.y = y;

		-- if camera is in flight mode then handle that --
		SceneMachine.Camera.Yaw = SceneMachine.Camera.Yaw - rad(xDiff * CC.mouseTurnSpeed);
		SceneMachine.Camera.Pitch = SceneMachine.Camera.Pitch - rad(yDiff * CC.mouseTurnSpeed);
        CC.Direction = CC.Direction - xDiff * CC.mouseTurnSpeed;
        CC.Pitch = CC.Pitch - yDiff * CC.mouseTurnSpeed;
	else
        SceneMachine.Camera.Yaw = rad(CC.Direction);
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

function DegreeToRadian(angle)
    return (math.pi * angle / 180.0);
end