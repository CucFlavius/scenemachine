local Editor = SceneMachine.Editor;
local Renderer = SceneMachine.Renderer;
local Camera = SceneMachine.Camera;
local SM = Editor.SceneManager;
local Renderer = SceneMachine.Renderer;
local PM = Editor.ProjectManager;
local Input = SceneMachine.Input;

local Vector2 = SceneMachine.Vector2;
local Vector3 = SceneMachine.Vector3;
local Vector4 = SceneMachine.Vector4;
local Matrix = SceneMachine.Matrix;
local Math = SceneMachine.Math;
local Ray = SceneMachine.Ray;

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
    Camera.viewMatrix:LookAt(Camera.position, Camera.position + Camera.forward, Vector3.up);

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

-------------------------------------------------------
-- Transform mouse coords from renderer relative to  --
-- device coords (between -0.5 and +0.5) 0 at center --
-------------------------------------------------------
--  x+0.5            x-0.5         
--  y+0.5            y+0.5
--
--          x=0.0
--          y=0.0
--
--  x+0.5            x-0.5         
--  y-0.5            y-0.5
-------------------------------------------------------
local function MouseToNormalizedDeviceCoords(mouseX, mouseY, width, height)
    local x = 0.5 - mouseX / width;
    local y = mouseY / height - 0.5;
    return Vector2:New(x, y);
end

local function NDCToClipCoords(ray_nds)
    return Vector4:New(ray_nds.x, ray_nds.y, -1.0, 1.0 );
end

local function ClipToEye(ray_clip, projection_matrix)
    local projectionInv = Matrix:New();
    projectionInv:SetMatrix(projection_matrix);
    projectionInv:Invert();

    local ray_eye = ray_clip:MultiplyMatrix(projectionInv);
    return Vector4:New( ray_eye.x, ray_eye.y, -1.0, 0.0 );
end

local function EyeToRayVector(ray_eye, view_matrix)
    local viewInv = Matrix:New();
    viewInv:SetMatrix(view_matrix);
    viewInv:Invert();
    ray_eye:MultiplyMatrix(viewInv);
    local ray_wor = Vector3:New();
    ray_wor:SetVector3(ray_eye);
    ray_wor:Normalize();
    return ray_wor;
end

function Camera.GetMouseRay()
    local ndc = MouseToNormalizedDeviceCoords(Input.mouseX, Input.mouseY, Camera.width, Camera.height);
    local clip = NDCToClipCoords(ndc);
    local eye = ClipToEye(clip, Camera.projectionMatrix);
    local direction = EyeToRayVector(eye, Camera.viewMatrix);

    local origin = Camera.position;
    local mouseRay = Ray:New(origin, direction);

    return mouseRay;
end