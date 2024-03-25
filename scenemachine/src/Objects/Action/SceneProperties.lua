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
	Renderer.projectionFrame:SetLightAmbientColor(R, G, B);
	SM.loadedScene.properties.ambientColor = { R, G, B, A };

	-- Restore the diffuse color
	R, G, B, A = self.startProperties.diffuseColor[1], self.startProperties.diffuseColor[2], self.startProperties.diffuseColor[3], self.startProperties.diffuseColor[4];
	Renderer.projectionFrame:SetLightDiffuseColor(R, G, B);
	SM.loadedScene.properties.diffuseColor = { R, G, B, A };

	-- Restore the background color
	R, G, B, A = self.startProperties.backgroundColor[1], self.startProperties.backgroundColor[2], self.startProperties.backgroundColor[3], self.startProperties.backgroundColor[4];
	Renderer.backgroundFrame.texture:SetColorTexture(R, G, B, 1);
	SM.loadedScene.properties.backgroundColor = { R, G, B, A };

	-- Restore the lighting visibility
	Renderer.projectionFrame:SetLightVisible(self.startProperties.enableLighting);
end

--- Redo the scene properties.
function SceneProperties:Redo()
	-- Get the end properties for ambient color
	local R, G, B, A = self.endProperties.ambientColor[1], self.endProperties.ambientColor[2], self.endProperties.ambientColor[3], self.endProperties.ambientColor[4];
	
	-- Set the ambient color for the projection frame
	Renderer.projectionFrame:SetLightAmbientColor(R, G, B);
	
	-- Update the ambient color in the loaded scene properties
	SM.loadedScene.properties.ambientColor = { R, G, B, A };
	
	-- Get the end properties for diffuse color
	R, G, B, A = self.endProperties.diffuseColor[1], self.endProperties.diffuseColor[2], self.endProperties.diffuseColor[3], self.endProperties.diffuseColor[4];
	
	-- Set the diffuse color for the projection frame
	Renderer.projectionFrame:SetLightDiffuseColor(R, G, B);
	
	-- Update the diffuse color in the loaded scene properties
	SM.loadedScene.properties.diffuseColor = { R, G, B, A };
	
	-- Get the end properties for background color
	R, G, B, A = self.endProperties.backgroundColor[1], self.endProperties.backgroundColor[2], self.endProperties.backgroundColor[3], self.endProperties.backgroundColor[4];
	
	-- Set the background color for the background frame texture
	Renderer.backgroundFrame.texture:SetColorTexture(R, G, B, 1);
	
	-- Update the background color in the loaded scene properties
	SM.loadedScene.properties.backgroundColor = { R, G, B, A };
	
	-- Set the visibility of the light based on the end properties
	Renderer.projectionFrame:SetLightVisible(self.endProperties.enableLighting);
end