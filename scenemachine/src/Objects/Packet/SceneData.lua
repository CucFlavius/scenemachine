local Packet = SceneMachine.Network.Packets.Packet;
SceneMachine.Network.Packets.SceneData = {};

--- @class SceneData : Packet
local SceneData = SceneMachine.Network.Packets.SceneData;

SceneData.__index = SceneData;
setmetatable(SceneData, Packet)

--- Creates a new SceneData object.
--- @param sceneData table The scene data to be stored in the object.
--- @return SceneData v The newly created SceneData object.
function SceneData:New(sceneData)
    local v = 
    {
        type = Packet.Type.SceneData;
        sceneData = sceneData,
    };

    setmetatable(v, SceneData);
    return v;
end