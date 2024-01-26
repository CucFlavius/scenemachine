local Editor = SceneMachine.Editor;
local Renderer = SceneMachine.Renderer;
local Camera = SceneMachine.Camera;
local SM = Editor.SceneManager;
local Renderer = SceneMachine.Renderer;
local PM = Editor.ProjectManager;
local Vector3 = SceneMachine.Vector3;
local Matrix = SceneMachine.Matrix;

Camera.position = Vector3:New();
Camera.eulerRotation = Vector3:New();
Camera.forward = Vector3:New();
Camera.up = Vector3:New();
Camera.right = Vector3:New();
Camera.projectionPlaneOffset = 1.2;
Camera.planePosition = Vector3:New();
Camera.width = 100.0;
Camera.height = 100.0;
Camera.aspectRatio = 1.0;
Camera.fov = math.rad(70);
Camera.nearClip = 0.1;
Camera.farClip = 1000.0;

Camera.projectionMatrix = Matrix:New();
Camera.viewMatrix = Matrix:New();

function Camera.Update()
    Renderer.projectionFrame:SetCameraPosition(Camera.position:Get());
    Renderer.projectionFrame:SetCameraOrientationByYawPitchRoll(Camera.eulerRotation:Get());
    Renderer.projectionFrame:SetCameraFieldOfView(Camera.fov);
    Renderer.projectionFrame:SetCameraFarClip(Camera.farClip)
    Renderer.projectionFrame:SetCameraNearClip(Camera.nearClip);

    Camera.width = Renderer.projectionFrame:GetWidth();
    Camera.height = Renderer.projectionFrame:GetHeight();
    Camera.aspectRatio = Camera.width / Camera.height;

    Camera.forward:Set(Renderer.projectionFrame:GetCameraForward());
    Camera.up:Set(Renderer.projectionFrame:GetCameraUp());
    Camera.right:Set(Renderer.projectionFrame:GetCameraRight());

    Camera.projectionMatrix:CreatePerspectiveFieldOfView(Camera.fov, Camera.aspectRatio, 0.01, 1000);
    Camera.viewMatrix:LookAt(Camera.position, Camera.forward, Vector3.up);

    -- Calculate camera near plane -- 
    Camera.planePosition:SetVector3(Camera.forward);
    Camera.planePosition:Scale(Camera.projectionPlaneOffset);
    Camera.planePosition:Add(Camera.position);

    -- remember current camera settings --
    if (SM.loadedSceneIndex ~= -1 and SM.loadedScene ~= nil) then
        if (SM.loadedScene.lastCameraPosition == nil) then
            SM.loadedScene.lastCameraPosition = {};
        end
        SM.loadedScene.lastCameraPosition[1],SM.loadedScene.lastCameraPosition[2],SM.loadedScene.lastCameraPosition[3]  = Camera.position:Get();
        if (SM.loadedScene.lastCameraEuler == nil) then
            SM.loadedScene.lastCameraEuler = {};
        end
        SM.loadedScene.lastCameraEuler[1], SM.loadedScene.lastCameraEuler[2], SM.loadedScene.lastCameraEuler[3] = Camera.eulerRotation:Get();
    end
end