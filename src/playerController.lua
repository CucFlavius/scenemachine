SceneMachine.Player = SceneMachine.Player or {}
local Player = SceneMachine.Player;
SceneMachine.World = SceneMachine.World or {}
local World = SceneMachine.World;
local CC = SceneMachine.CameraController;

Player.Action = {};						-- the collection of player action booleans
Player.Action.TurnLeft = false;			-- true if turn right key is pressed
Player.Action.TurnRight = false;		-- true if turn right key is pressed
Player.Action.MoveForward = false;		-- true if move forward key pressed
Player.Action.MoveBackward = false;		-- true if move backward key is pressed
Player.Action.StrafeLeft = false;		-- true if strafe left key is pressed
Player.Action.StrafeRight = false;		-- true if strafe right key is pressed

----------------------------------
--			Variables	 		--
----------------------------------
Player.FoV = 70;						-- Field of View in degrees
Player.Direction = 180;					-- The start angle at which the player is looking in degrees ( in degrees )
Player.Pitch = 0;
Player.Position = {};					-- the player position table
Player.Position.x = 0; 				-- player x start position on map
Player.Position.y = 0; 				-- player y start position on map
Player.Position.z = 1;
Player.Position.xCell = 0;				-- player x position relative to the current cell ( 0 to 1 )
Player.Position.yCell = 0;				-- player y position relative to the current cell ( 0 to 1 )
Player.turnSpeed = 1;--0.4;					-- player turn speed
Player.moveSpeed = 0.05;--0.01;				-- player movement speed

--------------------------------------
--			Keyboard Input			--
--------------------------------------
function Player.Input(key, pressed)
	if key == "A" then
		Player.Action.TurnLeft = pressed;
	end
	if key == "D" then
		Player.Action.TurnRight = pressed;
	end
	if key == "W" then
		Player.Action.MoveForward = pressed;
	end
	if key == "S" then
		Player.Action.MoveBackward = pressed;
	end
	if key == "Q" then
		Player.Action.StrafeLeft = pressed;
	end
	if key == "E" then
		Player.Action.StrafeRight = pressed;
	end
	--if key == "Z" then
		--if pressed == true then -- ignore on key released
			--Player.Interact();
		--end
	--end
	--if key == "F" then
		--Player.Shoot(pressed);
	--end	
 end

function Player.Initialize()
    SceneMachine.Input.AddKeyBind("W", function() Player.Action.MoveForward = true end, function() Player.Action.MoveForward = false end);
    SceneMachine.Input.AddKeyBind("S", function() Player.Action.MoveBackward = true end, function() Player.Action.MoveBackward = false end);
    SceneMachine.Input.AddKeyBind("A", function() Player.Action.TurnLeft = true end, function() Player.Action.TurnLeft = false end);
    SceneMachine.Input.AddKeyBind("D", function() Player.Action.TurnRight = true end, function() Player.Action.TurnRight = false end);
    SceneMachine.Input.AddKeyBind("Q", function() Player.Action.StrafeLeft = true end, function() Player.Action.StrafeLeft = false end);
    SceneMachine.Input.AddKeyBind("E", function() Player.Action.StrafeRight = true end, function() Player.Action.StrafeRight = false end);
    SceneMachine.Input.Initialize();

	-- calculate speeds based on update interval --
	Player.turnSpeed = Player.turnSpeed * (SceneMachine.UPDATE_INTERVAL * 100);
	Player.moveSpeed = Player.moveSpeed * (SceneMachine.UPDATE_INTERVAL * 100);
end

function DegreeToRadian(angle)
    return (math.pi * angle / 180.0);
end

function Player.Update()
    if CC.LMBPressed == false then
	    if Player.Action.TurnLeft then
            Player.Direction = Player.Direction + Player.turnSpeed;
            if Player.Direction > 360 then Player.Direction = Player.Direction - 360; end
            if Player.Direction < 0 then Player.Direction = Player.Direction + 360; end
        end
        
        if Player.Action.TurnRight then
            Player.Direction = Player.Direction - Player.turnSpeed;
            if Player.Direction > 360 then Player.Direction = Player.Direction - 360; end
            if Player.Direction < 0 then Player.Direction = Player.Direction + 360; end	
        end
    end

	if Player.Action.MoveForward then
		local xf, yf, zf = SceneMachine.Renderer.projectionFrame:GetCameraForward();
		local xDestination = Player.Position.x + (xf * Player.moveSpeed)--(Player.moveSpeed * math.cos(DegreeToRadian(Player.Direction + 180)));
		local yDestination = Player.Position.y + (yf * Player.moveSpeed) --(Player.moveSpeed * math.sin(DegreeToRadian(Player.Direction + 180)));
		local zDestination = Player.Position.z + (zf  * Player.moveSpeed)--(Player.moveSpeed * math.sin(DegreeToRadian(Player.Pitch)));
		--local xDestinationPerpendicular = 0;
		--local yDestinationPerpendicular = 0;

		--if Zee.Worgenstein.CheckCollision(xDestination, yDestination) == false then
			Player.Position.x = xDestination;
			Player.Position.y = yDestination;
			Player.Position.z = zDestination;	-- only for fly
		--else	
		--	Zee.Worgenstein.Slide(xDestination, yDestination);
		--end
	end

	if Player.Action.MoveBackward then
		local xf, yf, zf = SceneMachine.Renderer.projectionFrame:GetCameraForward();
		local xDestination = Player.Position.x - (xf * Player.moveSpeed)--(Player.moveSpeed * math.cos(DegreeToRadian(Player.Direction + 180)));
		local yDestination = Player.Position.y - (yf * Player.moveSpeed) --(Player.moveSpeed * math.sin(DegreeToRadian(Player.Direction + 180)));
		local zDestination = Player.Position.z - (zf  * Player.moveSpeed)--(Player.moveSpeed * math.sin(DegreeToRadian(Player.Pitch)));
		--if Zee.Worgenstein.CheckCollision(xDestination, yDestination) == false then
			Player.Position.x = xDestination;
			Player.Position.y = yDestination;
			Player.Position.z = zDestination;	-- only for fly
		--else	
		--	Zee.Worgenstein.Slide(xDestination, yDestination);
		--end
	end
	if Player.Action.StrafeLeft then
		local xDestination = Player.Position.x + (Player.moveSpeed * math.cos(DegreeToRadian(Player.Direction + 90)));
		local yDestination = Player.Position.y + (Player.moveSpeed * math.sin(DegreeToRadian(Player.Direction + 90)));
		--if Zee.Worgenstein.CheckCollision(xDestination, yDestination) == false then
			Player.Position.x = xDestination;
			Player.Position.y = yDestination;
		--end
	end
	if Player.Action.StrafeRight then
		local xDestination = Player.Position.x + (Player.moveSpeed * math.cos(DegreeToRadian(Player.Direction - 90)));
		local yDestination = Player.Position.y + (Player.moveSpeed * math.sin(DegreeToRadian(Player.Direction - 90)));
		--if Zee.Worgenstein.CheckCollision(xDestination, yDestination) == false then
			Player.Position.x = xDestination;
			Player.Position.y = yDestination;
		--end
	end

	-- gravity :P --
	--local h = World.SampleHeight(sampleX, sampleY);
    --Player.Position.z = h - 1;

	-- update player cell position (relative to a cell)
	Player.Position.xCell = Player.Position.x - math.floor(Player.Position.x);
	Player.Position.yCell = Player.Position.y - math.floor(Player.Position.y);
end