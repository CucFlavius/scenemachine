local Editor = SceneMachine.Editor;
local Renderer = SceneMachine.Renderer;
local Camera = SceneMachine.Camera;
local SM = Editor.SceneManager;
local Renderer = SceneMachine.Renderer;
local PM = Editor.ProjectManager;
local Vector3 = SceneMachine.Vector3;
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

-- TODO : convert these to use the new Vector3/4 classes
local function MouseToNormalizedDeviceCoords(mouseX, mouseY, width, height)
    local x = 0.5 - mouseX / width;
    local y = mouseY / height - 0.5;
    return { x, y };
end

local function NDCToClipCoords(ray_nds)
    return { ray_nds[1], ray_nds[2], -1.0, 1.0 };
end

local function ClipToEye(ray_clip, projection_matrix)
    projection_matrix:Invert();
    local ray_eye = projection_matrix:MultiplyVector4(ray_clip);
    return { ray_eye[1], ray_eye[2], -1.0, 0.0 };
end

local function EyeToRayVector(ray_eye, view_matrix)
    view_matrix:Invert();
    local ray_wor = view_matrix:MultiplyVector4(ray_eye);
    --Vector3 ray_wor = (ray_eye * view_matrix.Inverted()).Xyz;
    --ray_wor.Normalize();
    ray_wor = Math.normalizeVector3(ray_wor);
    return Vector3:New(ray_wor[1], ray_wor[2], ray_wor[3]);
end

local function UnprojectMouse(mouseX, mouseY, screenWidth, screenHeight, cameraProjection, cameraView)
    local ndc = MouseToNormalizedDeviceCoords(mouseX, mouseY, screenWidth, screenHeight);
    local clip = NDCToClipCoords(ndc);
    local eye = ClipToEye(clip, cameraProjection);
    local rayvec = EyeToRayVector(eye, cameraView);
    return rayvec;
end

function Camera.GetMouseRay()
    local curX, curY = GetCursorPosition();
    local frameXMin = Renderer.projectionFrame:GetLeft();
    local frameYMin = Renderer.projectionFrame:GetBottom();
    local frameXMax = Renderer.projectionFrame:GetRight();
    local frameYMax = Renderer.projectionFrame:GetTop();

    local relativeX, relativeY = curX - frameXMin, curY - frameYMin;
    local direction = UnprojectMouse(relativeX, relativeY, Camera.width, Camera.height, Camera.projectionMatrix, Camera.viewMatrix);
    local origin = Camera.position;
    local mouseRay = Ray:New(origin, direction);

    return mouseRay;
end