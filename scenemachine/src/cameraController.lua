local CC = SceneMachine.CameraController;
local Player = SceneMachine.Player;
local Renderer = SceneMachine.Renderer;
local Gizmos = SceneMachine.Gizmos;
local Input = SceneMachine.Input;
local Camera = SceneMachine.Camera;
local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;

----------------------------------
--			CC State	 		--
----------------------------------
CC.Action = {};						-- the collection of player action booleans
CC.RMBPrevious = {};
CC.RMBPressed = false;
CC.Action.TurnLeft = false;			-- true if turn right key is pressed
CC.Action.TurnRight = false;		-- true if turn right key is pressed
CC.Action.MoveForward = false;		-- true if move forward key pressed
CC.Action.MoveBackward = false;		-- true if move backward key is pressed
CC.Action.MoveUp = false;
CC.Action.MoveDown = false;
CC.Action.StrafeLeft = false;		-- true if strafe left key is pressed
CC.Action.StrafeRight = false;		-- true if strafe right key is pressed
CC.Action.ShiftSpeed = false;
CC.Focus = 
{
	startPos = Vector3:New(0, 0, 0);
	endPos = Vector3:New(0, 0, 0);
	distance = 0;
	startTime = 0;
	focusing = false;
};

----------------------------------
--			Variables	 		--
----------------------------------
CC.Direction = 180;					-- The start angle at which the player is looking in degrees ( in degrees )
CC.Pitch = 0;
CC.position = Vector3:New(0, 0, 1);	-- start position
CC.keyboardTurnSpeed = 10;
CC.moveSpeed = 10;
CC.acceleration = 1.0;
CC.maxAcceleration = 12.0;
CC.mouseTurnSpeed = 0.2;

--------------------------------------
--			Keyboard Input			--
--------------------------------------
function CC.Initialize()
    SceneMachine.Input.Initialize();
end

local twoPi = 2 * math.pi
local function clampAngle(angle)
    angle = angle % twoPi  -- Ensure the angle is within [0, 2π)
    if angle < 0 then
        angle = angle + twoPi  -- Make sure the angle is positive
    end
    return angle
end

