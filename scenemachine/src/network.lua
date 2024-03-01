local Net = SceneMachine.Network;
local Packet = Net.Packets.Packet;
local SM = SceneMachine.Editor.SceneManager;
local Renderer = SceneMachine.Renderer;

Net.myName = nil;
Net.myRealm = nil;
Net.leader = nil;
Net.players = {};
Net.playerAvatars = {};
Net.awaitingConnectionFrom = {};
Net.awaitingSceneData = false;
Net.splitPacketBuffer = {};
Net.time = 0;
Net.nextTick = 0;
Net.working = false;
Net.WORK_TICK = 0.5;    -- in seconds

function Net.Initialize()
    Net.PacketHandlers = {
        [Packet.Type.None] = Net.HandleNone,
        [Packet.Type.InvitationRequest] = Net.HandleInvitationRequest,
        [Packet.Type.InvitationAccepted] = Net.HandleInvitationAccepted,
        [Packet.Type.SceneData] = Net.HandleSceneData,
        [Packet.Type.ReadyToWork] = Net.HandleReadyToWork,
        [Packet.Type.PlayerState] = Net.HandlePlayerState,
    };

    local unitName = UnitName("player");
    Net.myName, Net.myRealm = strsplit( "-", unitName, 2 );
end

function Net.Update(deltaTime)
    if (Net.working) then

        Net.time = Net.time + deltaTime;

        if (Net.nextTick < Net.time) then
            -- run task
            local x, y, z = SceneMachine.Camera.position.x, SceneMachine.Camera.position.y, SceneMachine.Camera.position.z;
            local vx, vy, vz = SceneMachine.Camera.motionVector.x, SceneMachine.Camera.motionVector.y, SceneMachine.Camera.motionVector.z;
            local rx, ry, rz = SceneMachine.Camera.eulerRotation.x, SceneMachine.Camera.eulerRotation.y, SceneMachine.Camera.eulerRotation.z;
            local vrx, vry, vrz = SceneMachine.Camera.eulerVector.x, SceneMachine.Camera.eulerVector.y, SceneMachine.Camera.eulerVector.z;
            local packet = Net.Packets.PlayerState:New(Net.myName, x, y, z, vx, vy, vz, rx, ry, rz, vrx, vry, vrz);

            if (Net.myName == Net.leader) then
                for p = 1, #Net.players, 1 do
                    local name, realm = strsplit( "-", Net.players[p], 2 );
                    --packet:Send(Net.players[p]);
                    packet:Send(name);
                end
            else
                packet:Send(Net.leader);
            end

            Net.nextTick = Net.nextTick + Net.WORK_TICK;
        end

        if (Net.myName == Net.leader) then
            for p = 1, #Net.players, 1 do
                Net.UpdatePlayer(Net.players[p]);
            end
        else
            Net.UpdatePlayer(Net.leader);
        end
    end
end

