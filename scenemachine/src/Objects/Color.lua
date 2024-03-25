local max = math.max;
local min = math.min;

local function clamp(value, min, max)
	return math.min(math.max(value, min), max);
end

SceneMachine.Color =
{
	r = 0,
	g = 0,
	b = 0,
	a = 0,
}

--- @class Color
local Color = SceneMachine.Color;

setmetatable(Color, Color)

local fields = {}

--- Creates a new Color object with the specified RGBA values.
--- @param r number The red component of the color (0-1).
--- @param g number The green component of the color (0-1).
--- @param b number The blue component of the color (0-1).
--- @param a? number (optional) The alpha component of the color (0-1). Defaults to 1 if not provided.
--- @return Color color The new Color object.
function Color:New(r, g, b, a)
	local v = {r = 0, g = 0, b = 0, a = 0}
	v.r = r
	v.g = g
	v.b = b
	v.a = a or 1
	setmetatable(v, Color)
	return v
end

--- Sets the color values for the Color object.
--- @param r number: The red component of the color (0-1).
--- @param g number: The green component of the color (0-1).
--- @param b number: The blue component of the color (0-1).
--- @param a? number: Optional. The alpha component of the color (0-1). Defaults to 1 if not provided.
function Color:Set(r, g, b, a)
	self.r = r
	self.g = g
	self.b = b
	self.a = a or 1
end

--- Retrieves the color values.
--- @return number r, number g, number b, number a The red, green, blue, and alpha values of the color.
function Color:Get()
	return self.r, self.g, self.b, self.a
end

--- Checks if the current color is equal to another color.
--- @param other Color The color to compare with.
--- @return boolean equal Returns true if the colors are equal, false otherwise.
function Color:Equals(other)
	return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a
end

--- Linearly interpolates between two colors.
--- @param a Color The starting color.
--- @param b Color The ending color.
--- @param t number The interpolation factor (between 0 and 1).
--- @return Color color The interpolated color.
function Color:Lerp(a, b, t)
	t = clamp(t, 0, 1)
	return Color:New(a.r + t * (b.r - a.r), a.g + t * (b.g - a.g), a.b + t * (b.b - a.b), a.a + t * (b.a - a.a))
end

--- Converts a color to grayscale.
--- @param a table The color to convert.
--- @return number value The grayscale value.
function Color.GrayScale(a)
	return 0.299 * a.r + 0.587 * a.g + 0.114 * a.b
end

--- Multiplies the color components of the current color object with another color object.
--- @param a Color The color object to multiply with.
function Color:MultiplyColor(a)
	self.r = self.r * a.r;
	self.g = self.g * a.g;
	self.b = self.b * a.b;
end

--- Multiplies each component of the color by a given number.
--- @param a number The number to multiply the color components by.
--- @return Color color The modified Color object.
function Color:MultiplyNumber(a)
	self.r = self.r * a;
	self.g = self.g * a;
	self.b = self.b * a;
	return self;
end

--- Adds the components of another color to this color.
--- @param a Color The color to add.
function Color:AddColor(a)
	self.r = self.r + a.r;
	self.g = self.g + a.g;
	self.b = self.b + a.b;
end

--- Clamps the color values to the upper limit.
--- @param limit number The upper limit to clamp the color values to.
function Color:ClampUpper(limit)
	self.r = max(self.r, limit);
	self.g = max(self.g, limit);
	self.b = max(self.b, limit);
end

--- Clamps the color values to a lower limit.
--- @param limit number The lower limit to clamp the color values to.
function Color:ClampLower(limit)
	self.r = min(self.r, limit);
	self.g = min(self.g, limit);
	self.b = min(self.b, limit);
end

--- Inverts the color values.
function Color:Invert()
	self.r = -self.r;
	self.g = -self.g;
	self.b = -self.b;
end

--- Converts the Color object to a string representation.
--- @return string string The string representation of the Color object.
Color.__tostring = function(self)
	return string.format("RGBA(%f,%f,%f,%f)", self.r, self.g, self.b, self.a)
end

--- Adds two Color objects together and returns a new Color object.
--- @param a Color The first Color object.
--- @param b Color The second Color object.
--- @return Color color The resulting Color object.
Color.__add = function(a, b)
	return Color:New(a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a)
end

--- Subtracts two Color objects and returns a new Color object.
--- @param a Color The first Color object.
--- @param b Color The second Color object.
--- @return Color color The resulting Color object.
Color.__sub = function(a, b)
	return Color:New(a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a)
end

--- Multiplies two Color objects and returns a new Color object.
--- @param a Color The first Color object.
--- @param b Color The second Color object.
--- @return Color color The resulting Color object.
Color.__mul = function(a, b)
	if type(b) == "number" then
		return Color:New(a.r * b, a.g * b, a.b * b, a.a * b)
	else
		return Color:New(a.r * b.r, a.g * b.g, a.b * b.b, a.a * b.a)
	end
end

--- Divides two Color objects and returns a new Color object.
--- @param a Color The first Color object.
--- @param d Color The second Color object.
--- @return Color color The resulting Color object.
Color.__div = function(a, d)
	return Color:New(a.r / d, a.g / d, a.b / d, a.a / d)
end

--- Checks if two Color objects are equal.
--- @param a Color The first Color object.
--- @param b Color The second Color object.
--- @return boolean True if the Color objects are equal, false otherwise.
Color.__eq = function(a,b)
	return a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
end

-- This function is used as the __index metamethod for the Color table.
-- It is called when a key is not found in the Color table.
Color.__index = function(t,k)
	local var = rawget(Color, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)
		end
	end
	
	return var
end

fields.red 		= function() return Color:New(1,0,0,1) end
fields.green	= function() return Color:New(0,1,0,1) end
fields.blue		= function() return Color:New(0,0,1,1) end
fields.white	= function() return Color:New(1,1,1,1) end
fields.black	= function() return Color:New(0,0,0,1) end
fields.yellow	= function() return Color:New(1, 0.9215686, 0.01568628, 1) end
fields.cyan		= function() return Color:New(0,1,1,1) end
fields.magenta	= function() return Color:New(1,0,1,1) end
fields.gray		= function() return Color:New(0.5,0.5,0.5,1) end
fields.clear	= function() return Color:New(0,0,0,0) end

fields.grayscale = Color.GrayScale