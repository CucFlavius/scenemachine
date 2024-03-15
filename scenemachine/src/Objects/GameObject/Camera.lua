
SceneMachine.GameObjects.Camera = {};

local Vector3 = SceneMachine.Vector3;
local Object = SceneMachine.GameObjects.Object;
local Camera = SceneMachine.GameObjects.Camera;
local Gizmos = SceneMachine.Gizmos;

Camera.__index = Camera;
setmetatable(Camera, Object)

function Camera:New(name, position, rotation, fov, nearClip, farClip)
    local v = 
    {
        type = Object.Type.Camera,
        name = name or "NewObject",
        position = position or Vector3:New(),
        rotation = rotation or Vector3:New(),
        id = math.random(99999999);
        visible = true,
        frozen = false,
        isRenamed = false,
        fov = fov,
        nearClip = nearClip,
        farClip = farClip,
        gizmoType = Gizmos.Type.Camera,
    };


	setmetatable(v, Object)
	return v
end

function Object:GetFoV()
    return self.fov;
end

function Object:SetFoV(fov)
    self.fov = fov;
end

function Object:GetNearClip()
    return self.nearClip;
end

function Object:SetNearClip(near)
    self.nearClip = near;
end

function Object:GetFarClip()
    return self.farClip;
end

function Object:SetFarClip(far)
    self.farClip = far;
end
