local Editor = SceneMachine.Editor;
local Renderer = SceneMachine.Renderer;
local Camera = SceneMachine.Camera;
local SM = Editor.SceneManager;
local Renderer = SceneMachine.Renderer;
local PM = Editor.ProjectManager;

Camera.X = 0;
Camera.Y = 0;
Camera.Z = 0;		-- topdown
Camera.Yaw = 0;
Camera.Pitch = 0;
Camera.Roll = 0;
Camera.ProjectionPlaneOffset = 1.2;
Camera.Forward = { 0, 0, 0 };
Camera.Up = { 0, 0, 0 };
Camera.Right = { 0, 0, 0 };

Camera.planePositionX = 0;
Camera.planePositionY = 0;
Camera.planePositionZ = 0;
Camera.planeNormalX = 0;
Camera.planeNormalY = 0;
Camera.planeNormalZ = 0;

Camera.projectionMatrix = SceneMachine.Matrix:New();
Camera.viewMatrix = SceneMachine.Matrix:New();

function Camera.Update()
    Renderer.projectionFrame:SetCameraPosition(Camera.X, Camera.Y, Camera.Z);
    --print(Camera.Yaw .. " " .. Camera.Pitch .. " " .. Camera.Roll);
    Renderer.projectionFrame:SetCameraOrientationByYawPitchRoll(Camera.Yaw, Camera.Pitch, Camera.Roll);

    local forwardX, forwardY, forwardZ = Renderer.projectionFrame:GetCameraForward();
    Camera.Forward[1] = forwardX;
    Camera.Forward[2] = forwardY;
    Camera.Forward[3] = forwardZ;

    local upX, upY, upZ = Renderer.projectionFrame:GetCameraUp();
    Camera.Up[1] = upX;
    Camera.Up[2] = upY;
    Camera.Up[3] = upZ;

    local rightX, rightY, rightZ = Renderer.projectionFrame:GetCameraRight();
    Camera.Right[1] = rightX;
    Camera.Right[2] = rightY;
    Camera.Right[3] = rightZ;

    -- Calculate camera near plane -- 
	Camera.planeNormalX, Camera.planeNormalY, Camera.planeNormalZ = Renderer.projectionFrame:GetCameraForward();
	Camera.planePositionX = Camera.X + (Camera.planeNormalX * Camera.ProjectionPlaneOffset);
	Camera.planePositionY = Camera.Y + (Camera.planeNormalY * Camera.ProjectionPlaneOffset);
	Camera.planePositionZ = Camera.Z + (Camera.planeNormalZ * Camera.ProjectionPlaneOffset);

    -- remember current camera settings --
    if (SM.loadedSceneIndex ~= -1) then
        if (SM.loadedScene ~= nil) then
            SM.loadedScene.lastCameraPositionX = Camera.X;
            SM.loadedScene.lastCameraPositionY = Camera.Y;
            SM.loadedScene.lastCameraPositionZ = Camera.Z;
            SM.loadedScene.lastCameraYaw = Camera.Yaw;
            SM.loadedScene.lastCameraPitch = Camera.Pitch;
            SM.loadedScene.lastCameraRoll = Camera.Roll;
        end
    end
end