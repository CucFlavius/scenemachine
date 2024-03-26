
SceneMachine.GameObjects.Group = {};

local Vector3 = SceneMachine.Vector3;
local Gizmos = SceneMachine.Gizmos;
local Object = SceneMachine.GameObjects.Object;

--- @class Group : Object
local Group = SceneMachine.GameObjects.Group;

Group.__index = Group;
setmetatable(Group, Object)

--- Creates a new Group object.
---@param name string? (optional) The name of the group. Defaults to "NewGroup".
---@return Group v The newly created Group object.
function Group:New(name)
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
    };

	setmetatable(v, Group)
	return v
end

--- Selects the group.
function Group:Select()
    if (not self.selected) then
        self.selected = true;
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
--- @return Gizmos.Type gizmoType The gizmo type.
function Group:GetGizmoType()
    return Gizmos.Type.Object;
end

function Group:FitObjects(objects)
    if (#objects == 0) then
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
            if (object:GetGizmoType() == Gizmos.Type.Object) then
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
            elseif (object:GetGizmoType() == Gizmos.Type.Camera) then
                xmin = 0;
                ymin = 0;
                zmin = 0;
                xmax = 0;
                ymax = 0;
                zmax = 0;
            end

            -- Get position of the object
            local Pos = object:GetWorldPosition();
            local Scale = object:GetWorldScale();

            -- Update minimum bounds
            xMin = math.min(xMin, xmin * Scale + Pos.x);
            yMin = math.min(yMin, ymin * Scale + Pos.y);
            zMin = math.min(zMin, zmin * Scale + Pos.z);
            
            -- Update maximum bounds
            xMax = math.max(xMax, xmax * Scale + Pos.x);
            yMax = math.max(yMax, ymax * Scale + Pos.y);
            zMax = math.max(zMax, zmax * Scale + Pos.z);
        end

        self.minX, self.minY, self.minZ, self.maxX, self.maxY, self.maxZ = xMin, yMin, zMin, xMax, yMax, zMax;

        self.position = Vector3:New(xMin + (xMax - xMin) / 2, yMin + (yMax - yMin) / 2, zMin + (zMax - zMin) / 2);
        self.rotation = Vector3:New(0, 0, 0);
    end
end