function Net.InvitePlayer(playerName)
    Net.leader = Net.myName;
    Net.awaitingConnectionFrom[#Net.awaitingConnectionFrom + 1] = playerName;
    local packet = Net.Packets.InvitationRequest:New(playerName);
    packet:Send(playerName);
end

function Net.Disconnect()
    Net.working = false;

    -- todo needs more work
end

function Net.MessageReceive(prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID)

    local packetID = string.sub(text, 1, 8);
    local part = tonumber(string.sub(text, 9, 10), 16);
    local totalParts = tonumber(string.sub(text, 11, 12), 16);
    local data = string.sub(text, 13);

    if (totalParts == 0) then
        local decoded = SceneMachine.Libs.LibDeflate:DecodeForWoWAddonChannel(data);
        if not decoded then print("decode failed"); return end
        local decompressed = SceneMachine.Libs.LibDeflate:DecompressDeflate(decoded);
        if not decompressed then print("decompress failed"); return end
        local success, data = SceneMachine.Libs.LibSerialize:Deserialize(decompressed);
        if not success then print("deserialize failed"); return end

        --local player, realm = strsplit( "-", sender, 2 );

        if (Net.PacketHandlers[data.type]) then
            Net.PacketHandlers[data.type](sender, data);
        else
            print("Missing packet handler for type: " .. data.type);
        end
    else
        -- handle split packet
        Net.splitPacketBuffer[packetID] = Net.splitPacketBuffer[packetID] or {};
        Net.splitPacketBuffer[packetID][part] = data;
        print(#Net.splitPacketBuffer[packetID]);
        if (#Net.splitPacketBuffer[packetID] == totalParts) then
            -- assemble parts
            local fullData = table.concat(Net.splitPacketBuffer[packetID]);

            local decoded = SceneMachine.Libs.LibDeflate:DecodeForWoWAddonChannel(fullData);
            if not decoded then print("decode failed"); return end
            local decompressed = SceneMachine.Libs.LibDeflate:DecompressDeflate(decoded);
            if not decompressed then print("decompress failed"); return end
            local success, data = SceneMachine.Libs.LibSerialize:Deserialize(decompressed);
            if not success then print("deserialize failed"); return end
    
            print(string.len(fullData));
            if (Net.PacketHandlers[data.type]) then
                Net.PacketHandlers[data.type](sender, data);
            else
                print("Missing packet handler for type: " .. data.type);
            end
        end
    end
end

function Net.SplitPacketDataByChunk(text, chunkSize)
    local s = {}
    for i=1, #text, chunkSize do
        s[#s+1] = text:sub(i,i+chunkSize - 1)
    end
    return s
end

function Net.GeneratePacketID()
    if (Net.lastPacketID) then
        Net.lastPacketID = Net.lastPacketID + 1;
    else
        Net.lastPacketID = 1;
    end

    return string.format("%08x", Net.lastPacketID);
end

function Net.HandleNone(sender, _)
    print("None packet recieved from: " .. sender .. " Shouldn't happen.");
end

function Net.HandleInvitationRequest(sender, data)
    print(sender .. " invites you to their scene.");
    print("Debug - accepting invitation automatically.");

    -- set as leader
    Net.leader = sender;

    -- wait for scene data
    Net.awaitingSceneData = true;

    -- send message back
    local packet = Net.Packets.InvitationAccepted:New(data.playerName);
    packet:Send(sender);
end

function Net.HandleInvitationAccepted(sender, data)
    local player, realm = strsplit( "-", sender, 2 );

    if (not sender) then return end
    for i = 1, #Net.awaitingConnectionFrom, 1 do
        if (sender == Net.awaitingConnectionFrom[i] or player == Net.awaitingConnectionFrom[i]) then
            -- step 1: notification
            print ("Invitation Accepted by " .. sender);

            -- step 2: add player to server
            Net.players[#Net.players + 1] = sender;

            -- step 3: remove awaiting connection
            table.remove(Net.awaitingConnectionFrom, i);

            -- step 4: begin sending scene data
            --local sceneData = SM.ExportSceneForMessage(SM.loadedScene);
            local sceneData = SM.ExportScene(SM.loadedScene);

            local packet = Net.Packets.SceneData:New(sceneData);
            packet:Send(sender);
            --local splitData = Net.SplitPacketDataByChunk(sceneData, 200);
            --for i = 1, #splitData, 1 do
            --    local packet = Net.Packets.SceneData:New(splitData, i, #splitData);
            --    packet:Send(sender);
            --end
            return;
        end
    end
end

function Net.HandleSceneData(sender, data)
    SceneMachine.Editor.Show();
    local scene = SM.ImportNetworkScene(data.sceneData);
    SM.LoadNetworkScene(scene);

    Net.working = true;

    Net.MakeAvatar(sender);

    -- send ready signal
    local packet = Net.Packets.ReadyToWork:New(data.playerName);
    packet:Send(sender);
end

function Net.HandleReadyToWork(sender, data)
    print("Ready To Work");
    Net.working = true;

    Net.MakeAvatar(sender);
end

function Net.HandlePlayerState(sender, data)
    --print(sender)
    if (Net.playerAvatars[sender]) then
        Net.playerAvatars[sender].data = data;
        local actor = Net.playerAvatars[sender].actor;
        actor:SetPosition(data.x, data.y, data.z);
        actor:SetYaw(data.rx);
        actor:SetPitch(data.ry);
        actor:SetRoll(data.rz);
    end
end

function Net.UpdatePlayer(name)
    if (Net.playerAvatars[name]) then
        local actor = Net.playerAvatars[name].actor;
        local data = Net.playerAvatars[name].data;
        if (data) then
            local posX, posY, posZ = actor:GetPosition();
            posX = posX + data.vx;
            posY = posY + data.vy;
            posZ = posZ + data.vz;

            local newState = 0;

            if (data.vx == 0 and data.vy == 0 and data.vz == 0) then
                newState = 0;
            else
                newState = 1;
            end

            if (newState ~= Net.playerAvatars[name].state) then
                Net.playerAvatars[name].state = newState;
                if (Net.playerAvatars[name].state == 0) then
                    actor:SetAnimation(41);
                elseif(Net.playerAvatars[name].state == 1) then
                    actor:SetAnimation(42);
                end
            end

            local rotX = actor:GetYaw() + data.vrx / 2; -- fine tuning to only half because rarely someone rotates too crazy
            local rotY = actor:GetPitch() + data.vry / 2;
            local rotZ = actor:GetRoll() + data.vrz / 2;

            actor:SetPosition(posX, posY, posZ);
            actor:SetYaw(rotX);
            actor:SetPitch(rotY);
            actor:SetRoll(rotZ);
        end
    end
end

function Net.MakeAvatar(playerName)
    Net.playerAvatars[playerName] = {};
    Net.playerAvatars[playerName].actor = Renderer.AddActor(167145, 0, 0, 0, SceneMachine.ObjectType.Model);
    Net.playerAvatars[playerName].actor:SetModelByUnit("player");
end