local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local SM = SceneMachine.Editor.SceneManager;

SceneMachine.Actions.Destroy = {};

local Action = SceneMachine.Actions.Action;
local Destroy = SceneMachine.Actions.Destroy;
Destroy.__index = Destroy;
setmetatable(Destroy, Action)

function Destroy:New(objects)
	local v = 
    {
        type = Action.Type.Destroy,
		memorySize = 1,
		memoryUsage = 0,
		objects = {},
    };

	setmetatable(v, Destroy)

	-- save object states
	for i = 1, #objects, 1 do
		local obj = objects[i];
		v.objects[i] = obj;
	end

	v.memoryUsage = #objects * v.memorySize;

	return v
end

function Destroy:Finish()

end

function Destroy:Undo()
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		SM.UndeleteObject_internal(obj);
		--[[
		local pos = obj:GetPosition();
		local rot = obj:GetRotation();

		local newObj;
		if (obj.type == SceneMachine.ObjectType.Model) then
			newObj = SM.CreateObject(obj.fileID, obj.name, pos.x, pos.y, pos.z);
		elseif (obj.type == SceneMachine.ObjectType.Creature) then
			newObj = SM.CreateCreature(obj.displayID, obj.name, pos.x, pos.y, pos.z);
		elseif (obj.type == SceneMachine.ObjectType.Character) then
			newObj = SM.CreateCharacter(pos.x, pos.y, pos.z);
		else
			print("Destroy:Undo() Unsupported obj.type : " .. obj.type);
			return;
		end
		newObj:SetRotation(rot.x, rot.y, rot.z);
		newObj:SetScale(obj:GetScale());
		newObj:SetAlpha(obj:GetAlpha());
		self.objects[i] = newObj;
		--]]
	end
end

function Destroy:Redo()
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		SM.DeleteObject_internal(obj);
	end
end