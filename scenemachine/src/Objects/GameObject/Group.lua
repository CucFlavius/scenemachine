
SceneMachine.GameObjects.Group = {};

local Vector3 = SceneMachine.Vector3;
local Object = SceneMachine.GameObjects.Object;

--- @class Group : Object
local Group = SceneMachine.GameObjects.Group;

Group.__index = Group;
setmetatable(Group, Object)

--- Creates a new Group object.
---@param name string? (optional) The name of the group. Defaults to "NewGroup".
---@return Group v The newly created Group object.
function Group:New(name, scene)
    local v = 
    {
        name = name or "NewGroup",
        id = math.random(99999999);
        visible = true,
        frozen = false,
        isRenamed = false,
        type = Object.Type.Group,
        position = Vector3:New(),
        rotation = Vector3:New(),
        scale = 1,
        minX = -0.5,
        minY = -0.5,
        minZ = -0.5,
        maxX = 0.5,
        maxY = 0.5,
        maxZ = 0.5,
        scene = scene
    };

	setmetatable(v, Group)
	return v
end

--- Selects the group.
function Group:Select()
    if (not self.selected) then
        self.selected = true;
        -- TODO: This isn't doing anything for some reason
        --local objects = SM.loadedScene:GetChildObjects(self.id);
        --Group:FitObjects(objects);
    end
end

--- Deselects the group.
function Group:Deselect()
    if (self.selected) then
        self.selected = false;
    end
end

function Group:GetActiveBoundingBox()
    return self.minX, self.minY, self.minZ, self.maxX, self.maxY, self.maxZ;
end

--- Returns the gizmo type for the object.
--- @return Object.GizmoType gizmoType The gizmo type.
function Group:GetGizmoType()
    return Object.GizmoType.Object;
end

function Group:FitObjects(objects)
    if (not objects or #objects == 0) then
        self.minX, self.minY, self.minZ, self.maxX, self.maxY, self.maxZ = -0.5, -0.5, -0.5, 0.5, 0.5, 0.5;
    elseif (#objects == 1) then
        self.minX, self.minY, self.minZ, self.maxX, self.maxY, self.maxZ = objects[1]:GetActiveBoundingBox();
        self.position = objects[1]:GetPosition();
        self.rotation = objects[1]:GetRotation();
    else
        local xMin, yMin, zMin, xMax, yMax, zMax = 100000, 100000, 100000, -100000, -100000, -100000;
        for i = 1, #objects do
            local object = objects[i];
            local xmin, ymin, zmin, xmax, ymax, zmax = 0, 0, 0, 0, 0, 0;
            if (object:GetGizmoType() == Object.GizmoType.Object) then
                xmin, ymin, zmin, xmax, ymax, zmax = object:GetActiveBoundingBox();
                xmin = xmin or 0; ymin = ymin or 0; zmin = zmin or 0;
                xmax = xmax or 0; ymax = ymax or 0; zmax = zmax or 0;
                local bbCenter = {(xmax - xmin) / 2, (ymax - ymin) / 2, (zmax - zmin) / 2};
                xmin = -bbCenter[1];
                ymin = -bbCenter[2];
                zmin = -bbCenter[3];
                xmax = bbCenter[1];
                ymax = bbCenter[2];
                zmax = bbCenter[3];
            elseif (object:GetGizmoType() == Object.GizmoType.Camera) then
                xmin = 0;
                ymin = 0;
                zmin = 0;
                xmax = 0;
                ymax = 0;
                zmax = 0;
            end

            local Pos = object:GetWorldPosition();
            local Rot = object:GetWorldRotation();
            local Scale = object:GetWorldScale();

            local corners = {
                Vector3:New(xmin, ymin, zmin),
                Vector3:New(xmin, ymin, zmax),
                Vector3:New(xmin, ymax, zmin),
                Vector3:New(xmin, ymax, zmax),
                Vector3:New(xmax, ymin, zmin),
                Vector3:New(xmax, ymin, zmax),
                Vector3:New(xmax, ymax, zmin),
                Vector3:New(xmax, ymax, zmax)
            }

            for _, corner in ipairs(corners) do
                corner:RotateAroundPivot(Vector3.zero, Rot);
                -- Update minimum bounds
                xMin = math.min(xMin, corner.x * Scale + Pos.x);
                yMin = math.min(yMin, corner.y * Scale + Pos.y);
                zMin = math.min(zMin, corner.z * Scale + Pos.z);
                
                -- Update maximum bounds
                xMax = math.max(xMax, corner.x * Scale + Pos.x);
                yMax = math.max(yMax, corner.y * Scale + Pos.y);
                zMax = math.max(zMax, corner.z * Scale + Pos.z);
            end
        end
        
        self.minX, self.minY, self.minZ, self.maxX, self.maxY, self.maxZ = xMin, yMin, zMin, xMax, yMax, zMax;

        self.position = Vector3:New(xMin + (xMax - xMin) / 2, yMin + (yMax - yMin) / 2, zMin + (zMax - zMin) / 2);
        self.rotation = Vector3:New(0, 0, 0);
    end
end

--- Shows the group.
function Group:Show()
    self.visible = true;
    local objects = self.scene:GetChildObjectsRecursive(self.id);
    if (objects) then
        for i = 1, #objects, 1 do
            objects[i]:Show();
        end
    end
end

--- Hides the group.
function Group:Hide()
    self.visible = false;
    local objects = self.scene:GetChildObjectsRecursive(self.id);
    if (objects) then
        for i = 1, #objects, 1 do
            objects[i]:Hide();
        end
    end
end

--- Freezes the group.
--- Makes it unselectable in the scene viewport.
function Group:Freeze()
    self.frozen = true;
    local objects = self.scene:GetChildObjectsRecursive(self.id);
    if (objects) then
        for i = 1, #objects, 1 do
            objects[i]:Freeze();
        end
    end
end

--- Unfreezes the group.
--- Makes it selectable in the scene viewport.
function Group:Unfreeze()
    self.frozen = false;
    local objects = self.scene:GetChildObjectsRecursive(self.id);
    if (objects) then
        for i = 1, #objects, 1 do
            objects[i]:Unfreeze();
        end
    end
end