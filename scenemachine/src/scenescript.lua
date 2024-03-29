local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;

function SceneMachine.ImportScenescript(s)
    -- perform some changes to convert globals to SceneMachine locals
    s = string.gsub(s, "SceneTimelineAddFileData", "SceneMachine.SceneTimelineAddFileData");
    s = string.gsub(s, "cid", "SceneMachine.cid");
    s = string.gsub(s, "fid", "SceneMachine.fid");
    s = string.gsub(s, "gdi", "SceneMachine.gdi");
    s = string.gsub(s, "iid", "SceneMachine.iid");
    RunScript(s);
end

function SceneMachine.SceneTimelineAddFileData(scriptFile, sceneData)
    print("Running scenescript: " .. scriptFile);

    -- load every actor as object
    for actorName in pairs(sceneData.actors) do
        local actor = sceneData.actors[actorName];
        local properties = actor.properties;

        local scale = properties.Scale;
        if (scale) then
            scale = scale.events[1][0.000];
        end
        local appearance = properties.Appearance;
        if (appearance) then
            appearance = appearance.events[1][0.000];
        end
        local groundSnap = properties.GroundSnap;
        if (groundSnap) then
            groundSnap = groundSnap.events[1][0.000];
        end
        local transform = properties.Transform;
        if (transform) then
            transform = transform.events[1][0.000];
        end
        local fade = properties.Fade;
        if (fade) then
            fade = fade.events[1][0.000];
        end
        local animKit = properties.AnimKit;
        if (animKit) then
            animKit = animKit.events[1];
        end
        local playSpellState = properties.PlaySpellState;
        if (playSpellState) then
            playSpellState = playSpellState.events[1];
        end

        local object;

        if (appearance) then
            local creatureID = appearance.creatureID;
            local creatureDisplayInfoID = appearance.creatureDisplayInfoID;
            local fileDataID = appearance.fileDataID;
            
            if (fileDataID ~= 0) then
                object = SM.loadedScene:CreateObject(fileDataID, actorName, 0, 0, 0);
            elseif (creatureDisplayInfoID ~= 0) then
                object = SM.loadedScene:CreateCreature(creatureDisplayInfoID, actorName, 0, 0, 0);
            elseif (creatureID ~= 0) then
                creatureDisplayInfoID = SceneMachine.creatureToDisplayID[creatureID];
                object = SM.loadedScene:CreateCreature(creatureDisplayInfoID, actorName, 0, 0, 0);
            else
                print("Unsupported actor type");
            end
        end

        if (object and transform) then
            local position = transform.transform.position;
            object:SetPosition(position.x, position.y, position.z);
            local yaw = transform.transform.yaw;
            local pitch = transform.transform.pitch;
            local roll = transform.transform.roll;
            object:SetRotation(math.rad(roll), math.rad(pitch), math.rad(yaw));
            if (scale) then
                object:SetScale(scale.scale);
            end

            if (animKit) then
                local animationKit = animKit.props.animKitID;
                object.actor:PlayAnimationKit(animationKit);
            end

            if (playSpellState) then
                local spellVisualKit = playSpellState.props.spellVisualID;
                object.actor:SetSpellVisualKit(spellVisualKit);
            end
        end
    end
end

-- creatureID
function SceneMachine.cid(value)
    return value;
end

-- fileDataID
function SceneMachine.fid(value)
    return value;
end

-- wmoGameObjectDisplayID
function SceneMachine.gdi(value)
    return value;
end

-- itemID
function SceneMachine.iid(value)
    return value;
end