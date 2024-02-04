SceneMachine.UI = 
{
    elements = {}
}

local UI = SceneMachine.UI;

setmetatable(UI, UI)

local fields = {}

function UI:New()
	local v = 
    {
        elements = {}
    };

	setmetatable(v, UI);
	return v;
end

function UI:AddElement(element)
	self.elements[#self.elements + 1] = element;
end

function UI:Update()
	for i = 1, #self.elements, 1 do
		if (self.elements[i].visible) then
        	self.elements[i]:Update();
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