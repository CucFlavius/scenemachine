-- WoW global definitions
-- Strictly used just in visual studio code for wow api reference
-- Not compiled by wow
-- Don't ship with the addon, waste of space

--------------------
-- Bit operations --
--------------------
bit = {};
function bit.tobit() end
function bit.tohex() end
function bit.bnot() end
function bit.band() end
function bit.bor() end
function bit.bxor() end
function bit.lshift() end
function bit.rshift() end
function bit.arshift() end
function bit.rol() end
function bit.ror() end
function bit.bswap() end

function assert(value) end

--------------------
--      math      --
--------------------

--- Returns the absolue value of the number. Will return a floating point or an integer depending upon the argument.
---@param num number Number to return numeric (absolute) value of.
---@return absoluteValue number The absolute value of the argument number.
function abs(num) end

--- Returns the absolue value of the number. Will always return a floating point number even if the argument is integer
---@param num number Number to return numeric (absolute) value of.
---@return absoluteValue number The absolute value of the argument number.
function fabs(num) end

--- Returns the largest integer smaller than or equal to the given number.
---@param value number Number to return floor value of.
---@return floorValue number The floor value of the argument number.
function floor(value) end

--- Returns the radian equivalent of the degree value.
---@param degrees number Number in degrees.
---@return radiansValue number The radian value.
function rad(degrees) end

--- Returns the numeric maximum of the input values.
---@param value number Input value to compare.
---@return maxNumber number The maximum number.
function max(value, ...) end

--- Returns the numeric minimum of the input values.
---@param value number Input value to compare.
---@return minNumber number The minimum number.
function min(value, ...) end

function distance(num) end
function sin(num) end
function cos(num) end
function tan(num) end
function atan(num) end
function abs(num) end
function floor(num) end
function sqrt(num) end
function clamp(num) end

--------------------
--       ui       --
--------------------
UIParent = {}

---Creates a new UI frame.
---@param frameType string Type of the frame to be created (XML tag name): "Frame", "Button", etc. See UIOBJECT_Frame
---@return frame newFrame Frame - Reference to the newly created frame.
function CreateFrame(frameType) end

---Creates a new UI frame.
---@param frameType string Type of the frame to be created (XML tag name): "Frame", "Button", etc. See UIOBJECT_Frame
---@param frameName string Name of the newly created frame. If nil, no frame name is assigned. The function will also set a global variable of this name to point to the newly created frame.
---@param parentFrame frame The frame object that will be used as the created Frame's parent (cannot be a string!) Does not default to UIParent if given nil.
---@param inheritsFrame string A comma-delimited list of names of virtual frames to inherit from (the same as in XML). If nil, no frames will be inherited. These frames cannot be frames that were created using this function, they must be created using XML with virtual="true" in the tag.
---@return frame newFrame Frame - Reference to the newly created frame.
function CreateFrame(frameType, frameName, parentFrame, inheritsFrame) end

function SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy) end
function SetPoint(point, relativeFrame, relativePoint) end
function SetPoint(point, ofsx, ofsy) end
function SetPoint(point) end

--------------------
--      table     --
--------------------
function getn(value) end
-- unpack(tableName, i, j)
function unpack() end

--------------------
--     string     --
--------------------
function strlen(value) end
function strmatch(value, value2) end

--------------------
--     player     --
--------------------
function UnitPosition(unit) end

--------------------
--  game frames   --
--------------------

--- The default chat window
DEFAULT_CHAT_FRAME = {};
GeneralDockManager = {};
ChatFrameMenuButton = {};
ChatFrameChannelButton = {};
QuickJoinToastButton = {};
MainMenuBar = {};
PlayerFrame = {};
ObjectiveTrackerFrame = {};

--------------------
--     Other      --
--------------------
LibStub = {};
ZWindowAPI = {};

--- Returns the system uptime of your computer in seconds, with millisecond precision.
---@return number seconds Floating Point Number - The current system uptime in seconds.
function GetTime() end;

--- Retrieve the current framerate (frames / second).
---@return number framerate The current framerate in frames per second.
function GetFramerate() end;