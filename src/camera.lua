SceneMachine = SceneMachine or {}
SceneMachine.Camera = {}
SceneMachine.Renderer = SceneMachine.Renderer or {}
SceneMachine.Editor = SceneMachine.Editor or {};
local Editor = SceneMachine.Editor;
local Renderer = SceneMachine.Renderer;
local Camera = SceneMachine.Camera;
Editor.SceneManager = Editor.SceneManager or {};
local SM = Editor.SceneManager;
local Renderer = SceneMachine.Renderer;
Editor.ProjectManager = Editor.ProjectManager or {};
local PM = Editor.ProjectManager;

Camera.X = 0;
Camera.Y = 0;
Camera.Z = 0;		-- topdown
Camera.Yaw = 0;
Camera.Pitch = 0;
Camera.Roll = 0;
Camera.ProjectionPlaneOffset = 1.2;

Camera.planePositionX = 0;
Camera.planePositionY = 0;
Camera.planePositionZ = 0;
Camera.planeNormalX = 0;
Camera.planeNormalY = 0;
Camera.planeNormalZ = 0;

function Camera.Update()
    Renderer.projectionFrame:SetCameraPosition(Camera.X, Camera.Y, Camera.Z);
    --print(Camera.X .. " " .. Camera.Y .. " " .. Camera.Z);
    Renderer.projectionFrame:SetCameraOrientationByYawPitchRoll(Camera.Yaw, Camera.Pitch, Camera.Roll);

    -- Calculate camera near plane -- 
	Camera.planeNormalX, Camera.planeNormalY, Camera.planeNormalZ = Renderer.projectionFrame:GetCameraForward();
	Camera.planePositionX = Camera.X + (Camera.planeNormalX * Camera.ProjectionPlaneOffset);
	Camera.planePositionY = Camera.Y + (Camera.planeNormalY * Camera.ProjectionPlaneOffset);
	Camera.planePositionZ = Camera.Z + (Camera.planeNormalZ * Camera.ProjectionPlaneOffset);

    -- remember current camera settings --
    if (SM.loadedSceneIndex ~= -1) then
        local scene = PM.currentProject.scenes[SM.loadedSceneIndex];
        if (scene ~= nil) then
            scene.lastCameraPositionX = Camera.X;
            scene.lastCameraPositionY = Camera.Y;
            scene.lastCameraPositionZ = Camera.Z;
            scene.lastCameraYaw = Camera.Yaw;
            scene.lastCameraPitch = Camera.Pitch;
            scene.lastCameraRoll = Camera.Roll;
        end
    end
end