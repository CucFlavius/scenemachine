
SceneMachine.GameObjects.Camera = {};

local Vector3 = SceneMachine.Vector3;
local Object = SceneMachine.GameObjects.Object;
local Gizmos = SceneMachine.Gizmos;

--- @class Camera : Object
local Camera = SceneMachine.GameObjects.Camera;

Camera.__index = Camera;
setmetatable(Camera, Object)

--- Creates a new Camera object.
--- @param name string? (optional) The name of the camera.
--- @param position Vector3? (optional) The position of the camera.
--- @param rotation Vector3? (optional) The rotation of the camera.
--- @param fov number The field of view of the camera.
--- @param nearClip number The near clipping plane of the camera.
--- @param farClip number The far clipping plane of the camera.
--- @return Camera v The newly created Camera object.
function Camera:New(name, position, rotation, fov, nearClip, farClip)
    local v = 
    {
        type = Object.Type.Camera,
        name = name or "NewCamera",
        position = position or Vector3:New(),
        rotation = rotation or Vector3:New(),
        id = math.random(99999999),
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

--- Returns the type of gizmo for the camera.
--- @return Gizmos.Type gizmoType The gizmo type.
function Camera:GetGizmoType()
    return Gizmos.Type.Camera;
end

--- Retrieves the field of view (FoV) value of the camera.
--- @return number fov The field of view value.
function Camera:GetFoV()
    return self.fov;
end

--- Sets the field of view (FOV) for the camera.
--- @param fov number The new field of view value.
function Camera:SetFoV(fov)
    self.fov = fov;
end

--- Retrieves the value of the near clip plane for the camera.
--- @return number nearClip The value of the near clip plane.
function Camera:GetNearClip()
    return self.nearClip;
end

--- Sets the value of the near clip plane for the camera.
---@param near number The new value for the near clip plane.
function Camera:SetNearClip(near)
    self.nearClip = near;
end

--- Retrieves the value of the far clip plane for the camera.
--- @return number farClip The value of the far clip plane.
function Camera:GetFarClip()
    return self.farClip;
end

--- Sets the far clip distance of the camera.
---@param far number The new far clip distance.
function Camera:SetFarClip(far)
    self.farClip = far;
end

--- Selects the camera.
function Camera:Select()
    if (not self.selected) then
        self.selected = true;
    end
end

--- Deselects the camera.
function Camera:Deselect()
    if (self.selected) then
        self.selected = false;
    end
end