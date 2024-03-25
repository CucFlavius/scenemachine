local Packet = SceneMachine.Network.Packets.Packet;
SceneMachine.Network.Packets.ReadyToWork = {};

--- @class ReadyToWork : Packet
local ReadyToWork = SceneMachine.Network.Packets.ReadyToWork;

ReadyToWork.__index = ReadyToWork;
setmetatable(ReadyToWork, Packet)

--- Creates a new ReadyToWork packet object.
---@param playerName string The name of the player.
---@return ReadyToWork v The new ReadyToWork packet object.
function ReadyToWork:New(playerName)
    local v = 
    {
        type = Packet.Type.ReadyToWork;
        playerName = playerName;
    };

    setmetatable(v, ReadyToWork);
    return v;
end