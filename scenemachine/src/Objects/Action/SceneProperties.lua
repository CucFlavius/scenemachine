local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;
local Renderer = SceneMachine.Renderer;

SceneMachine.Actions.SceneProperties = {};

local Action = SceneMachine.Actions.Action;
local SceneProperties = SceneMachine.Actions.SceneProperties;
SceneProperties.__index = SceneProperties;
setmetatable(SceneProperties, Action)

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

	v.memoryUsage = v.memorySize;

	return v
end

function SceneProperties:Finish(properties)
	self.endProperties = {};
	self.endProperties.ambientColor = properties.ambientColor;
	self.endProperties.diffuseColor = properties.diffuseColor;
	self.endProperties.backgroundColor = properties.backgroundColor;
end

function SceneProperties:Undo()
	local R, G, B, A = self.startProperties.ambientColor[1], self.startProperties.ambientColor[2], self.startProperties.ambientColor[3], self.startProperties.ambientColor[4];
    Renderer.projectionFrame:SetLightAmbientColor(R, G, B);
    SM.loadedScene.properties.ambientColor = { R, G, B, A };
	R, G, B, A = self.startProperties.diffuseColor[1], self.startProperties.diffuseColor[2], self.startProperties.diffuseColor[3], self.startProperties.diffuseColor[4];
	Renderer.projectionFrame:SetLightDiffuseColor(R, G, B);
    SM.loadedScene.properties.diffuseColor = { R, G, B, A };
	R, G, B, A = self.startProperties.backgroundColor[1], self.startProperties.backgroundColor[2], self.startProperties.backgroundColor[3], self.startProperties.backgroundColor[4];
	Renderer.backgroundFrame.texture:SetColorTexture(R, G, B, 1);
    SM.loadedScene.properties.backgroundColor = { R, G, B, A };
end

function SceneProperties:Redo()
	local R, G, B, A = self.endProperties.ambientColor[1], self.endProperties.ambientColor[2], self.endProperties.ambientColor[3], self.endProperties.ambientColor[4];
    Renderer.projectionFrame:SetLightAmbientColor(R, G, B);
    SM.loadedScene.properties.ambientColor = { R, G, B, A };
	R, G, B, A = self.endProperties.diffuseColor[1], self.endProperties.diffuseColor[2], self.endProperties.diffuseColor[3], self.endProperties.diffuseColor[4];
	Renderer.projectionFrame:SetLightDiffuseColor(R, G, B);
    SM.loadedScene.properties.diffuseColor = { R, G, B, A };
	R, G, B, A = self.endProperties.backgroundColor[1], self.endProperties.backgroundColor[2], self.endProperties.backgroundColor[3], self.endProperties.backgroundColor[4];
	Renderer.backgroundFrame.texture:SetColorTexture(R, G, B, 1);
    SM.loadedScene.properties.backgroundColor = { R, G, B, A };
end