function CC.Update(deltaTime)
	-- don't move when marquee selecting
	if (Gizmos.marqueeOn) then
		return
	end;

	if (CC.Action.ShiftSpeed == true) then
		CC.acceleration = CC.acceleration + deltaTime;
		CC.acceleration = math.min(CC.maxAcceleration, CC.acceleration);
	else
		CC.acceleration = 1.0;
	end

    if CC.RMBPressed == false then
	    if CC.Action.TurnLeft then
            CC.Direction = CC.Direction + CC.keyboardTurnSpeed * deltaTime * 5;
            if CC.Direction > 360 then CC.Direction = CC.Direction - 360; end
            if CC.Direction < 0 then CC.Direction = CC.Direction + 360; end
        end
        
        if CC.Action.TurnRight then
            CC.Direction = CC.Direction - CC.keyboardTurnSpeed * deltaTime * 5;
            if CC.Direction > 360 then CC.Direction = CC.Direction - 360; end
            if CC.Direction < 0 then CC.Direction = CC.Direction + 360; end	
        end
    end

	if CC.Action.MoveForward then
		local v = Vector3:New();
		v:SetVector3(Camera.forward);
		v:Scale(CC.moveSpeed * CC.acceleration * deltaTime);
		CC.position:Add(v);
	end
	if CC.Action.MoveBackward then
		local v = Vector3:New();
		v:SetVector3(Camera.forward);
		v:Scale(CC.moveSpeed * CC.acceleration * deltaTime);
		CC.position:Subtract(v);
	end
	if CC.Action.StrafeLeft then
		local cosDir = math.cos(DegreeToRadian(CC.Direction + 90))
		local sinDir = math.sin(DegreeToRadian(CC.Direction + 90));
		CC.position.x = CC.position.x + (CC.moveSpeed * deltaTime * CC.acceleration * cosDir);
		CC.position.y = CC.position.y + (CC.moveSpeed * deltaTime * CC.acceleration * sinDir);
	end
	if CC.Action.StrafeRight then
		local cosDir = math.cos(DegreeToRadian(CC.Direction - 90))
		local sinDir = math.sin(DegreeToRadian(CC.Direction - 90));
		CC.position.x = CC.position.x + (CC.moveSpeed * deltaTime * CC.acceleration * cosDir);
		CC.position.y = CC.position.y + (CC.moveSpeed * deltaTime * CC.acceleration * sinDir);
	end
	if CC.Action.MoveUp then
		CC.position.z = CC.position.z + (CC.moveSpeed * deltaTime * CC.acceleration);
	end
	if CC.Action.MoveDown then
		CC.position.z = CC.position.z - (CC.moveSpeed * deltaTime * CC.acceleration);
	end

	SceneMachine.Camera.position:SetVector3(CC.position);
    
    if (CC.RMBPressed == true) then
		local xDiff = Input.mouseXRaw - CC.RMBPrevious.x;
		local yDiff = Input.mouseYRaw - CC.RMBPrevious.y;
		CC.RMBPrevious.x = Input.mouseXRaw;
		CC.RMBPrevious.y = Input.mouseYRaw;

		-- if camera is in flight mode then handle that --
		SceneMachine.Camera.eulerRotation.x = clampAngle(SceneMachine.Camera.eulerRotation.x - rad(xDiff * CC.mouseTurnSpeed));
		SceneMachine.Camera.eulerRotation.y = clampAngle(SceneMachine.Camera.eulerRotation.y - rad(yDiff * CC.mouseTurnSpeed));
        CC.Direction = CC.Direction - xDiff * CC.mouseTurnSpeed;
        CC.Pitch = CC.Pitch - yDiff * CC.mouseTurnSpeed;
	else
        SceneMachine.Camera.eulerRotation.x = clampAngle(rad(CC.Direction));
    end

	-- handle focus
	if (CC.Action.MoveForward or CC.Action.MoveBackward or CC.Action.StrafeLeft or CC.Action.StrafeRight or CC.Action.MoveUp or CC.Action.MoveDown) then
		-- cancel focus if any movement key is pressed
		CC.Focus.focusing = false;
	end

	if (CC.Focus.focusing) then
		-- animate focus
		local speed = CC.Focus.distance * 2.0;
		local distCovered = (SceneMachine.time - CC.Focus.startTime) * speed;
		local fractionOfJourney = 0;
		if (CC.Focus.distance ~= 0) then
			fractionOfJourney = distCovered / CC.Focus.distance;
		end

		CC.position:Lerp(CC.Focus.startPos, CC.Focus.endPos, fractionOfJourney);

		if (fractionOfJourney >= 1) then
			CC.Focus.focusing = false;
		end
	end
end

function CC.OnRMBDown()
	CC.RMBPressed = true;
	CC.RMBPrevious.x = Input.mouseXRaw;
	CC.RMBPrevious.y = Input.mouseYRaw;
end

function CC.OnRMBUp()
	CC.RMBPressed = false;
end

function CC.FocusObjects(objects)
	if (#objects == 0) then
		return
	end

	if (#objects == 1) then
		CC.FocusObject(objects[1]);
	end

	-- TODO: Focus multiple objects
end

function CC.FocusObject(object)
	if (object == nil) then
		return;
	end

	-- set start position
	CC.Focus.startPos:SetVector3(Camera.position);

	local objectPos = object:GetPosition();--Vector3
	local objectScale = object:GetScale();--Float
	local vector = Vector3:New();
	vector:SetVector3(Camera.eulerRotation);
	vector:EulerToDirection();
	vector:Normalize();

	local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
	local objectCenter = Vector3:New( objectPos.x * objectScale, objectPos.y * objectScale, (objectPos.z + (zMax / 2)) * objectScale );
	local radius = math.max(xMax, math.max(yMax, zMax));
	local dist = radius / (math.sin(Camera.fov) * 0.5);
	vector:Scale(dist);
	objectCenter:Subtract(vector);

	-- set end position
	CC.Focus.endPos:SetVector3(objectCenter);

	CC.Focus.startTime = SceneMachine.time;

	-- calculate the journey length.
	CC.Focus.distance = Vector3.ManhattanDistance(CC.Focus.startPos, CC.Focus.endPos);

	CC.Focus.focusing = true;
end

function DegreeToRadian(angle)
    return (math.pi * angle / 180.0);
end