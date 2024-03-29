local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;

SceneMachine.Actions.TransformObject = {};

local Action = SceneMachine.Actions.Action;

--- @class TransformObject : Action
local TransformObject = SceneMachine.Actions.TransformObject;

TransformObject.__index = TransformObject;
setmetatable(TransformObject, Action)

--- Creates a new TransformObject instance.
--- @param objects table A table containing the objects to transform.
--- @return TransformObject v The newly created TransformObject instance.
function TransformObject:New(objects)
	local v = 
	{
		type = Action.Type.TransformObject,
		memorySize = 8,
		memoryUsage = 0,
		objects = {},
		startPos = {},
		startRot = {},
		startScale = {},
		startAlpha = {},
	};

	setmetatable(v, TransformObject)

	-- save object states
	for i = 1, #objects, 1 do
		local obj = objects[i];
		v.objects[i] = obj;
		v.startPos[i] = Vector3:New(obj.position.x, obj.position.y, obj.position.z);
		v.startRot[i] = Vector3:New(obj.rotation.x, obj.rotation.y, obj.rotation.z);
		v.startScale[i] = obj:GetScale();
		if (obj:HasActor()) then
			v.startAlpha[i] = obj:GetAlpha();
		end
	end

	v.memoryUsage = #objects * v.memorySize;

	return v
end

--- Finish function to save object states
function TransformObject:Finish()
	self.endPos = {};
	self.endRot = {};
	self.endScale = {};
	self.endAlpha = {};
	-- save object states
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		self.endPos[i] = Vector3:New(obj.position.x, obj.position.y, obj.position.z);
		self.endRot[i] = Vector3:New(obj.rotation.x, obj.rotation.y, obj.rotation.z);
		self.endScale[i] = obj:GetScale();
		if (obj:HasActor()) then
			self.endAlpha[i] = obj:GetAlpha();
		end
	end
end

--- Undoes the transformation applied to the objects.
function TransformObject:Undo()
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		obj:SetPositionVector3(self.startPos[i]);
		obj:SetRotation(self.startRot[i].x, self.startRot[i].y, self.startRot[i].z);
		obj:SetScale(self.startScale[i]);
		if (obj:HasActor()) then
			obj:SetAlpha(self.startAlpha[i]);
		end
	end
end

--- Applies the transformation changes to the objects.
function TransformObject:Redo()
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		obj:SetPositionVector3(self.endPos[i]);
		obj:SetRotation(self.endRot[i].x, self.endRot[i].y, self.endRot[i].z);
		obj:SetScale(self.endScale[i]);
		if (obj:HasActor()) then
			obj:SetAlpha(self.endAlpha[i]);
		end
	end
end