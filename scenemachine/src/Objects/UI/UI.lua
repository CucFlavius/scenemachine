SceneMachine.UI = {};

SceneMachine.UI.UI = 
{
    updateElements = {}
}

local UI = SceneMachine.UI.UI;

setmetatable(UI, UI)

local fields = {}

function UI:New(resourcePath)
	local v = 
    {
        updateElements = {},
		focused = false,
    };

	setmetatable(v, UI);
	v:Initialize(resourcePath);
	return v;
end

function UI:Initialize(resourcePath)
    self.resourcePath = resourcePath;
    
    self.fontResourcePath = self.resourcePath .. "\\font";
    self.fontResources = {}
    self.fontResources["Segoe"] = self.fontResourcePath .. "\\Segoe UI.ttf";
    
    self.textureResourcePath = self.resourcePath .. "\\textures";
    self.textureResources = {}
    self.textureResources["SliderThumb"] = self.textureResourcePath .. "\\SliderThumb.png";

    self.defaultFont = self.fontResources["Segoe"];

    self.closeWindowText = nil;
    self.closeWindowIcon = self.textureResourcePath .. "\\closeButton.png"
end

function UI:AddElement(element)
	self.updateElements[#self.updateElements + 1] = element;
end

function UI:Update()
	for i = 1, #self.updateElements, 1 do
		if (self.updateElements[i].visible) then
        	self.updateElements[i]:Update();
		end
    end
end

UI.__tostring = function(self)
	return "UI";
end

UI.__index = function(t,k)
	local var = rawget(UI, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end