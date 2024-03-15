
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
    };


	setmetatable(v, Camera)
	return v
end

function Camera:GetGizmoType()
    return Gizmos.Type.Camera;
end

function Camera:GetFoV()
    return self.fov;
end

function Camera:SetFoV(fov)
    self.fov = fov;
end

function Camera:GetNearClip()
    return self.nearClip;
end

function Camera:SetNearClip(near)
    self.nearClip = near;
end

function Camera:GetFarClip()
    return self.farClip;
end

function Camera:SetFarClip(far)
    self.farClip = far;
end

function Camera:Select()
    if (not self.selected) then
        self.selected = true;
    end
end

function Camera:Deselect()
    if (self.selected) then
        self.selected = false;
    end
end