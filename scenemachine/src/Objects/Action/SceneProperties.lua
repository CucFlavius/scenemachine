local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;
local Renderer = SceneMachine.Renderer;

SceneMachine.Actions.SceneProperties = {};

local Action = SceneMachine.Actions.Action;

--- @class SceneProperties : Action
local SceneProperties = SceneMachine.Actions.SceneProperties;

SceneProperties.__index = SceneProperties;
setmetatable(SceneProperties, Action)

--- Creates a new SceneProperties object with the specified properties.
--- @param properties table The properties to initialize the SceneProperties object with.
--- @return SceneProperties v The newly created SceneProperties object.
function SceneProperties:New(properties)
	--- @class SceneProperties : Action
	local v = 
    {
        type = Action.Type.SceneProperties,
		memorySize = 9,
		memoryUsage = 0,
		startProperties = {},
    };

	setmetatable(v, SceneProperties)

	v.startProperties.ambientColor = properties.ambientColor;
	v.startProperties.diffuseColor = properties.diffuseColor;
	v.startProperties.backgroundColor = properties.backgroundColor;
	v.startProperties.enableLighting = properties.enableLighting;

	v.memoryUsage = v.memorySize;

	return v
end

--- Finish the scene properties by assigning the provided properties to the endProperties table.
--- @param properties table The properties to assign to the endProperties table.
function SceneProperties:Finish(properties)
	self.endProperties = {};
	self.endProperties.ambientColor = properties.ambientColor;
	self.endProperties.diffuseColor = properties.diffuseColor;
	self.endProperties.backgroundColor = properties.backgroundColor;
	self.endProperties.enableLighting = properties.enableLighting;
end

-- Undoes the changes made to the scene properties.
function SceneProperties:Undo()
	-- Restore the ambient color
	local R, G, B, A = self.startProperties.ambientColor[1], self.startProperties.ambientColor[2], self.startProperties.ambientColor[3], self.startProperties.ambientColor[4];
	SM.loadedScene:SetAmbientColor(R, G, B, A);

	-- Restore the diffuse color
	R, G, B, A = self.startProperties.diffuseColor[1], self.startProperties.diffuseColor[2], self.startProperties.diffuseColor[3], self.startProperties.diffuseColor[4];
	SM.loadedScene:SetDiffuseColor(R, G, B, A);

	-- Restore the background color
	R, G, B, A = self.startProperties.backgroundColor[1], self.startProperties.backgroundColor[2], self.startProperties.backgroundColor[3], self.startProperties.backgroundColor[4];
	SM.loadedScene:SetBackgroundColor(R, G, B, A);

	SM.loadedScene:SetLightingEnabled(self.startProperties.enableLighting);
end

--- Redo the scene properties.
function SceneProperties:Redo()
	-- Get the end properties for ambient color
	local R, G, B, A = self.endProperties.ambientColor[1], self.endProperties.ambientColor[2], self.endProperties.ambientColor[3], self.endProperties.ambientColor[4];
	SM.loadedScene:SetAmbientColor(R, G, B, A);
	
	-- Get the end properties for diffuse color
	R, G, B, A = self.endProperties.diffuseColor[1], self.endProperties.diffuseColor[2], self.endProperties.diffuseColor[3], self.endProperties.diffuseColor[4];
	SM.loadedScene:SetDiffuseColor(R, G, B, A);
	
	-- Get the end properties for background color
	R, G, B, A = self.endProperties.backgroundColor[1], self.endProperties.backgroundColor[2], self.endProperties.backgroundColor[3], self.endProperties.backgroundColor[4];
	SM.loadedScene:SetBackgroundColor(R, G, B, A);
	
	SM.loadedScene:SetLightingEnabled(self.endProperties.enableLighting);
end