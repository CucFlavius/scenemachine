

-- WoW.tools debug output: Start of package 3189


-- WoW.tools debug output: SceneScript name: Timeline Properties

--
-- Property Definition
-- Version control source file WoW\Source\Object\ObjectClient\SceneTimelineFramework\timeline_010_Properties.lua
-- Programmers should edit in the repository first before updating in WOWEdit
--
scenePropertyData = { }

function SceneTimelineAddProperty(propName, propDef)
	propDef.propertyName = propName
	if (not propDef.priority) then
		propDef.priority = 0
	end
	scenePropertyData[propName] = propDef
end

function SceneTimelineAddStatePropertyOneShot(propName, propDef)
	if (propDef.SetStateCreateData) then
	
		propDef.ApplyToCreateData = function(prop, createData, key)
			propDef.SetStateCreateData(prop, createData, key)
		end
		
	end
	
	if (propDef.SetStateActor) then

		propDef.ApplyToActor = function(prop, actor, key, time)
			propDef.SetStateActor(prop, actor, key, time, false)
		end
		
		propDef.ScrubActorTo = function(prop, actor, processedKeys, time)
			if (#processedKeys > 0) then
				local lastKey = processedKeys[#processedKeys]
				propDef.SetStateActor(prop, actor, lastKey, time, true)
			else
				propDef.SetStateActor(prop, actor, propDef.defaultKey, time, true)
			end
		end
		
	end

	SceneTimelineAddProperty(propName, propDef)
end

-- assumes that key 1 is the start and key 2 is the end
function SceneTimelineAddStatePropertyEvent(propName, propDef)

	local stateStorageKey = "timelineProcessedStateKeys" .. propName

	propDef.minEventKeys = 2
	propDef.maxEventKeys = 2

	if (propDef.ApplyState and propDef.RemoveState and propDef.GetUniqueID) then
		
		propDef.ApplyToActor = function(prop, actor, key, time)
			propDef.ProcessKeyInternal(false, prop, actor, key, time)
		end
		
		-- prop.handlePauseForScrubActorTo is for some properties(e.g. CameraEffect) that we only want to be processed when the scene is not paused
		propDef.ScrubActorTo = function(prop, actor, processedKeys, time)
			-- loop through all the keys, work out what state we should be in then add/remove the deltas
			local currentStorage = actor[stateStorageKey] or { }
			local nextStorage =  { }
			actor[stateStorageKey] = nextStorage

			for _,key in ipairs(processedKeys) do
				if ((not prop.handlePauseForScrubActorTo) or (prop.handlePauseForScrubActorTo and not actor.timelineInstance.paused)) then
					prop.ProcessKeyInternal(true, prop, actor, key, time)
				end
			end

			-- process any removes first
			for id, entry in pairs(currentStorage) do
				if (not nextStorage[id]) then
					prop.RemoveState(prop, actor, entry.endKey, time)
				end
			end

			-- add new ones
			for id, entry in pairs(nextStorage) do
				if (not currentStorage[id]) then
					if ((not prop.handlePauseForScrubActorTo) or (prop.handlePauseForScrubActorTo and not actor.timelineInstance.paused)) then
						prop.ApplyState(prop, actor, entry.startKey, time)
					end
				end
			end
		end

		propDef.ProcessKeyInternal = function(isScrub, prop, actor, key, time)
			local id = propDef.GetUniqueID(key)
			local storage = actor[stateStorageKey]
			if (not storage) then
				storage = { }
				actor[stateStorageKey] = storage
			end

			if (key.keyIndex == 1) then
				-- normal playback add
				local entry = storage[id]
				local endKey = key.eventInstance.keys[2]
				if (endKey) then
					if (not entry) then
						entry = { }
						entry.startKey = key
						entry.endKey = endKey
						storage[id] = entry
						if (not isScrub) then
							propDef.ApplyState(prop, actor, key, time)
						end
					else
						if (endKey.time > entry.endKey.time) then
							entry.endKey = endKey
						end
					end
				end
			elseif (key.keyIndex == 2) then
				-- normal playback remove
				local entry = storage[id]
				if (entry and (entry.endKey == key)) then
					storage[id] = nil
					if (not isScrub) then
						propDef.RemoveState(prop, actor, key, time)
					end
				end
			end
		end
	end

	SceneTimelineAddProperty(propName, propDef)
end

function SceneTimelineGetActorID(srcActor, actorName)
	if (not actorName) or (not srcActor.timelineInstance) or (not srcActor.timelineInstance.actorIDByName) then
		return nil
	end
	
	local lowerName = string.lower(actorName)
	local actorID
	
	local delimStart, delimEnd
	while lowerName do
		actorID = srcActor.timelineInstance.actorIDByName[lowerName]
		if (actorID) then
			return actorID
		end

		-- backwards compatibility, search by decreasing path specificity
		delimStart, delimEnd = string.find(lowerName, "\\");
		if (delimEnd) then
			lowerName = string.sub(lowerName, delimEnd+1, #lowerName)
		else
			-- out of path
			return nil
		end
	end
	
	return nil
end

function SceneTimelineGetActor(srcActor, actorName)
	if (not actorName) or (not srcActor.timelineInstance) or (not srcActor.timelineInstance.actorMap) then
		return nil
	end
	
	local actorID = SceneTimelineGetActorID(srcActor, actorName)
	if (actorID) then
		return srcActor.timelineInstance.actorMap[actorID]
	end
	
	return nil
end

-- special universal properties
SceneTimelineAddProperty("End",
{
	keyFields =
	{
	},

	ApplyToActor = function(property, actor, key, time)
		if (scene:IsTimelineEditing()) then
			actor.timelineInstance.paused = true
		else
			scene:EndScene()
		end
	end,
})

-- special universal properties
SceneTimelineAddProperty("PlayerCondition",
{
	meta = 
	{
		description = "This actor will not spawn at runtime if this condition does not test true",
	},
	keyFields =
	{
		{ 
			name = "condition",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "PlayerCondition",
			}
		},
	},
})

-- WoW.tools debug output: SceneScript name: Timeline Framework

--
-- Framework
-- Version control source file WoW\Source\Object\ObjectClient\SceneTimelineFramework\timeline_020_Framework.lua
-- Programmers should edit in the repository first before updating in WOWEdit
--

local ApplySingleEvent
local ReverseSingleEvent
local AdvanceTimeToNextEvent
local SortKeys

local sceneInputData = { }
local DEFAULT_FRAME_DELAY = 1
local INITIAL_KEY_TIME = 0.0001

ApplySingleEvent = function(instance, event, finalTime)
	local actor = instance.actorMap[event.actorID]
	local propDef = instance.propertyByName[event.property]

	if (actor and propDef and propDef.ApplyToActor) then
		propDef.ApplyToActor(propDef, actor, event, finalTime)
	end
end

AdvanceTimeToNextEvent = function(instance, nextTime, playBackID)
	local waitTime = nextTime - instance.processedTime
	if (instance.playBackRate > 0.0001) then
		waitTime = waitTime / instance.playBackRate
	else
		waitTime = 60*60 -- essentially infinite - 1hr
	end
	
	scene:WaitTimer(waitTime)

	if (instance.playBackID ~= playBackID) then
		return
	end

	instance.processedTime = instance.pendingTime
	SceneTimelineProcessCurrentTime(instance)
end

local ProcessFrameDelayedEvents = function(instance, frameDelay, frameDelayedThisFrame, processedTime, playBackID)
	for _ = 1,frameDelay do
		scene:WaitTimer(0)
		if (instance.playBackID ~= playBackID) then
			return
		end
	end

	for i,nextEvent in ipairs(frameDelayedThisFrame) do
		ApplySingleEvent(instance, nextEvent, processedTime)
	end
end


local valType
local PopulateKeyDefaultsRecurse
PopulateKeyDefaultsRecurse = function(srcKey, srcVal, dstTable)
	valType = type(srcVal)

	if valType == 'table' then
		if (dstTable[srcKey] == nil) or type(dstTable[srcKey]) ~= valType then
			dstTable[srcKey] = { }
		end

		for childKey,childVal in pairs(srcVal) do
			PopulateKeyDefaultsRecurse(childKey, childVal, dstTable[srcKey])
		end
	else
		if (dstTable[srcKey] == nil) or type(dstTable[srcKey]) ~= valType then
			dstTable[srcKey] = srcVal -- primitive copy
		end
	end
end

local InitializeKeyFields = function(fields, dstBuffer)
	if (not fields) then
		return
	end
	
	for fieldIndex,field in pairs(fields) do
		-- simple deep copy from defaults
		PopulateKeyDefaultsRecurse(field.name, field.default, dstBuffer)
	end
end

function SceneTimelineIsActorVisibilityDisabled(instance, actorID)
	for i,value in ipairs(instance.actorVisibilityDisabled) do
		if value == actorID then
			return i
		end
	end
end

function SceneTimelineActorVisibility(instance, actorID, enableVisibility)
	found = SceneTimelineIsActorVisibilityDisabled(instance, actorID)

	if not found and not enableVisibility then
		table.insert(instance.actorVisibilityDisabled, actorID)
	elseif found and enableVisibility then
		table.remove(instance.actorVisibilityDisabled, found)
	end
end



function SceneTimelineProcessTime(instance)
	SceneTimelineProcessCurrentTime(instance)

	-- queue up pending future events
	-- to avoid framerate drift, we queue all the future events up at once, so they should
	-- not accumulate frame rate errors by queing the next one some time after the last
	if (instance.paused) or (instance.playBackRate < 0) then
		return
	end

	local lastTime = 0
	for _,nextEvent in ipairs(instance.pendingEvents) do
		if (not nextEvent) then
			return
		end

		if ((nextEvent.time > instance.processedTime) and (nextEvent.time > lastTime)) then
			lastTime = nextEvent.time;
			scene:AddCoroutineWithParams(AdvanceTimeToNextEvent, instance, lastTime, instance.playBackID)
		end
	end
end

function SceneTimelineProcessCurrentTime(instance)
	if (instance.processedTime ~= instance.pendingTime) then
		-- we are already waiting for the next time
		return
	end

	local propDef
	local frameDelay
	local frameDelayedEvents = { }

	while true do
		local nextEvent = instance.pendingEvents[1]
		if (not nextEvent) then
			return
		end

		if (nextEvent.time > instance.processedTime) then
			instance.pendingTime = nextEvent.time
			return
		end

		propDef = instance.propertyByName[nextEvent.property]
		frameDelay = DEFAULT_FRAME_DELAY
		if (propDef and propDef.frameDelay) then
			frameDelay = propDef.frameDelay
		end

		if ((frameDelay > 0) and (instance.processedTime > INITIAL_KEY_TIME)) then
			local frameDelayedThisFrame = frameDelayedEvents[frameDelay]
			if (not frameDelayedThisFrame) then
				-- group all framed delayed keys into one coroutine - there are often a lot of
				-- keys on the same frame
				frameDelayedThisFrame = { nextEvent }
				frameDelayedEvents[frameDelay] = frameDelayedThisFrame
				scene:AddCoroutineWithParams(ProcessFrameDelayedEvents, instance, frameDelay, frameDelayedThisFrame, instance.processedTime, instance.playBackID)
			else
				table.insert(frameDelayedThisFrame, nextEvent)
			end
		else
			ApplySingleEvent(instance, nextEvent, instance.processedTime)
		end

		table.insert(instance.processedEvents, nextEvent)
		table.remove(instance.pendingEvents, 1)
	end
end

local EVENT_PROP_INDEX = "props"
function SceneTimelineCreateEventInstance(actorID, propName, propDef, eventID, eventKeys)

	local eventInstance = {}
	eventInstance.eventID = eventID
	eventInstance.property = propName
	eventInstance.eventFields = eventKeys[EVENT_PROP_INDEX] or { }
	InitializeKeyFields(propDef.eventFields, eventInstance.eventFields)
	
	eventInstance.keys = { }
					
	for keyTime,keyVals in pairs(eventKeys) do
		if (type(keyTime) == 'number') then
			local key = {}
			key.actorID = actorID
			key.property = propName
			key.eventID = eventID
			key.time = keyTime
			key.keyFields = keyVals
			key.eventFields = eventInstance.eventFields
			InitializeKeyFields(propDef.keyFields, key.keyFields)
			
			key.eventInstance = eventInstance
			table.insert(eventInstance.keys, key)
		end
	end
	
	-- sort keys within event
	table.sort(eventInstance.keys, SceneTimelineSortKeysComparison)
	
	return eventInstance
end

function SceneTimelineTokenizePath(path)
	local tokens = { }
	local curPos = 1
	local delimStart, delimEnd, subFolder
	while curPos do
		delimStart, delimEnd = string.find(path, "\\", curPos);
		if (delimEnd) then
			subFolder = string.sub(path, curPos, delimStart-1)
			curPos = delimEnd+1
		else
			subFolder = string.sub(path, curPos, #path)
			curPos = nil
		end
		table.insert(tokens, subFolder)
	end
--[[
	-- test print
	local tokenString = ""
	for n,token in ipairs(tokens) do
		if (n > 1) then
			tokenString = tokenString .. ", "
		end
		tokenString = tokenString .. token
	end
	print(tokenString)
]]
	return tokens
end

function SceneTimelineFindScriptContext(scriptData)	
	local scriptContext
	if (Scene.GetCurrentContext) then
		-- in dev work for WOWEdit saving
		-- also has the nice benefit of not requiring stack parsing
		scriptContext = scene:GetCurrentContext()
		scriptContext.scriptPath = scriptContext.scriptPath or ""
		scriptContext.looseFile = scriptContext.looseFile or ""

		local pathTokens
		if (#scriptContext.scriptPath > 0) then
			pathTokens = SceneTimelineTokenizePath(scriptContext.scriptPath)
		else
			pathTokens = SceneTimelineTokenizePath(scriptContext.looseFile)
		end

		local numTokens = #pathTokens
		if (numTokens > 0) then
			scriptData.scriptFile = pathTokens[numTokens]
			scriptData.scriptFile = string.gsub(scriptData.scriptFile, ".lua", "")
		end
	end
	scriptData.scriptContext = scriptContext
	return scriptData
end

function SceneTimelineAddFileData(scriptFile, sceneData)
	-- group sceneData by which source file it came out of
	local fileData = sceneData.attributes
	local scriptData = {}
	scriptData.scriptContext = {}
	scriptData.scriptFile = scriptFile 

	scriptData = SceneTimelineFindScriptContext(scriptData)

	for actorName,actorData in pairs(sceneData.actors) do
		local realActorData = actorData.properties

		table.insert(sceneInputData, realActorData)
		realActorData.actorID = #sceneInputData
		realActorData.attributes = actorData.attributes
		realActorData.actorPartialName = actorName
		if (#scriptData.scriptFile) then
			realActorData.actorName = scriptData.scriptFile .. "\\" .. actorName
		else
			realActorData.actorName = actorName
		end
		realActorData.scriptContext = scriptData.scriptContext
	end
end

function SceneTimelineAddInputData(scriptFile, sceneData)
	-- group sceneData by which source file it came out of
	local scriptData = {}
	scriptData.scriptContext = {}
	scriptData.scriptFile = scriptFile 

	scriptData = SceneTimelineFindScriptContext(scriptData)

	for actorName,actorData in pairs(sceneData) do
		table.insert(sceneInputData, actorData)
		actorData.actorID = #sceneInputData
		
		actorData.actorPartialName = actorName
		if (#scriptData.scriptFile) then
			actorData.actorName = scriptData.scriptFile .. "\\" .. actorName
		else
			actorData.actorName = actorName
		end
		actorData.scriptContext = scriptData.scriptContext
	end
end

-- backwards compatibility for spelling mistake
SceneTimlineAddInputData = SceneTimelineAddInputData

function SceneTimelineSpawnActor(createData)
	local actor = scene:SpawnActor(createData)

	if (createData.timelineInstance) then
		createData.timelineInstance.actorMap[createData.actorID] = actor
		createData.timelineInstance.actorIDByName[string.lower(createData.actorName)] = createData.actorID
		if (createData.actorPartialName) then
			createData.timelineInstance.actorIDByPartialName[string.lower(createData.actorPartialName)] = createData.actorID
		end
	end

	actor.actorID = createData.actorID
	actor.actorName = createData.actorName
	actor.actorPartialName = createData.actorPartialName
	actor.timelineInstance = createData.timelineInstance
	actor.initialCreateData = createData

	return actor
end

local SortPropertiesComparison = function(a, b)
	local aFrameDelay = a.frameDelay or DEFAULT_FRAME_DELAY
	local bFrameDelay = b.frameDelay or DEFAULT_FRAME_DELAY
	if (aFrameDelay ~= bFrameDelay) then
		return (aFrameDelay < bFrameDelay)
	end

	local aPrio = a.priority or 0
	local bPrio = b.priority or 0
	return (a.aPrio < b.bPrio)
end

function SceneTimelineCreate()
	local instance = { }
	instance.sceneData = sceneInputData
	instance.actorMap = { }
	instance.actorIDByName = { }
	instance.actorIDByPartialName = { }
	instance.actorCreateDataMap = { }
	instance.pendingEvents = { }
	instance.processedEvents = { }
	instance.pendingTime = 0
	instance.processedTime = 0
	instance.playBackID = 0
	instance.playBackRate = 1.0
	instance.paused = false
	instance.eventsByID = { }
	instance.propertyByID = { }
	instance.propertyByName = { }
	instance.lastAppliedEvents = { }
	instance.nullKeysByProp = { }
	instance.actorVisibilityDisabled = {}
	
	-- property set up
	local numProperties = 0
	
	-- sort properties in descending order of priority
	table.sort(instance.processedEvents, SortPropertiesComparison)

	for propName, propDef in pairs(scenePropertyData) do
		numProperties = numProperties + 1
		instance.propertyByID[numProperties] = propDef
		instance.propertyByName[propName] = propDef

		propDef.propertyID = numProperties;
		propDef.propertyName = propName;

		propDef.minEventKeys = propDef.minEventKeys or 1
		propDef.maxEventKeys = propDef.maxEventKeys or 1
		if (propDef.maxEventKeys < propDef.minEventKeys) then
			propDef.maxEventKeys = propDef.minEventKeys
		end

		local nullEventKeys = {}
		for keyIndex = 1,propDef.minEventKeys do
			local nullTime = (keyIndex-1)*0.001
			nullEventKeys[nullTime] = {}
		end
				
		local nullEventInstance = SceneTimelineCreateEventInstance("", propName, propDef, 0, nullEventKeys)
		for keyIndex,key in pairs(nullEventInstance.keys) do
			key.keyID = 0
			key.keyIndex = keyIndex
		end
		
		local nullKey = nullEventInstance.keys[1]
		if (nullKey) then
			instance.nullKeysByProp[propName] = nullKey
		end	
		
		propDef.defaultKey = nullKey
	end

	-- unique index for all keys and events
	local eventID = 0
	local keyID = 0
	local keyIndex = 0
				
	-- make a flattened list of keyed events
	-- any properties that can be handled by create data
	-- will be stored there and discarded
	for _,actorData in pairs(instance.sceneData or { }) do
		local actorID = actorData.actorID

		local disabledActor = false
		
		-- finds if player has a condition and disables actor if not true
		-- only in use on official client scene 
		-- (we want to preserve the actor if in timeline editor)
		local playerConditionEvents = actorData["PlayerCondition"]
		if not scene:IsTimelineEditing() and playerConditionEvents then
			if playerConditionEvents.events then
				for _,event in pairs(playerConditionEvents.events) do
					for _,key in pairs(event) do
						for _,value in pairs(key) do
							if not scene:EvalPlayerCondition(value) then
								disabledActor = true
							end
						end
					end
				end
			end
		end

		if not disabledActor then
			-- default the create data
			local createData = instance.actorCreateDataMap[actorID]
			if (not createData) then
				createData = ActorCreateData:Default()
				instance.actorCreateDataMap[actorID] = createData
				createData.actorID = actorID
				createData.actorName = actorData.actorName
				createData.actorPartialName = actorData.actorPartialName
				createData.scriptContext = actorData.scriptContext
				createData.timelineInstance = instance
				createData.sceneEditorActorID = actorID
				for propName,propDef in pairs(instance.propertyByName) do
					local nullKey = instance.nullKeysByProp[propName]
					if (nullKey and propDef.ApplyToCreateData) then
						propDef.ApplyToCreateData(propDef, createData, nullKey)
					end
				end
			end

			-- iterate actual keyed properties
			for property,propertyData in pairs(actorData) do
				local trackData = propertyData
				local propDef = instance.propertyByName[property]
				if (propDef) then	
					if propertyData.events then
						trackData = propertyData.events
					end
					for _,eventKeys in pairs(trackData) do
						eventID = eventID + 1				

						local eventInstance = SceneTimelineCreateEventInstance(actorID, property, propDef, eventID, eventKeys)
						instance.eventsByID[eventID] = eventInstance

						-- assign IDs and indices					
						for keyIndex,key in pairs(eventInstance.keys) do
							keyID = keyID + 1
							key.keyID = keyID
							key.keyIndex = keyIndex
							if (key.time <= INITIAL_KEY_TIME) and (propDef.ApplyToCreateData) then
								propDef.ApplyToCreateData(propDef, createData, key)
								table.insert(instance.processedEvents, key)
							else
								table.insert(instance.pendingEvents, key)
							end	
						end
					end
				end
			end
		end
	end

	SortKeys(instance)

	if (SceneTimelineEditorImport) then
		SceneTimelineEditorImport(instance)
	end

	-- build actors
	for actorID,createData in pairs(instance.actorCreateDataMap) do
		local actor = SceneTimelineSpawnActor(createData)
	end

	-- wait until all actors are loaded
	local pendingLoads = true
	while pendingLoads do
		pendingLoads = false
		for actorID, actor in pairs(instance.actorMap) do
			if (not actor:IsReadyToDisplay()) then
				pendingLoads = true
				break
			end
		end
		if (pendingLoads) then
			scene:WaitTimer(0)
		end
	end

	-- start everything off
	scene:SetPauseDebugCinematic(false)
	scene:SetDebugCinematicCurrentTime(0.0)
	SceneTimelineProcessTime(instance)

	return instance
end

SortKeys = function(instance)
	table.sort(instance.processedEvents, SceneTimelineSortKeysComparison)
	table.sort(instance.pendingEvents, SceneTimelineSortKeysComparison)
end

function SceneTimelineSortKeysComparison(a, b)
	-- sort the keys in (time, property, actor) order
	if (a.time ~= b.time) then
		return (a.time < b.time)
	elseif (a.propertyID ~= b.propertyID) then
		return (a.propertyID < b.propertyID)
	else
		return (a.actorID < b.actorID)
	end
end


-- WoW.tools debug output: SceneScript name: Timeline Editor Types

--
-- Editor Data Definitions and Import/Export
-- Version control source file WoW\Source\Object\ObjectClient\SceneTimelineFramework\timeline_030_EditorTypes.lua
-- Programmers should edit in the repository first before updating in WOWEdit
--

sceneTimelineDataTypes = { }

sceneTimelineDataTypes[TimelineDataType.Boolean] =
{
	WriteToEditor = function(editorKey, field)
		editorKey.boolData = field;
	end;
	ReadFromEditor = function(editorKey, dstTable, dstKey)
		dstTable[dstKey] = editorKey.boolData
	end;
}

sceneTimelineDataTypes[TimelineDataType.Integer] =
{
	WriteToEditor = function(editorKey, field)
		editorKey.integerData = field;
	end;
	ReadFromEditor = function(editorKey, dstTable, dstKey)
		dstTable[dstKey] = editorKey.integerData
	end;
}
sceneTimelineDataTypes[TimelineDataType.Record] = sceneTimelineDataTypes[TimelineDataType.Integer] 

sceneTimelineDataTypes[TimelineDataType.Float] =
{
	WriteToEditor = function(editorKey, field)
		editorKey.floatData = field;
	end;
	ReadFromEditor = function(editorKey, dstTable, dstKey)
		dstTable[dstKey] = editorKey.floatData
	end;
}
sceneTimelineDataTypes[TimelineDataType.Vector] =
{
	WriteToEditor = function(editorKey, field)
		editorKey.transformData.position = field;
		editorKey.transformData.yaw = 0
		editorKey.transformData.pitch = 0
		editorKey.transformData.roll = 0
	end;

	ReadFromEditor = function(editorKey, dstTable, dstKey)
		dstTable[dstKey] = editorKey.transformData.position
	end;
}

sceneTimelineDataTypes[TimelineDataType.WorldPosition] = sceneTimelineDataTypes[TimelineDataType.Vector] 
sceneTimelineDataTypes[TimelineDataType.SplinePosition] = sceneTimelineDataTypes[TimelineDataType.Vector] 

sceneTimelineDataTypes[TimelineDataType.Transform] =
{
	WriteToEditor = function(editorKey, field)
		editorKey.transformData = field;
	end;
	ReadFromEditor = function(editorKey, dstTable, dstKey)
		dstTable[dstKey] = editorKey.transformData
	end;
}
sceneTimelineDataTypes[TimelineDataType.WorldTransform] = sceneTimelineDataTypes[TimelineDataType.Transform]
sceneTimelineDataTypes[TimelineDataType.SplineTransform] = sceneTimelineDataTypes[TimelineDataType.Transform]

sceneTimelineDataTypes[TimelineDataType.String] =
{
	WriteToEditor = function(editorKey, field)
		editorKey.stringData = field;
	end;
	ReadFromEditor = function(editorKey, dstTable, dstKey)
		dstTable[dstKey] = editorKey.stringData
	end;
}
sceneTimelineDataTypes[TimelineDataType.Actor] = sceneTimelineDataTypes[TimelineDataType.String]


-- WoW.tools debug output: SceneScript name: Timeline Editor

--
-- Editor API
-- Version control source file WoW\Source\Object\ObjectClient\SceneTimelineFramework\timeline_040_Editor.lua
-- Programmers should edit in the repository first before updating in WOWEdit
--

local SceneTimelineEditorExportActor
local SceneTimelineEditorExportKey
local SceneTimelineScrub
local SetSceneTimeAndRefresh
local EditorNewActor
local SceneTimelineActorAdded
local SceneTimelineActorRemove
local SceneTimelineKeyChanged
local UpdateEventTiming

local PopulateFieldForExport = function(field)
	field.metaData = { }
	for metaKey, metaValue in pairs(field.meta or { }) do
		local metaEntry = 
		{
			name = metaKey,
			value = {
				boolData = false,
				integerData = 0,
				floatData = 0.0,
				transformData = Transform:New(),
				stringData = "",			
			},
		}

		local metaType = type(metaValue)
		if (metaType == "number") then
			metaEntry.value.integerData = metaValue
			metaEntry.value.floatData = metaValue
			if (metaValue == 0) then
				metaEntry.value.boolData = false
			else
				metaEntry.value.boolData = true
			end
			table.insert(field.metaData, metaEntry)
		elseif (metaType == "boolean") then
			if (metaValue) then
				metaEntry.value.integerData = 1
				metaEntry.value.floatData = 1.0
				metaEntry.value.boolData = true
			else
				metaEntry.value.integerData = 0
				metaEntry.value.floatData = 0.0
				metaEntry.value.boolData = false
			end
			table.insert(field.metaData, metaEntry)
		elseif (metaType == "string") then
			metaEntry.value.stringData = metaValue
			table.insert(field.metaData, metaEntry)
		elseif (metaType == "table") then
			if (metaValue.position) then
				metaEntry.value.transformData = metaValue
				table.insert(field.metaData, metaEntry)
			end
		end
	end
end

local exportProp = { }

function SceneTimelineEditorImport(instance)
	for propName, propDef in pairs(instance.propertyByName) do
		exportProp.ID = propDef.propertyID
		exportProp.name = propName
		exportProp.minEventKeys = propDef.minEventKeys
		exportProp.maxEventKeys = propDef.maxEventKeys

		-- populates metadata for property
		PopulateFieldForExport(propDef)
		exportProp.metaData = propDef.metaData

		if (exportProp.maxEventKeys < exportProp.minEventKeys) then
			exportProp.maxEventKeys = exportProp.minEventKeys
		end
		
		exportProp.eventFields = propDef.eventFields or { }
		exportProp.keyFields = propDef.keyFields or { }
		for _,field in ipairs(exportProp.eventFields) do
			PopulateFieldForExport(field)
		end
		for _,field in ipairs(exportProp.keyFields) do
			PopulateFieldForExport(field)
		end

		-- find the defaults for export (nil will yield defaults)
		exportProp.defaultEvent = TimelineKey:Default()
		exportProp.defaultKey = TimelineKey:Default()
		
		SceneTimelinePropertyConvertForExport(exportProp.defaultEvent.eventFields, propDef.eventFields, propDef.defaultKey.eventFields)
		SceneTimelinePropertyConvertForExport(exportProp.defaultKey.keyFields,     propDef.keyFields,   propDef.defaultKey.keyFields)

		scene:ImportTimelineProperty(exportProp)
	end

	for _,createData in pairs(instance.actorCreateDataMap) do
		SceneTimelineEditorExportActor(createData)
	end

	-- export to game editor in sorted order
	for _,event in ipairs(instance.processedEvents) do
		SceneTimelineEditorExportKey(instance, event)
	end
	for _,event in ipairs(instance.pendingEvents) do
		SceneTimelineEditorExportKey(instance, event)
	end

	scene:ImportTimelineComplete()
end

local exportActor = { }
SceneTimelineEditorExportActor = function(createData)
	exportActor.actorID    = createData.actorID
	exportActor.actorName  = createData.actorName
	if (Scene.GetCurrentContext) then
		-- in dev work for WOWEdit saving
		exportActor.scriptContext = createData.scriptContext
	else
		exportActor.scriptFile = ""
	end
	scene:ImportTimelineActor(exportActor)
end

local exportKeyByProperty = { }
SceneTimelineEditorExportKey = function(instance, event)
	if (not event.property) then
		return
	end
	local propDef = instance.propertyByName[event.property]
	if (not propDef) then
		return
	end

	-- avoid a lot of garbage collection by building a base scene event
	-- for exporting for each property
	local editorKey = exportKeyByProperty[event.property]
	if (not exportKeyData) then
		editorKey = TimelineKey:Default()
		exportKeyByProperty[event.property] = editorKey
	end

	editorKey.keyIndex = (event.keyIndex - 1) -- Lua is 1 based
	editorKey.keyID = event.keyID
	editorKey.eventID = event.eventID
	editorKey.propertyIndex = propDef.propertyID
	editorKey.actorID = event.actorID
	editorKey.keyTime = event.time

	SceneTimelinePropertyConvertForExport(editorKey.eventFields, propDef.eventFields, event.eventFields)
	SceneTimelinePropertyConvertForExport(editorKey.keyFields,   propDef.keyFields,   event.keyFields)
	
	scene:ImportTimelineKey(editorKey)
end

SceneTimelineScrub = function(instance, time, paused, rate)
	instance.playBackRate = rate
	if (paused) then
		instance.paused = true
	else
		instance.paused = false
	end

	scene:SetPauseDebugCinematic(instance.paused)
	scene:SetDebugCinematicCurrentTime(time)

	SetSceneTimeAndRefresh(instance, time)
end

SetSceneTimeAndRefresh = function(instance, time)
	local allKeys = { }
	instance.processedEvents = { }
	instance.pendingEvents   = { }
	
	-- re-add all keys as pending and sort
	for eventID, event in pairs(instance.eventsByID) do
		for keyIndex, key in ipairs(event.keys) do
			table.insert(allKeys, key)
		end
	end	
	table.sort(allKeys, SceneTimelineSortKeysComparison)
	
	-- re-bucket all the keys based on the current time
	-- apply simple keys as we go
	-- accumulate properties with a custom scrub function for application in one hit
	local propDef
	local actor
	
	local scrubKeysByActor = { }
	local allScrubProps = { }
	local scrubKeysForActor
	local scrubKeysForActorProp

	for overallKeyIndex, key in ipairs(allKeys) do
		propDef = instance.propertyByName[key.property]
		actor = instance.actorMap[key.actorID]
		scrubKeysForActor = nil
		scrubKeysForActorProp = nil

		if (actor and propDef.ScrubActorTo) then
			-- for scrubbed keys, always start with an empty list
			scrubKeysForActor = scrubKeysByActor[key.actorID]
			if (not scrubKeysForActor) then
				scrubKeysForActor = { }
				scrubKeysByActor[key.actorID] = scrubKeysForActor
			end
			scrubKeysForActorProp = scrubKeysForActor[key.property]
			if (not scrubKeysForActorProp) then
				scrubKeysForActorProp = { }
				scrubKeysForActorProp.propDef = propDef
				scrubKeysForActorProp.actor = actor
				scrubKeysForActorProp.orderedKeys = { }
				scrubKeysForActor[key.property] = scrubKeysForActorProp
				table.insert(allScrubProps, scrubKeysForActorProp)
			end
		end
	
		if (key.time <= time) then
			table.insert(instance.processedEvents, key)

			if (actor) then
				if (propDef.ScrubActorTo) then
					table.insert(scrubKeysForActorProp.orderedKeys, key)
				elseif (propDef.ApplyToActor) then
					propDef.ApplyToActor(propDef, actor, key, time)
				end			
			end
		else
			table.insert(instance.pendingEvents, key)
		end
		
	end
	
	-- process all the keys that have an explicit scrub function
	-- process them in order first to last completed
	local scrubSort = function(a, b)
		local aEmpty = true
		if (#a.orderedKeys > 0) then
			aEmpty = false
		end
		
		local bEmpty = true
		if (#b.orderedKeys > 0) then
			bEmpty = false
		end
		
		if (aEmpty ~= bEmpty) then
			return aEmpty
		elseif (not aEmpty and (a.orderedKeys[#a.orderedKeys].time ~= b.orderedKeys[#b.orderedKeys].time)) then
			return (a.orderedKeys[#a.orderedKeys].time < b.orderedKeys[#b.orderedKeys].time)
		elseif (a.propDef.propName ~= b.propDef.propName) then
			return (a.propDef.propName < b.propDef.propName)
		else
			return (a.actor.actorID < b.actor.actorID)
		end
	end
	
	table.sort(allScrubProps, scrubSort)
	for _,scrubKeysForActorProp in ipairs(allScrubProps) do
		scrubKeysForActorProp.propDef.ScrubActorTo(
			scrubKeysForActorProp.propDef,
			scrubKeysForActorProp.actor,
			scrubKeysForActorProp.orderedKeys,
			time)
	end

	instance.playBackID = instance.playBackID + 1	
	instance.pendingTime = time
	instance.processedTime = time
	SceneTimelineProcessTime(instance)
end

EditorNewActor = function(instance, actorID, actorName)

	-- default the create data
	local createData = ActorCreateData:Default()
	instance.actorCreateDataMap[actorID] = createData
	createData.actorID = actorID
	createData.actorName = actorName
	createData.timelineInstance = instance
	createData.sceneEditorActorID = actorID
	for propName,propDef in pairs(instance.propertyByName) do
		local nullKey = instance.nullKeysByProp[propName]
		if (nullKey and propDef.ApplyToCreateData) then
			propDef.ApplyToCreateData(propDef, createData, nullKey)
		end
	end
	
	local actor = SceneTimelineSpawnActor(createData)

	actor.lastTimelineEventsByProperty = { }
	return actor
end

SceneTimelineActorAdded = function(instance, event)
	EditorNewActor(instance, event.editorKey.actorID, event.stringData)
end

SceneTimelineActorRemove = function(instance, event)

	-- brute force kill related keys
	local nextPending = { }
	for i,v in ipairs(instance.processedEvents) do
		if (v.actorID ~= event.editorKey.actorID) then
			table.insert(nextPending, v)
		else
			instance.eventsByID[v.eventID] = nil
		end
	end
	for i,v in ipairs(instance.pendingEvents) do
		if (v.actorID ~= event.editorKey.actorID) then
			table.insert(nextPending, v)
		else
			instance.eventsByID[v.eventID] = nil
		end
	end
	instance.processedEvents = { }
	instance.pendingEvents = nextPending

	instance.actorCreateDataMap[event.editorKey.actorID] = nil
	local actor = instance.actorMap[event.editorKey.actorID]
	if (actor) then
		instance.actorMap[event.editorKey.actorID] = nil
		instance.actorIDByName[string.lower(actor.actorName)] = nil
		if (actor.actorPartialName) then
			instance.actorIDByPartialName[string.lower(actor.actorPartialName)] = nil
		end
		actor:Despawn()
	end

	SetSceneTimeAndRefresh(instance, event.editorTimeSeconds)
end

SceneTimelineKeyChanged = function(instance, sceneEvent)
	-- find the actor, add if necessary
	local actor = instance.actorMap[sceneEvent.editorKey.actorID]
	if (not actor) then
		return
	end

	-- find the key and edit
	local event
	local key
	
	if (sceneEvent.type == SceneEventType.EditorKeyAdd) then
		local propDef = instance.propertyByID[sceneEvent.editorKey.propertyIndex]
		if (not propDef) then
			return
		end

		key = {}
		key.actorID = sceneEvent.editorKey.actorID
		key.property = propDef.propertyName
		key.eventID = sceneEvent.editorKey.eventID
		key.keyID = sceneEvent.editorKey.keyID
		key.time = sceneEvent.editorKey.keyTime
		key.keyFields = { }
		key.eventFields = { }
		SceneTimelinePropertyConvertForImport(sceneEvent.editorKey.keyFields, propDef.keyFields, key.keyFields)
		SceneTimelinePropertyConvertForImport(sceneEvent.editorKey.eventFields, propDef.eventFields, key.eventFields)
		
		event = instance.eventsByID[sceneEvent.editorKey.eventID]	
		if (not event) then
			event = SceneTimelineCreateEventInstance(sceneEvent.editorKey.actorID, propDef.propertyName, propDef, sceneEvent.editorKey.eventID, {})
			event.eventFields = key.eventFields
			instance.eventsByID[sceneEvent.editorKey.eventID] = event
		end	
		key.eventInstance = event
			
		table.insert(event.keys, key)
		
		if (sceneEvent.editorKey.keyTime < sceneEvent.editorTimeSeconds) then
			needsRefresh = true
		end
	else
		event = instance.eventsByID[sceneEvent.editorKey.eventID]
		if (not event) then
			return
		end
		for _,eventKey in pairs(event.keys) do
			if (eventKey.keyID == sceneEvent.editorKey.keyID) then
				key = eventKey
			end
		end
		if (not key) then
			return
		end	

		if (event.keys[1].time < sceneEvent.editorTimeSeconds) then
			needsRefresh = true
		end
		
		if (sceneEvent.type == SceneEventType.EditorKeyChange) then
			key.time = sceneEvent.editorKey.keyTime

			local propDef = instance.propertyByName[key.property]
			if (propDef) then
				SceneTimelinePropertyConvertForImport(sceneEvent.editorKey.keyFields, propDef.keyFields, key.keyFields)
				SceneTimelinePropertyConvertForImport(sceneEvent.editorKey.eventFields, propDef.eventFields, key.eventFields)
			end

			if (sceneEvent.editorKey.keyTime < sceneEvent.editorTimeSeconds) then
				needsRefresh = true
			end
		elseif (sceneEvent.type == SceneEventType.EditorKeyRemove) then
			key.deleted = true
		end
	end
	
	UpdateEventTiming(instance, event)
	
	return true
end

UpdateEventTiming = function(instance, event)
	local numKeys = 0
	event.nextKeys = { }
	for _,eventKey in pairs(event.keys) do
		if (not eventKey.deleted) then
			table.insert(event.nextKeys, eventKey)
			numKeys = numKeys + 1
		end
	end
	
	-- sort keys within event
	event.keys = event.nextKeys
	event.nextKeys = nil
	
	if (numKeys == 0) then
		instance.eventsByID[event.eventID] = nil			
	elseif (numKeys > 1) then
		table.sort(event.keys, SceneTimelineSortKeysComparison)
	end

	-- update key index add any remaining keys into the appropriate list
	for keyIndex,eventKey in pairs(event.keys) do
		eventKey.keyIndex = keyIndex
	end
end

function SceneTimelinePropertyConvertForExport(dstEditorFields, fields, srcFields)
	if (not dstEditorFields) or (not fields) or (not srcFields) then
		return
	end
	
	local dataType
	local eventFieldData
	local srcField
	for fieldIndex,field in pairs(fields) do
		eventFieldData = dstEditorFields[fieldIndex]
		if (not eventFieldData) then
			eventFieldData = TimelineKeyField:Default()
			dstEditorFields[fieldIndex] = eventFieldData
		end	

		srcField = srcFields[field.name]
		if ((srcField ~= nil) and field.type) then
			dataType = sceneTimelineDataTypes[field.type]
			if (dataType) then
				dataType.WriteToEditor(eventFieldData, srcField)
			end
		end
	end
end

function SceneTimelinePropertyConvertForImport(srcEditorFields, fields, dstFields)
	if (not srcEditorFields) or (not fields) or (not dstFields) then
		return
	end
	
	local dataType
	local eventFieldData
	for fieldIndex,field in pairs(fields) do
		if (field.type) then
			dataType = sceneTimelineDataTypes[field.type]
			eventFieldData = srcEditorFields[fieldIndex]
			if (dataType and eventFieldData) then
				dataType.ReadFromEditor(eventFieldData, dstFields, field.name)
			end
		end
	end
end

--
-- main editor loop
--
function MainEditorLoop()
	while true do
		scene:WaitTimer(0)
		local evt = scene:PeekEvent()
		local refreshTime = nil
		while (mainTimelineInstance and (evt.type ~= SceneEventType.None)) do
			scene:PopEvent()
			if (evt.type == SceneEventType.EditorPause) then
				SceneTimelineScrub(mainTimelineInstance, evt.editorTimeSeconds, true, evt.floatData)
			elseif (evt.type == SceneEventType.EditorPlay) then
				SceneTimelineScrub(mainTimelineInstance, evt.editorTimeSeconds, false, evt.floatData)
			elseif (evt.type == SceneEventType.EditorActorAdd) then
				SceneTimelineActorAdded(mainTimelineInstance, evt)
				refreshTime = evt.editorTimeSeconds
			elseif (evt.type == SceneEventType.EditorActorRemove) then
				SceneTimelineActorRemove(mainTimelineInstance, evt)
				refreshTime = evt.editorTimeSeconds
			elseif (evt.type == SceneEventType.EditorKeyChange or evt.type == SceneEventType.EditorKeyAdd or evt.type == SceneEventType.EditorKeyRemove) then
				SceneTimelineKeyChanged(mainTimelineInstance, evt)
				refreshTime = evt.editorTimeSeconds
			elseif scene:IsTimelineEditing() and evt.type == SceneEventType.EditorActorVisibilityEnable  then
				SceneTimelineActorVisibility(mainTimelineInstance, evt.integerData, true)
				refreshTime = evt.editorTimeSeconds
			elseif scene:IsTimelineEditing() and evt.type == SceneEventType.EditorActorVisibilityDisable then
				SceneTimelineActorVisibility(mainTimelineInstance, evt.integerData, false)
				refreshTime = evt.editorTimeSeconds
			end
			evt = scene:PeekEvent()
		end
	
		-- only refresh once when there are mutliple events on a frame
		if (refreshTime) then
			SetSceneTimeAndRefresh(mainTimelineInstance, refreshTime)
		end
	end
end

if (scene:IsTimelineEditing()) then
	scene:AddCoroutine(MainEditorLoop)
end


-- WoW.tools debug output: SceneScript name: Timeline Main

--
-- Main Loop
-- Version control source file WoW\Source\Object\ObjectClient\SceneTimelineFramework\timeline_050_Main.lua
-- Programmers should edit in the repository first before updating in WOWEdit
--
scene:SetRelativeCoords(false)
-- give a chance for all the data scripts to execute
-- this is achieved by spawning a new coroutine, which will push it to the end of script execution
mainTimelineInstance = nil
local sceneInit = function()
	mainTimelineInstance = SceneTimelineCreate()
end
scene:AddCoroutine(sceneInit)

-- wait forever, and 'End' key is required to end a scene
-- this coroutine just needs to spin forever so mainTimelineInstance
-- is not garbage collected by the Lua VM
while true do
	scene:WaitTimer(60*60);
end


--WoW.tools debug output: End of package 3189



-- WoW.tools debug output: Start of package 3190


-- WoW.tools debug output: SceneScript name: Timeline Properties - RTC

SceneTimelineAddStatePropertyOneShot("Appearance",
{	
	meta = 
	{
		description = "NOTE: setting this key may override earlier property keys such as groundsnap.",
	},
	keyFields =
	{
		{ 
			name = "creatureID",
			type = TimelineDataType.Record,
			default = 121295, -- invisible stalker
			meta = 
			{
				table = "Creature",
				tableWrapperType = "cid",
			}
		},
		{ 
			name = "creatureDisplaySetIndex",
			type = TimelineDataType.Integer,
			default = 0,
		},
		{ 
			name = "creatureDisplayInfoID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "CreatureDisplayInfo",
				tableWrapperType = "cdiid",
			}
		},
		{ 
			name = "fileDataID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "FileData",
				tableWrapperType = "fid",
			}
		},
		{ 
			name = "wmoGameObjectDisplayID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "GameObjectDisplayInfo",
				tableWrapperType = "gdi",
			}
		},
		{ 
			name = "itemID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "Item",
				tableWrapperType = "iid",
			}
		},		
		{ 
			name = "isPlayerClone",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{ 
			name = "isPlayerCloneNative",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "playerSummon",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "playerGroupIndex",
			type = TimelineDataType.Integer,
			default = 0,
		},
		{
			name = "smoothPhase",
			type = TimelineDataType.Boolean,
			default = false,
		},
	},

	SetStateCreateData = function(property, createData, key)
		createData.playerCloneToken = ""
		createData.playerCloneIsNative = true
		createData.creatureID = key.keyFields.creatureID
		createData.creatureDisplaySetIndex = key.keyFields.creatureDisplaySetIndex
		createData.creatureDisplayID = key.keyFields.creatureDisplayInfoID
		createData.modelFileID = key.keyFields.fileDataID
		createData.wmoGameObjectDisplayID = key.keyFields.wmoGameObjectDisplayID
		createData.itemID = key.keyFields.itemID
		createData.smoothPhase = key.keyFields.smoothPhase
		createData.playerSummon = key.keyFields.playerSummon

		local isPlayer = false
		if (key.keyFields.playerGroupIndex > 1) then
			isPlayer = true
			if (scene.IsPlayerInRaid and scene:IsPlayerInRaid() and (key.keyFields.playerGroupIndex <= 40)) then
				createData.playerCloneToken = "raid" .. key.keyFields.playerGroupIndex
			elseif (key.keyFields.playerGroupIndex <= 5) then
				createData.playerCloneToken = "party" .. (key.keyFields.playerGroupIndex - 1) -- party1 is not the current player
			end
		elseif ((key.keyFields.playerGroupIndex == 1) or key.keyFields.isPlayerClone or key.keyFields.isPlayerCloneNative) then
			isPlayer = true
			createData.playerCloneToken = "player"
		end

		if (isPlayer) then
			createData.playerCloneIsNative = key.keyFields.isPlayerCloneNative
			if (scene:IsTimelineEditing()) then
				createData.creatureID = 167875 -- RTC player dummy 
			else
				createData.creatureID = 121295 -- invisible stalker for not found players
			end
			createData.modelFileID = 0
			createData.wmoGameObjectDisplayID = 0
			createData.itemID = 0
			createData.creatureDisplayID = 0
			createData.creatureDisplaySetIndex = 0
			createData.playerSummon = false
		end
	end,

	SetStateActor = function(property, actor, key)
		local createData = { }
		property.SetStateCreateData(property, createData, key)

		if (createData.playerCloneToken			~= actor.initialCreateData.playerCloneToken) or
		   (createData.playerCloneIsNative		~= actor.initialCreateData.playerCloneIsNative) or
		   (createData.creatureID				~= actor.initialCreateData.creatureID) or
		   (createData.creatureDisplaySetIndex  ~= actor.initialCreateData.creatureDisplaySetIndex) or
		   (createData.creatureDisplayID		~= actor.initialCreateData.creatureDisplayID) or
		   (createData.modelFileID				~= actor.initialCreateData.modelFileID) or
		   (createData.playerSummon				~= actor.initialCreateData.playerSummon) or
		   (createData.wmoGameObjectDisplayID	~= actor.initialCreateData.wmoGameObjectDisplayID) or
		   (createData.itemID					~= actor.initialCreateData.itemID) then
			actor.initialCreateData.playerCloneToken = createData.playerCloneToken
			actor.initialCreateData.playerCloneIsNative = createData.playerCloneIsNative
			actor.initialCreateData.creatureID = createData.creatureID
			actor.initialCreateData.creatureDisplaySetIndex = createData.creatureDisplaySetIndex
			actor.initialCreateData.creatureDisplayID = createData.creatureDisplayID
			actor.initialCreateData.modelFileID = createData.modelFileID
			actor.initialCreateData.playerSummon = createData.playerSummon
			actor.initialCreateData.wmoGameObjectDisplayID = createData.wmoGameObjectDisplayID
			actor.initialCreateData.itemID = createData.itemID
			actor:SetModel(actor.initialCreateData)
		end
	end,
})

SceneTimelineAddStatePropertyOneShot("AreaOfInterest",
{
	meta = 
	{
		description = "NOTE: setting this to high can heavily affect performance. Only do this if required",
	},
	keyFields =
	{
		{
			name = "range",
			type = TimelineDataType.Integer,
			default = 1,
		},
	},

	SetStateCreateData = function(property, createData, key)
		createData.aoiSettings.range = key.keyFields.range
	end,
})

SceneTimelineAddStatePropertyOneShot("Shadow",
{
	keyFields =
	{
		{
			name = "shadow",
			type = TimelineDataType.Boolean,
			default = true,
		},
	},

	SetStateCreateData = function(property, createData, key)
		createData.noShadow = not key.keyFields.shadow
	end,

	SetStateActor = function(property, actor, key)
		actor:SetShadows(key.keyFields.shadow)
	end,
})

SceneTimelineAddStatePropertyOneShot("GroundSnap",
{
	priority = 2000,

	keyFields =
	{
		{
			name = "snap",
			type = TimelineDataType.Boolean,
			default = true,
		},
	},

	SetStateCreateData = function(property, createData, key)
		createData.groundSnap = key.keyFields.snap
	end,

	SetStateActor = function(property, actor, key)
		actor:SetSnapToGround(key.keyFields.snap)
	end,
})

SceneTimelineAddStatePropertyOneShot("Transform",
{
	priority = 1000,

	keyFields =
	{
		{
			name = "transform",
			type = TimelineDataType.WorldTransform,
			default = { position={x=0, y=0, z=0}, yaw=0, pitch=0, roll=0 },
		},
	},

	SetStateCreateData = function(property, createData, key)
		createData.transform = key.keyFields.transform
	end,

	SetStateActor = function(property, actor, key)
		actor:SetTransform(key.keyFields.transform)	
	end,
})

local setScaleData =
{
	scale = 1.0;
	scaleDuration = 2000; -- milliseconds
} 

SceneTimelineAddStatePropertyOneShot("Scale",
{
	keyFields =
	{
		{
			name = "scale",
			type = TimelineDataType.Float,
			default = 1.0,
		},
		{
			name = "duration",
			editorDescription = "seconds",
			type = TimelineDataType.Float,
			default = 2.0,
			meta = 
			{
				duration = true,
			}
		},
	},

	SetStateCreateData = function(property, createData, key)
		if key.keyFields.scale < 0 then
			key.keyFields.scale = 1
		end
		
		createData.scale = key.keyFields.scale
	end,

	SetStateActor = function(property, actor, key)
		if key.keyFields.scale < 0 then
			key.keyFields.scale = 1
		end

		setScaleData.scale = key.keyFields.scale
		setScaleData.scaleDuration = key.keyFields.duration * 1000 -- convert to MS
		-- hack - 0 duration scale change not allowed
		if (setScaleData.scaleDuration <= 0) then
			setScaleData.scaleDuration = 1
		end

		actor:SetScaleEx(setScaleData)
	end,
})


SceneTimelineAddStatePropertyOneShot("Performance",
{
	keyFields =
	{
		{
			name = "DisableUpdates",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "DespawnIfLowPerformance",
			type = TimelineDataType.Boolean,
			default = false,
		},
	},

	SetStateCreateData = function(property, createData, key)
		if not scene:IsTimelineEditing() then
			createData.disableUpdates = key.keyFields.DisableUpdates
		else
			createData.disableUpdates = false
		end
	end,

	SetStateActor = function(property, actor, key)
		if not scene:IsTimelineEditing() then
			actor:SetDisableUpdates(key.keyFields.DisableUpdates)

			if key.keyFields.DespawnIfLowPerformance and scene:IsLowSpecGraphics() then		
				actor:Despawn()
			end
		end
	end,
})

SceneTimelineAddStatePropertyOneShot("Distance",
{
	keyFields = 
	{
		{
			name = "cancelSceneAtDistance",
			type = TimelineDataType.Boolean,
			default = false,
			meta = 
			{
				fieldGroupBox = "CancelScene",
			}
		},		
		{
			name = "sceneDistance",
			type = TimelineDataType.Float,
			default = 200.0,
			meta = 
			{
				fieldGroupBox = "CancelScene",
			}
		},		
		{
			name = "cancelSceneTarget",
			type = TimelineDataType.Actor,
			default = "",
			meta = 
			{
				fieldGroupBox = "CancelScene",
			}
		},		
		{
			name = "cancelBroadcastTextAtDistance",
			type = TimelineDataType.Boolean,
			default = false,
			meta = 
			{
				fieldGroupBox = "BroadcastText",
			}
		},		
		{
			name = "broadcastTextDistance",
			type = TimelineDataType.Float,
			default = 200.0,
			meta = 
			{
				fieldGroupBox = "BroadcastText",
			}
		},
	},

	SetStateActor = function(property, actor, key)
		if key.keyFields.cancelBroadcastTextAtDistance and key.keyFields.broadcastTextDistance > 0.0 then
			scene:SetCancelBroadcastTextAtDistance(key.keyFields.broadcastTextDistance)
		else
			scene:SetCancelBroadcastTextAtDistance(0.0)
		end

		if scene:IsTimelineEditing() then
			return
		end

		if key.keyFields.cancelSceneAtDistance and key.keyFields.sceneDistance > 0.0 then
			local targetActor = SceneTimelineGetActor(actor, key.keyFields.cancelSceneTarget)
			if targetActor then
				scene:CancelSceneAtDistanceTarget(key.keyFields.sceneDistance, targetActor)
			else					
				scene:CancelSceneAtDistance(key.keyFields.sceneDistance)
			end
		else
			scene:CancelSceneAtDistance(0.0)
		end
	

	end
})


SceneTimelineAddStatePropertyOneShot("Despawn",
{
	keyFields =
	{
		{
			name = "despawn",
			type = TimelineDataType.Boolean,
			default = true,
		},
	},

	SetStateActor = function(property, actor, key)
		if not scene:IsTimelineEditing() and key.keyFields.despawn then
			actor:Despawn()
		end
	end,
})


SceneTimelineAddStatePropertyOneShot("HeadFacingTarget",
{
	meta = 
	{
		description = "NOTE: Only use unclampLookAtPitchAngle if using VERY controlled\nCinematic cameras as this has a very large chance of causing clipping",
	},
	priority = 50,

	keyFields =
	{
		{
			name = "target",
			type = TimelineDataType.Actor,
			default = "",
		},
		{
			name = "vertical", 
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "offset",
			type = TimelineDataType.Vector,
			default = { x=0, y=0, z=0 },
		},
		{
			name = "FacingTurnRate",
			type = TimelineDataType.Float,
			default = 3,
		},
		{
			name = "unclampLookAtPitchAngle",
			type = TimelineDataType.Boolean,
			default = false,
		},
	},

	SetStateActor = function(property, actor, key)
		local targetActor = SceneTimelineGetActor(actor, key.keyFields.target)
		if targetActor then
			if key.keyFields.vertical then
				local facingData = ActorHeadLookData:Default()
				facingData.headLookType = HeadLookType.Target
				facingData.target = targetActor
				if (key.keyFields.FacingTurnRate > 0) then
					facingData.headFacingTurnRate = key.keyFields.FacingTurnRate
				end
				facingData.offset = key.keyFields.offset
				facingData.increaseLookAtPitchAngle = key.keyFields.unclampLookAtPitchAngle
				actor:SetHeadFacingFull(facingData)
			else
				-- keeping the old way here for now might convert over later
				--current dont expose some of the variables needed
				if (key.keyFields.FacingTurnRate > 0) then
					actor:SetHeadFacingTurnRate(key.keyFields.FacingTurnRate)
				end
				actor:SetHeadFacingToTarget(targetActor, key.keyFields.offset)
			end
		else
			actor:ClearHeadFacing()
		end
	end,
})

SceneTimelineAddStatePropertyOneShot("FacingTarget",
{
	priority = 50,

	keyFields =
	{
		{
			name = "target",
			type = TimelineDataType.Actor,
			default = "",
		},
		{
			name = "offset",
			type = TimelineDataType.Vector,
			default = { x=0, y=0, z=0 },
		},
		{
			name = "FacingTurnRate",
			type = TimelineDataType.Float,
			default = 3,
		},
	},

	SetStateActor = function(property, actor, key)
		if (key.keyFields.FacingTurnRate > 0) then
			actor:SetFacingTurnRate(key.keyFields.FacingTurnRate)
		end

		local targetActor = SceneTimelineGetActor(actor, key.keyFields.target)
		if targetActor then
			actor:SetFacingToTarget(targetActor, key.keyFields.offset)
		else
			actor:ClearFacing()
		end
	end,
})

SceneTimelineAddProperty("CastSpell",
{
	keyFields =
	{
		{
			name = "spellID",
			type = TimelineDataType.Record,
			default = 133,
			meta = 
			{
				table = "Spell",
				tableWrapperType = "sid",
			}
		},
		{
			name = "target",
			type = TimelineDataType.Actor,
			default = "",
		},
	},

	ApplyToActor = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		local targetActor = SceneTimelineGetActor(actor, key.keyFields.target)
		if (key.keyFields.spellID > 0) and targetActor then
			actor:CastSpell(key.keyFields.spellID, targetActor)
		end	
	end,
	
	ScrubActorTo = function(prop, actor, processedKeys, time)
		-- event: no-op 
	end,
})
	
SceneTimelineAddStatePropertyEvent("PlaySpellPreCast",
{
    eventFields = 
	{
		{
			name = "spellVisualID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "SpellVisual",
				tableWrapperType = "svid",
			}
		},
	},

	GetUniqueID = function(key)
		return key.eventFields.spellVisualID
	end,

	ApplyState = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		local spellVisualID = key.eventFields.spellVisualID
		if (not actor.timelinePreCastKit) then
			actor.timelinePreCastKit = { }
		end
		if (spellVisualID > 0) then
		    actor.timelinePreCastKit[spellVisualID] = actor:PlaySpellPreCastVisual(spellVisualID)
        end
    end,
	
	RemoveState = function(property, actor, key, time)
		local spellVisualID = key.eventFields.spellVisualID
		if (not actor.timelinePreCastKit) then
			return
		end

		local instance = actor.timelinePreCastKit[spellVisualID]
		if (instance) then
			actor:ClearSpellVisual(instance)
			actor.timelinePreCastKit[spellVisualID] = nil
		end
	end,
})

SceneTimelineAddProperty("PlaySpellCast",
{
	keyFields =
	{
		{
			name = "spellVisualID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "SpellVisual",
				tableWrapperType = "svid",
			}
		},
	},

	ApplyToActor = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		if (key.keyFields.spellVisualID > 0) then
			actor:PlaySpellCastVisual(key.keyFields.spellVisualID)
		end	
	end,
	
	ScrubActorTo = function(prop, actor, processedKeys, time)
		-- event: no-op 
	end,
})

SceneTimelineAddProperty("PlaySpellCastAtTarget",
{
	keyFields =
	{
		{
			name = "spellVisualID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "SpellVisual",
				tableWrapperType = "svid",
			}
		},
		{
			name = "time",
			editorDescription = "travel time",
			type = TimelineDataType.Float,
			default = 1,
			meta = 
			{
				duration = true,
			}
		},
		{
			name = "target",
			type = TimelineDataType.Actor,
			default = "",
		},
	},

	ApplyToActor = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		local targetActor = SceneTimelineGetActor(actor, key.keyFields.target)
		if (key.keyFields.spellVisualID > 0) and targetActor then
			actor:PlaySpellCastVisualAtTargets(key.keyFields.spellVisualID, key.keyFields.time, true, { targetActor })
		end	
	end,
	
	ScrubActorTo = function(prop, actor, processedKeys, time)
		-- event: no-op 
	end,
})

SceneTimelineAddProperty("PlaySpellImpact",
{
	keyFields =
	{
		{
			name = "spellVisualID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "SpellVisual",
				tableWrapperType = "svid",
			}
		},
		{
			name = "UseAtTarget", 
			type = TimelineDataType.Boolean,
			default = false,
		},
	},

	ApplyToActor = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		if (key.keyFields.spellVisualID > 0) then
			if key.keyFields.UseAtTarget then
				actor:PlaySpellTargetImpactVisual(key.keyFields.spellVisualID)
			else
				actor:PlaySpellImpactVisual(key.keyFields.spellVisualID)
			end
			
		end	
	end,
	
	ScrubActorTo = function(prop, actor, processedKeys, time)
		-- event: no-op 
	end,
})

SceneTimelineAddStatePropertyEvent("PlaySpellState",
{
	eventFields = 
	{
		{
			name = "spellVisualID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "SpellVisual",
				tableWrapperType = "svid",
			}
		},
		{
			name = "target",
			type = TimelineDataType.Actor,
			default = "",
		},
	},

	GetUniqueID = function(key)
		return key.eventFields.spellVisualID
	end,

	ApplyState = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		local spellVisualID = key.eventFields.spellVisualID
		if (not actor.timelineStateKits) then
			actor.timelineStateKits = { }
		end
		
		local targetActor = SceneTimelineGetActor(actor, key.keyFields.target)
		if targetActor then
			actor.timelineStateKits[spellVisualID] = actor:PlaySpellStateVisualAtTargets(key.keyFields.spellVisualID, { targetActor })
		else
			actor.timelineStateKits[spellVisualID] = actor:PlaySpellStateVisual(spellVisualID)
		end
	end,
	
	RemoveState = function(property, actor, key, time)
		local spellVisualID = key.eventFields.spellVisualID
		if (not actor.timelineStateKits) then
			return
		end

		local instance = actor.timelineStateKits[spellVisualID]
		if (instance) then
			actor:ClearSpellVisual(instance)
			actor.timelineStateKits[spellVisualID] = nil
		end
	end,
})

SceneTimelineAddStatePropertyEvent("PlaySpellChannel",
{
	eventFields = 
	{
		{
			name = "spellVisualID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "SpellVisual",
				tableWrapperType = "svid",
			}
		},
		{
			name = "target",
			type = TimelineDataType.Actor,
			default = "",
		},
	},


	GetUniqueID = function(key)
		return key.eventFields.target .. "-" .. tostring(key.eventFields.spellVisualID)
	end,

	ApplyState = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		local targetActor = SceneTimelineGetActor(actor, key.eventFields.target)

		if (not actor.timelineChannelKits) then
			actor.timelineChannelKits = { }
		end

		local id = property.GetUniqueID(key)
		actor.timelineChannelKits[id] = actor:PlaySpellChannelVisualAtTargets(key.eventFields.spellVisualID, { targetActor })
	end,
	
	RemoveState = function(property, actor, key, time)
		if (not actor.timelineChannelKits) then
			return
		end

		local id = property.GetUniqueID(key)
		local instance = actor.timelineChannelKits[id]
		if (instance) then
			actor:ClearSpellVisual(instance)
			actor.timelineChannelKits[id] = nil
		end
	end,
})


SceneTimelineAddProperty("AnimKit",
{
	minEventKeys = 2,

	eventFields = 
	{
		{
			name = "animKitID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "AnimKit",
				tableWrapperType = "akid",
			}
		}
	},

	ApplyToActorInternal = function(property, actor, key, time)
		if (#key.eventInstance.keys <= 1) then
			return
		end

		if (not actor.timelineAnimKits) then
			actor.timelineAnimKits = { }
		end

		local play = false
		local offset = 0
		local startKey = key.eventInstance.keys[1]
		local endKey = key.eventInstance.keys[2]
		if (key.keyIndex == 1) and (time >= startKey.time) and (time <= endKey.time) then
			play = true
			offset = time - key.time
		end

		local kitHandle = nil
		if (play) then
			kitHandle = actor.timelineAnimKits[startKey.keyID]
			if (not kitHandle) then
				local kitParams = AnimKitData:Default()
				kitParams.animKitID = key.eventFields.animKitID
				kitParams.isMaintained = true
				kitHandle = actor:PlayAnimKitEx(kitParams)
				actor.timelineAnimKits[startKey.keyID] = kitHandle
			end
		else
			kitHandle = actor.timelineAnimKits[startKey.keyID]
			if (kitHandle) then
				actor.timelineAnimKits[startKey.keyID] = nil
				kitHandle:Stop()
			end
		end
	end,

	ApplyToActor = function(property, actor, key, time)
		property.ApplyToActorInternal(property, actor, key, time)
	end,

	ScrubActorTo = function(property, actor, processedKeys, time)
		for keyID,kitHandle in pairs(actor.timelineAnimKits or { }) do
			kitHandle:Stop()
		end
		actor.timelineAnimKits = { }

		for _,key in ipairs(processedKeys) do
			property.ApplyToActorInternal(property, actor, key, time)
		end
	end,
})

SceneTimelineAddProperty("MoveSpline",
{
	priority = 200,
	frameDelay = 0,

	minEventKeys = 2,
	maxEventKeys = 50,
	
	meta = 
	{
		description = "NOTE: ModelSpeeds and OverrideSpeeds will take precedence\nover key positions on the timeline.",
	},

	eventFields = 
	{
		{
			name = "overrideSpeed",
			type = TimelineDataType.Float,
			default = 0.0,
		},
		{
			name = "useModelRunSpeed",
			type = TimelineDataType.Boolean,
			default = false,
		},		
		{
			name = "useModelWalkSpeed",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "yawUsesSplineTangent",
			type = TimelineDataType.Boolean,
			default = true,
		},
		{
			name = "yawUsesNodeTransform",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "yawBlendDisabled",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "pitchUsesSplineTangent",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "pitchUsesNodeTransform",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "rollUsesNodeTransform",
			type = TimelineDataType.Boolean,
			default = false,
		},
	},

	keyFields = 
	{
		{
			name = "position",
			type = TimelineDataType.SplineTransform,
			default = { position={x=0, y=0, z=0}, yaw=0, pitch=0, roll=0 },
		}
	},

	ApplyToActor = function(property, actor, key, time)
		local numKeys = #key.eventInstance.keys
		if (numKeys > 1) then
			if (key.keyIndex == 1) then
				local baseTime = key.time
			
				local moveData = MoveData:Default(numKeys)
				moveData.teleportToFirstPoint = true
				moveData.initialTime = time - baseTime
				if (actor.timelineInstance.paused) then
					moveData.moveRate = 0
				else
					moveData.moveRate = actor.timelineInstance.playBackRate
				end

				if (key.eventFields.yawBlendDisabled) then
					moveData.noFacingBlend = true
				end

				local speed = key.eventFields.overrideSpeed
				if (speed == 0.0) and (key.eventFields.useModelRunSpeed) then
					speed = actor:GetAnimationSpeed(Animations.Run)
				end
				if (speed == 0.0) and (key.eventFields.useModelWalkSpeed) then
					speed = actor:GetAnimationSpeed(Animations.Walk)
				end

				if (speed > 0.0) then
					moveData.posControl = MovePosControl.PointSpeed
				else
					moveData.posControl = MovePosControl.PointTime
				end

				if (key.eventFields.yawUsesNodeTransform) then
					moveData.yawControl = MoveRotControl.Angle
				elseif (key.eventFields.yawUsesSplineTangent) then
					moveData.yawControl = MoveRotControl.Tangent
				else
					moveData.yawControl = MoveRotControl.None
				end

				if (key.eventFields.pitchUsesNodeTransform) then
					moveData.pitchControl = MoveRotControl.Angle
				elseif (key.eventFields.pitchUsesSplineTangent) then
					moveData.pitchControl = MoveRotControl.Tangent
				else
					moveData.pitchControl = MoveRotControl.None
				end

				if (key.eventFields.rollUsesNodeTransform) then
					moveData.rollControl = MoveRotControl.Angle
				else
					moveData.rollControl = MoveRotControl.None
				end
				
				for keyIndex,moveKey in ipairs(key.eventInstance.keys) do
					moveData.points[keyIndex].time = moveKey.time - baseTime
					moveData.points[keyIndex].speed = speed
					moveData.points[keyIndex].pos = moveKey.keyFields.position.position
					moveData.points[keyIndex].yaw = moveKey.keyFields.position.yaw
					moveData.points[keyIndex].pitch = moveKey.keyFields.position.pitch
					moveData.points[keyIndex].roll = moveKey.keyFields.position.roll
				end
				
				actor:Move(moveData)
			end
		end
	end,
	
	ScrubActorTo = function(property, actor, processedKeys, time)
		local processedKeyIndex = #processedKeys
		local lastStartedEvent
		local key
		while (not lastStartedEvent) and (processedKeyIndex > 0) do
			key = processedKeys[processedKeyIndex]
			if (key.keyIndex == 1) then
				lastStartedEvent = key.eventInstance
			else
				processedKeyIndex = processedKeyIndex - 1
			end
		end
		
		if (not lastStartedEvent) then
			actor:StopMovement()
			return
		end
		
		local numKeys = #lastStartedEvent.keys
		if (numKeys > 1) then
			property.ApplyToActor(property, actor, lastStartedEvent.keys[1], time)
		else
			actor:StopMovement()
		end
	end,
})

SceneTimelineAddProperty("Camera",
{
	priority = 50,
	frameDelay = 0, -- deafult frame delay is 1, cameras take effect on the next frame
	meta = 
	{
		description = "WARNING - DOF creates visual artifacts!\nCheck with your lead before adjusting DOF settings",
	},
	keyFields = 
	{
		{
			name = "cameraModeID",
			type = TimelineDataType.Record,
			default = 772,
			meta = 
			{
				table = "CameraMode",
				fieldGroupBox = "Camera Settings",
				tableWrapperType = "cmid",
			}
		},
		{
			name = "position",
			type = TimelineDataType.Actor,
			default = "",
			meta = 
			{
				fieldGroupBox = "Camera Settings",
			}
		},
		{
			name = "target",
			type = TimelineDataType.Actor,
			default = "",
			meta = 
			{
				fieldGroupBox = "Camera Settings",
			}
		},
		{
			name = "FOV",
			type = TimelineDataType.Float,
			default = 90.0,
			meta = 
			{
				fieldGroupBox = "Camera Settings",
			}
		},
		{
			name = "farBlurAmount",
			type = TimelineDataType.Float,
			default = 0.0,
			meta = 
			{
				fieldGroupBox = "Depth of Field (DOF)",
				sliderField = true,
				sliderFieldMin = 0.0,
				sliderFieldMax = 1.0,
			},
		},
		{
			name = "focalDepthFar",
			type = TimelineDataType.Float,
			default = 0.0,
			meta = 
			{
				fieldGroupBox = "Depth of Field (DOF)",
			},
		},
		{
			name = "focalLength",
			type = TimelineDataType.Float,
			default = 0.0,
			meta = 
			{
				fieldGroupBox = "Depth of Field (DOF)",
			},
		},
		{
			name = "grayscaleAlpha",
			type = TimelineDataType.Float,
			default = 0.0,
			meta = 
			{
				fieldGroupBox = "Depth of Field (DOF)",
				sliderField = true,
				sliderFieldMin = 0.0,
				sliderFieldMax = 1.0,
			},
		},
		{
			name = "blendTime",
			type = TimelineDataType.Float,
			default = 0.0,
			meta = 
			{
				duration = true,
			}
		},
		{
			name = "shotNumber",
			type = TimelineDataType.Integer,
			default = 1010,
			meta = 
			{
				displayText = true,
			}
		},
	},

	ApplyToActor = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return 
		end

		local cameraModeID = key.keyFields.cameraModeID
		local positionActor = SceneTimelineGetActor(actor, key.keyFields.position)

		if (cameraModeID > 0) and (positionActor) then
			local targetActor = SceneTimelineGetActor(actor, key.keyFields.target)
			local cameraData = { }
			cameraData.cameraModeID = cameraModeID
			cameraData.transitionTime = key.keyFields.blendTime
			cameraData.transitionInitialTime = time - key.time
			cameraData.fov = key.keyFields.FOV

			cameraData.focalDepthFar = key.keyFields.focalDepthFar
			cameraData.focalLength = key.keyFields.focalLength

			cameraData.farBlurAmount = math.min(math.max(key.keyFields.farBlurAmount, 0), 1)
			cameraData.grayscaleAlpha = math.min(math.max(key.keyFields.grayscaleAlpha, 0), 1)

			scene:SetCameraEx(cameraData, positionActor, targetActor)
		else
			scene:SetCamera(0, key.keyFields.blendTime, nil, nil)
		end

		scene:SetDebugCinematicShotNumber(key.keyFields.shotNumber, key.time)
	end,

	ScrubActorTo = function(property, actor, processedKeys, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return 
		end

		-- brute force the camera system
		-- we have to loop through them and not just set the
		-- more recent one because of camera transitions
		scene:SetCamera(0, 0, nil, nil)
		for index,key in ipairs(processedKeys) do
			property.ApplyToActor(property, actor, key, time)
		end
	
		scene:SetDebugCinematicCurrentTime(time)
	end,
})

SceneTimelineAddProperty("GameCameraTarget",
{
	keyFields =
	{
		{
			name = "target",
			type = TimelineDataType.Actor,
			default = "",
		},
		{
			name = "minZoom",
			type = TimelineDataType.Float,
			default = 0.0,
		},		
		{
			name = "maxZoom",
			type = TimelineDataType.Float,
			default = 0.0,
		},		

	},
	
	ApplyToActor = function(property, actor, key)
		local targetActor = SceneTimelineGetActor(actor, key.keyFields.target)
		scene:SetGameCameraTarget(targetActor, key.keyFields.minZoom, key.keyFields.maxZoom)
	end,
	
	ScrubActorTo = function(prop, actor, processedKeys, time)
		-- event: no-op 
	end,	
})


SceneTimelineAddStatePropertyEvent("CameraEffect",
{
	handlePauseForScrubActorTo = true,

	eventFields = 
	{
		{
			name = "cameraEffectID",
			type = TimelineDataType.Record,
			default = 779,
			meta = 
			{
				table = "cameraEffectID",
				tableWrapperType = "ceid",
			}
		},
		{
			name = "amplitudeScale",
			type = TimelineDataType.Float,
			default = 1.0,
			meta = 
			{
				table = "amplitudeScale",
			}
		},
		{
			name = "target",
			type = TimelineDataType.Actor,
			default = "",
		},		
	},


	GetUniqueID = function(key)
		return key.eventFields.cameraEffectID
	end,

	ApplyState = function(property, actor, key, time)
		local cameraEffectID = key.eventFields.cameraEffectID
		local amplitudeScale = key.eventFields.amplitudeScale
		local targetActor = SceneTimelineGetActor(actor, key.eventFields.target)

		if (not targetActor) then
			return
		end

		if (not actor.timelineCameraEffects) then
			actor.timelineCameraEffects = { }
		end

		actor.timelineCameraEffects[cameraEffectID] = scene:AddCameraEffect(cameraEffectID, targetActor:GetPosition(), targetActor, amplitudeScale)
	end,
	
	RemoveState = function(property, actor, key, time)
		local cameraEffectID = key.eventFields.cameraEffectID
		if (not actor.timelineCameraEffects) then
			return
		end

		local instance = actor.timelineCameraEffects[cameraEffectID]
		if (instance) then
			scene:RemoveCameraEffect(instance)
			actor.timelineCameraEffects[cameraEffectID] = nil
		end
	end,
})
SceneTimelineAddProperty("PreloadMovie",
{
	keyFields = 
	{
		{
			name = "movieID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "Movie",
				tableWrapperType = "mid",
			}
		},
	},
	
	SetStateCreateData = function(property, createData, key)
		-- do some sort of 
		-- preload movie for run
		
	end,
	
	ApplyToActor = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end
		scene:PreloadMovie(key.keyFields.movieID)
	end,
	
	ScrubActorTo = function(prop, actor, processedKeys, time)
		-- event: no-op 
	end,	
})

SceneTimelineAddProperty("Movie",
{
	keyFields = 
	{
		{
			name = "movieID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "Movie",
				tableWrapperType = "mid",
			}
		},
	},
	
	SetStateCreateData = function(property, createData, key)
		-- do some sort of 
		-- preload movie for run
		
	end,
	
	ApplyToActor = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		scene:PlayMovie(key.keyFields.movieID)

	end,
	
	ScrubActorTo = function(prop, actor, processedKeys, time)
		-- event: no-op 
	end,	
})

SceneTimelineAddProperty("RenderMovieLayer",
{
	keyFields = 
	{
		{
			name = "enable",
			type = TimelineDataType.Boolean,
			default = true,
		},
	},
	
	ApplyToActor = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		scene:EnableRenderMovieLayer(key.keyFields.enable)

	end,
	
	ScrubActorTo = function(prop, actor, processedKeys, time)
		-- event: no-op 
	end,	
})

SceneTimelineAddProperty("Broadcast Text",
{
	keyFields = 
	{
		{
			name = "broadcastTextID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "BroadcastText",
				tableWrapperType = "btid",
			}
		},
		{
			name = "target",
			type = TimelineDataType.Actor,
			default = "",
		},
		{
			name = "type",
			type = TimelineDataType.Integer,
			default = 0,
		},
		{
			name = "stereoAudio",
			type = TimelineDataType.Boolean,
			default = false,
		},		
	},
	
	ApplyToActor = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		local targetActor = SceneTimelineGetActor(actor, key.keyFields.target)
		local useActor = targetActor and targetActor or actor

		if (key.keyFields.stereoAudio) then
			useActor:BroadcastTextStereo(key.keyFields.type, key.keyFields.broadcastTextID)
		else
			useActor:BroadcastText(key.keyFields.type, key.keyFields.broadcastTextID)
		end
	end,
	
	ScrubActorTo = function(prop, actor, processedKeys, time)
		-- event: no-op 
	end,	
})

SceneTimelineAddProperty("SoundKit",
{
	minEventKeys = 2,

	eventFields = 
	{
		{
			name = "soundKitID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "SoundKit",
				tableWrapperType = "skid",
			}
		},
		{
			name = "stereoAudio",
			type = TimelineDataType.Boolean,
			default = false,
		},		
		{
			name = "looping",
			type = TimelineDataType.Boolean,
			default = false,
			meta = 
			{
				isLooping = true,
			}
		},
		{
			name = "sourceActor", -- default self
			type = TimelineDataType.Actor,
			default = "",
		},
	},

	ApplyToActor = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		local startKey = key.eventInstance.keys[1]
		if (not startKey) then
			return
		end
		
		local endKey = key.eventInstance.keys[2]
		local duration = 0
		if (endKey) then
			duration = endKey.time - startKey.time
		end
		
		if (duration < 0.001) then
			if (key.eventFields.looping) then
				return
			else
				-- fire and forget
				if (key.keyIndex ~= 1) then
					return
				end
			end
		end
		
		if (not actor.timelineSoundKits) then
			actor.timelineSoundKits = { }
		end
		
		-- stop current kit with this eventID
		local prevHandle = actor.timelineSoundKits[key.eventID]
		if (prevHandle) then
			prevHandle:Stop()
			actor.timelineSoundKits[key.eventID] = nil
		end
		
		if (key.keyIndex ~= 1) then
			return
		end
						
		local soundSrcActor = SceneTimelineGetActor(actor, key.eventFields.sourceActor)
		if (not soundSrcActor) then
			soundSrcActor = actor
		end
		
		local playOnce = true
		if (key.eventFields.looping) then
			playOnce = false
		end
		
		local nextHandle
		if (key.eventFields.stereoAudio) then
			nextHandle = soundSrcActor:PlaySoundKitStereo(key.eventFields.soundKitID, playOnce)
		else
			nextHandle = soundSrcActor:PlaySoundKit(key.eventFields.soundKitID, playOnce)
		end		
		
		actor.timelineSoundKits[key.eventID] = nextHandle		
	end,
	
	ScrubActorTo = function(prop, actor, processedKeys, time)
		-- silence all sounds
		if not actor.timelineSoundKits then
			return
		end
		
		for _,soundKitHandle in pairs(actor.timelineSoundKits) do
			soundKitHandle:Stop()
		end
		actor.timelineSoundKits = { }
	end,
})

-- deprecated
SceneTimelineAddProperty("SoundKit - One Shot",
{
	keyFields = 
	{
		{
			name = "soundKitID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "SoundKit",
				tableWrapperType = "skid",
			}
		},
		{
			name = "stereoAudio",
			type = TimelineDataType.Boolean,
			default = false,
		},		
	},
	
	ApplyToActor = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		if (key.keyFields.stereoAudio) then
			actor:PlaySoundKitStereo(key.keyFields.soundKitID, true)
		else
			actor:PlaySoundKit(key.keyFields.soundKitID, true)
		end
	end,
	
	ScrubActorTo = function(prop, actor, processedKeys, time)
		-- event: no-op 
	end,	
})

SceneTimelineAddStatePropertyOneShot("Music",
{
	keyFields = 
	{
		{
			name = "soundKitID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "SoundKit",
				tableWrapperType = "skid",
			}
		},	
	},
	
	SetStateActor = function(property, actor, key, time)
		-- similar to Camera, we should probably consider if two
		-- competing actors try and control this property
		local soundKitID = key.keyFields.soundKitID or 0
		if (not actor.musicSoundKitID) or (actor.musicSoundKitID ~= soundKitID) then
			actor.musicSoundKitID = soundKitID
			actor:PlayMusic(soundKitID)
		end
	end,
})

SceneTimelineAddStatePropertyOneShot("FadeRegion",
{
	keyFields = 
	{
		{
			name = "enabled",
			type = TimelineDataType.Boolean,
			default = true,
		},
		{
			name = "radius",
			type = TimelineDataType.Float,
			default = 0,
		},
		{
			name = "includePlayer",
			type = TimelineDataType.Boolean,
			default = true,
		},
		{
			name = "excludePlayers",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "excludeNonPlayers",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "includeSounds",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "includeWMOs",
			type = TimelineDataType.Boolean,
			default = false,
		},
	},

	SetStateCreateData = function(property, createData, key)
		if key.keyFields.radius > 0 then
			createData.fadeRegionSettings.radius = key.keyFields.radius
			createData.fadeRegionSettings.includePlayer = key.keyFields.includePlayer
			createData.fadeRegionSettings.excludePlayers = key.keyFields.excludePlayers
			createData.fadeRegionSettings.excludeNonPlayers = key.keyFields.excludeNonPlayers
			createData.fadeRegionSettings.includeSounds = key.keyFields.includeSounds
			createData.fadeRegionSettings.includeWMOs = key.keyFields.includeWMOs
			createData.fadeRegionSettings.active = key.keyFields.enabled
		end
	end,

	SetStateActor = function(property, actor, key, time)
		if key.keyFields.radius > 0 and key.keyFields.enabled then
			settings = 
			{ 
				radius=key.keyFields.radius, 
				includePlayer=key.keyFields.includePlayer,
				excludePlayers=key.keyFields.excludePlayers,
				excludeNonPlayers=key.keyFields.excludeNonPlayers,
				includeSounds=key.keyFields.includeSounds,
				includeWMOs=key.keyFields.includeWMOs,
				active=true,
			}
			actor:SetFadeRegion(settings)
		else
			actor:RemoveFadeRegion()
		end
	end,
})

SceneTimelineAddStatePropertyOneShot("EquipWeapon",
{
	keyFields = 
	{
		{
			name = "itemID",
			type = TimelineDataType.Record,
			default = 0,
			meta = 
			{
				table = "Item",
				tableWrapperType = "iid",
			}	
		},
		{
			name = "MainHand", 
			type = TimelineDataType.Boolean,
			default = true,
		},
		{
			name = "OffHand", 
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "Ranged", 
			type = TimelineDataType.Boolean,
			default = false,
		},

	},

	SetStateActor = function(property, actor, key)
		local itemID = key.keyFields.itemID

		if (key.keyFields.MainHand) then
			actor:EquipWeapon(WeaponSlot.MainHand, itemID)
		end

		if (key.keyFields.OffHand) then
			actor:EquipWeapon(WeaponSlot.OffHand, itemID)
		end		

		if (key.keyFields.Ranged) then
			actor:EquipWeapon(WeaponSlot.Ranged, itemID)
		end		
	end,
})

SceneTimelineAddStatePropertyOneShot("Sheathe",
{
	keyFields =
	{
		{
			name = "isSheathed",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "isRanged",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "animated",
			type = TimelineDataType.Boolean,
			default = false,
		},
	},

	SetStateActor = function(property, actor, key, time, isScrub)
		local instant = true
		if (key.keyFields.animated) and (not isScrub) then
			instant = false
		end

		if (key.keyFields.isSheathed) then
			actor:SetSheatheState(SheatheState.Sheathed, instant)
		elseif (key.keyFields.isRanged) then
			actor:SetSheatheState(SheatheState.ShowRanged, instant)
		else
			actor:SetSheatheState(SheatheState.ShowWeapon, instant)
		end
	end,
})

SceneTimelineAddStatePropertyOneShot("Interactible",
{
	keyFields =
	{
		{
			name = "interactible",
			type = TimelineDataType.Boolean,
			default = true,
		},
	},

	SetStateCreateData = function(property, createData, key)
		createData.interactible = key.keyFields.interactible
	end,

	SetStateActor = function(property, actor, key)
		actor:SetInteractible(key.keyFields.interactible)
	end,
})

SceneTimelineAddStatePropertyOneShot("Selectable",
{
	keyFields =
	{
		{
			name = "selectable",
			type = TimelineDataType.Boolean,
			default = true,
		},
	},

	SetStateCreateData = function(property, createData, key)
		createData.selectable = key.keyFields.selectable
	end,

	SetStateActor = function(property, actor, key)
		actor:SetSelectable(key.keyFields.selectable)
	end,
})

SceneTimelineAddStatePropertyOneShot("OverrideLinkage",
{	
	meta = 
	{
		description = "Used to tie model visibility to interior / exterior areas",
	},
	keyFields =
	{
		{
			name = "overrideLinkage",
			type = TimelineDataType.Integer,
			default = 0,
		},
	},

	SetStateCreateData = function(property, createData, key)
		createData.overrideLinkage = key.keyFields.overrideLinkage
	end,

	SetStateActor = function(property, actor, key)
		actor:SetOverrideLinkage(key.keyFields.overrideLinkage)
	end,
})

SceneTimelineAddStatePropertyOneShot("OverrideReaction",
{
	keyFields =
	{
		{
			name = "overrideReaction",
			type = TimelineDataType.Integer,
			default = 0,
		},
	},

	SetStateCreateData = function(property, createData, key)
		createData.overrideReaction = key.keyFields.overrideReaction
	end,

	SetStateActor = function(property, actor, key)
		actor:SetOverrideReaction(key.keyFields.overrideReaction)
	end,
})

SceneTimelineAddStatePropertyOneShot("SetHealth",
{
	keyFields =
	{
		{
			name = "health",
			type = TimelineDataType.Integer,
			default = 100,
			meta = 
			{
				sliderField = true,
				sliderFieldMin = 0,
				sliderFieldMax = 100,
				percentDisplay = true;
			},
		},
	},

	SetStateActor = function(property, actor, key)
		local maxHealth = actor:GetMaxHealth()
		local percHealth = key.keyFields.health / 100
		actor:SetHealth(percHealth * maxHealth)
	end,
})

SceneTimelineAddStatePropertyOneShot("AttachToActor",
{
	priority = 100,

	keyFields =
	{
		{
			name = "parent",
			type = TimelineDataType.Actor,
			default = "",
		},
		{
			name = "parentAttachment",
			type = TimelineDataType.Integer,
			default = -1,
		},
		{
			name = "useChildAttachOrientation",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "childAttachment",
			type = TimelineDataType.Integer,
			default = -1,
		},
		{
			name = "useTargetOffset",
			type = TimelineDataType.Boolean,
			default = false,
		},
		{
			name = "targetOffset",
			type = TimelineDataType.Transform,
			default = { position={x=0, y=0, z=0}, yaw=0, pitch=0, roll=0 },
		},
		{
			name = "transitionTime",
			type = TimelineDataType.Float,
			default = 0.0,
			meta = 
			{
				duration = true,
			}
		},	
		{
			name = "respectGroundSnap",
			type = TimelineDataType.Boolean,
			default = false,
		},
	},

	SetStateActor = function(property, actor, key, time, isScrub)
		local attachData = AttachmentData:Default();
		attachData.parentActor = SceneTimelineGetActor(actor, key.keyFields.parent)
		attachData.parentAttachment = key.keyFields.parentAttachment
		attachData.useChildAttachOrientation = key.keyFields.useChildAttachOrientation
		attachData.childAttachment = key.keyFields.childAttachment
		attachData.useTargetOffset = key.keyFields.useTargetOffset
		attachData.targetOffset = key.keyFields.targetOffset
		attachData.transitionTime = key.keyFields.transitionTime
		attachData.respectGroundSnap = key.keyFields.respectGroundSnap
		actor:SetAttachedTo(attachData)
	end,
})

SceneTimelineAddStatePropertyOneShot("Fade",
{
	keyFields =
	{
		{
			name = "alpha",
			type = TimelineDataType.Float,
			default = 1.0,
		},
		{
			name = "time",
			type = TimelineDataType.Float,
			default = 0.0,
			meta = 
			{
				duration = true,
			}
		},
	},

	SetStateActor = function(property, actor, key, time, isScrub)
		if (key.keyFields.alpha == 0.0) then
			actor:SetSelectable(false)
			actor:SetInteractible(false)
		end

		if (isScrub) then
			actor:Fade(key.keyFields.alpha, 0.0)
		else
			actor:Fade(key.keyFields.alpha, key.keyFields.time)
		end
	end,
})

local createCustomScriptFunc = [[
return function(...)
	%s
end
]]

SceneTimelineAddProperty("CustomScript", 
{
	keyFields =
	{
		{
			name = "script",
			type = TimelineDataType.String,
			default = "",
			meta = 
			{
				multiline = true,
			}
		},
	},

	ApplyToActor = function(property, actor, key)
		if (#key.keyFields.script <= 0) then
			return
		end

		-- follow pet battle model, create a function so we can set it in the right environment
		-- NOTE: Need Lua 5.1 at least for yielding from a coroutine from pcall, otherwise
		--       we could pcall the script in the coroutine and protect against errors
		local createString = string.format(createCustomScriptFunc, key.keyFields.script)
		local status, customFunc = pcall(loadstring(createString))
		if (status == true) then
			setfenv(customFunc, getfenv())
			scene:AddCoroutine(customFunc)
		else
			print("ERROR: CustomScript Load")
		end
	end,
	
	ScrubActorTo = function(prop, actor, processedKeys, time)
		-- event: no-op 
	end,
})

SceneTimelineAddStatePropertyOneShot("TriggerServerEvent",
{
	keyFields =
	{
		{
			name = "serverEvent",
			type = TimelineDataType.String,
			default = "",
			meta = 
			{
				displayText = true,
			}
		},
	},

	SetStateActor = function(property, actor, key)
		if not (scene:IsTimelineEditing()) then
			scene:TriggerServerEvent(key.keyFields.serverEvent)
		end
	end,
})

SceneTimelineAddStatePropertyEvent("ScreenEffect",
{
	eventFields = 
	{
		{
			name = "screenEffectID",
			type = TimelineDataType.Record,
			default = 1117,
			meta = 
			{
				table = "ScreenEffect",
				tableWrapperType = "seid",
			}
		}
	},

	GetUniqueID = function(key)
		return key.eventFields.screenEffectID
	end,

	ApplyState = function(property, actor, key, time)
		scene:ApplyScreenEffect(key.eventFields.screenEffectID)
	end,
	
	RemoveState = function(property, actor, key, time)
		scene:ClearScreenEffect(key.eventFields.screenEffectID)
	end,
})

SceneTimelineAddStatePropertyEvent("TextEffect",
{
	meta = 
	{
		description = "NOTE: Placeholder text will not be localized and is only meant for testing!",
	},
	eventFields = 
	{
		{
			name = "globalStringBaseTag",
			type = TimelineDataType.String,
			default = "",
			meta = 
			{
				table = "GlobalString",
			}
		},
		{
			name = "placeholderText",
			type = TimelineDataType.String,
			default = "TEST",
			meta = 
			{
				table = "PlaceholderText",
			}
		},		
		{
			name = "textAlignment",
			type = TimelineDataType.Integer,
			default = 1,
		},
		{
			name = "textScale",
			type = TimelineDataType.Float,
			default = 1,
		},		
		{
			name = "textStyle",
			type = TimelineDataType.Integer,
			default = 1,
		},		
	},

	GetUniqueID = function(key)
		return key.eventFields.globalStringBaseTag
	end,

	ApplyState = function(property, actor, key, time)
		if SceneTimelineIsActorVisibilityDisabled(actor.timelineInstance, actor.actorID) then
			return
		end

		local globalStringBaseTag = key.eventFields.globalStringBaseTag
		local placeholderText = key.eventFields.placeholderText
		local renderedText = ""
	
		if GetGlobalString(key.eventFields.globalStringBaseTag) ~= nil then 
			renderedText = GetGlobalString(key.eventFields.globalStringBaseTag)
		elseif placeholderText ~= "" then
			local placeholderSuffix = "(PH)"
			renderedText = placeholderText .. placeholderSuffix		
		end
		local textAlignment = key.eventFields.textAlignment
		local textScale = key.eventFields.textScale
		local textStyle = key.eventFields.textStyle
		
		if (not actor.timelineTextEffects) then
			actor.timelineTextEffects = { }
		end

		actor.timelineTextEffects[globalStringBaseTag] = actor:CreateTextEffect(renderedText, textStyle, textAlignment)
		actor:SetTextEffectScale(actor.timelineTextEffects[globalStringBaseTag], textScale)
	
	end,

	RemoveState = function(property, actor, key, time)
		local globalStringBaseTag = key.eventFields.globalStringBaseTag
		if (not actor.timelineTextEffects) then
			return
		end

		local instance = actor.timelineTextEffects[globalStringBaseTag]
		if (instance) then
			actor:ClearTextEffect(instance)
			actor.timelineTextEffects[globalStringBaseTag] = nil
		end
	end,
})

SceneTimelineAddStatePropertyOneShot("SetAnimTier",
{
	keyFields =
	{
		{
			name = "animTier",
			type = TimelineDataType.Integer,
			default = 1,
		},
	},

	SetStateActor = function(property, actor, key)
		actor:SetAnimTier(key.keyFields.animTier)
	end,
})

-- highest to lowest priority order
local animationTable =
{ 
	{ boneName="Jaw",			oneShotAnimKitID=19303, loopingAnimKitID=19304, boneSetID=AnimKitBoneSets.Jaw},
	{ boneName="Head",			oneShotAnimKitID=19301, loopingAnimKitID=19302, boneSetID=AnimKitBoneSets.Head},
	{ boneName="RightHand",		oneShotAnimKitID=19299, loopingAnimKitID=19300, boneSetID=AnimKitBoneSets.RightHand},
	{ boneName="LeftHand",		oneShotAnimKitID=19297, loopingAnimKitID=19298, boneSetID=AnimKitBoneSets.LeftHand},
	{ boneName="RightShoulder",	oneShotAnimKitID=19295, loopingAnimKitID=19296, boneSetID=AnimKitBoneSets.RightShoulder},
	{ boneName="LeftShoulder",	oneShotAnimKitID=19293, loopingAnimKitID=19294, boneSetID=AnimKitBoneSets.LeftShoulder},
	{ boneName="UpperBody",		oneShotAnimKitID=19291, loopingAnimKitID=19292, boneSetID=AnimKitBoneSets.UpperBody},
	{ boneName="FullBody",		oneShotAnimKitID=19284, loopingAnimKitID=19285, boneSetID=AnimKitBoneSets.FullBody},
	{ boneName="RightEye",			oneShotAnimKitID=21811, loopingAnimKitID=21810, boneSetID=AnimKitBoneSets.RightEye},
	{ boneName="LeftEye",			oneShotAnimKitID=21809, loopingAnimKitID=21808, boneSetID=AnimKitBoneSets.LeftEye},
	{ boneName="RightUpperEyelid",	oneShotAnimKitID=21819, loopingAnimKitID=21818, boneSetID=AnimKitBoneSets.RightUpperEyelid},
	{ boneName="LeftUpperEyelid",	oneShotAnimKitID=21813, loopingAnimKitID=21812, boneSetID=AnimKitBoneSets.LeftUpperEyelid},
	{ boneName="RightLowerEyelid",	oneShotAnimKitID=21817, loopingAnimKitID=21816, boneSetID=AnimKitBoneSets.RightLowerEyelid},
	{ boneName="LeftLowerEyelid",	oneShotAnimKitID=21815, loopingAnimKitID=21814, boneSetID=AnimKitBoneSets.LeftLowerEyelid},

	{ boneName="LeftArm",		oneShotAnimKitID=24844, loopingAnimKitID=24843, boneSetID=AnimKitBoneSets.LeftArm},
	{ boneName="RightArm",		oneShotAnimKitID=24846, loopingAnimKitID=24845, boneSetID=AnimKitBoneSets.RightArm},
	{ boneName="FaceHairIGC",	oneShotAnimKitID=24848, loopingAnimKitID=24847, boneSetID=AnimKitBoneSets.FaceHairIGC},
	{ boneName="FaceLowerIGC",	oneShotAnimKitID=24850, loopingAnimKitID=24849, boneSetID=AnimKitBoneSets.FaceLowerIGC},
	{ boneName="FaceUpperIGC",	oneShotAnimKitID=24852, loopingAnimKitID=24851, boneSetID=AnimKitBoneSets.FaceUpperIGC},
	{ boneName="FaceBeardIGC",	oneShotAnimKitID=24854, loopingAnimKitID=24853, boneSetID=AnimKitBoneSets.FaceBeardIGC},

	{ boneName="RightWing",	oneShotAnimKitID=24856, loopingAnimKitID=24855, boneSetID=AnimKitBoneSets.RightWing},
	{ boneName="LeftWing",	oneShotAnimKitID=24859, loopingAnimKitID=24858, boneSetID=AnimKitBoneSets.LeftWing},
}

for priority,animationData in ipairs(animationTable) do
	local name = "Animation_" .. animationData.boneName
	SceneTimelineAddStatePropertyEvent(name,
	{
		eventFields = 
		{
			{
				name = "animID",
				type = TimelineDataType.Record,
				default = -1,
				meta = 
				{
					table = "AnimationData",
					tableWrapperType = "adid",
				}
			},

			{
				name = "variation",
				type = TimelineDataType.Integer,
				default = 0,
			},

			{
				name = "looping",
				type = TimelineDataType.Boolean,
				default = false,
				meta = 
				{
					isLooping = true,
				}
			},

			{
				name = "speed",
				type = TimelineDataType.Float,
				default = 1.0,
				meta = 
				{
					playbackRate = true,
					fieldGroupBox = "Speed",
				}
			},

			{
				name = "randomSpeed",
				type = TimelineDataType.Boolean,
				default = false,
				meta =
				{
					fieldGroupRange = "randomSpeed",
					fieldGroupBox = "Speed",
				}
			},

			{
				name = "randomSpeedRangeStart",
				type = TimelineDataType.Float,
				default = 0.0,
				meta =
				{
					fieldGroupRange = "randomSpeed",
					fieldGroupBox = "Speed",
				}
			},

			{
				name = "randomSpeedRangeEnd",
				type = TimelineDataType.Float,
				default = 0.0,
				meta =
				{
					fieldGroupRange = "randomSpeed",
					fieldGroupBox = "Speed",
				}
			},

			{
				name = "startTime",
				type = TimelineDataType.Float,
				default = 0.0,
				meta =
				{
					fieldGroupBox = "StartTime",
				}
			},

			{
				name = "randomStartTime",
				type = TimelineDataType.Boolean,
				default = false,
				meta =
				{
					fieldGroupRange = "randomStart",
					fieldGroupBox = "StartTime",
				}
			},

			{
				name = "randomStartTimeRangeStart",
				type = TimelineDataType.Float,
				default = 0.0,
				meta =
				{
					fieldGroupRange = "randomStart",
					fieldGroupBox = "StartTime",
				}
			},

			{
				name = "randomStartTimeRangeEnd",
				type = TimelineDataType.Float,
				default = 0.0,
				meta =
				{
					fieldGroupRange = "randomStart",
					fieldGroupBox = "StartTime",
				}
			},

			{
				name = "blendIn",
				type = TimelineDataType.Float,
				default = 0.15,
			},
			
			{
				name = "blendOut",
				type = TimelineDataType.Float,
				default = 0.15,
			},
			{
				name = "blendWeight",
				type = TimelineDataType.Float,
				default = 1,
			},
		},

		GetUniqueID = function(key)
			if (key.eventFields.looping) then
				return "loop-" .. animationData.boneName .. "-" .. tostring(key.eventFields.animID)
			else
				return "oneshot-" .. animationData.boneName .. "-" .. tostring(key.eventFields.animID)
			end
		end,

		ApplyState = function(property, actor, key, time)
			if (not actor.timelineAnimationKitInstances) then
				actor.timelineAnimationKitInstances = { }
			end
			local id = property.GetUniqueID(key)

			local playData = AnimKitData:Default()
			if (key.eventFields.looping) then
				playData.animKitID = animationData.loopingAnimKitID
			else
				playData.animKitID = animationData.oneShotAnimKitID
			end

			playData.isMaintained = true
			playData.animOverride = key.eventFields.animID
			playData.boneSetIDOverride = animationData.boneSetID
			playData.variationOverride = key.eventFields.variation

			startTime = key.eventFields.startTime
			if (key.eventFields.randomStartTime) then
				startTime = math.random() * math.random(key.eventFields.randomStartTimeRangeStart, key.eventFields.randomStartTimeRangeEnd)
			end

			playData.startTimeOverrideMS = startTime * 1000 --milliseconds

			local newSpeed = key.eventFields.speed
			if (key.eventFields.randomSpeed) then
				newSpeed = math.random() * math.random(key.eventFields.randomSpeedRangeStart, key.eventFields.randomSpeedRangeEnd)
			end

			if (newSpeed ~= 1.0) then
				playData.speedOverrideType = AnimKitSpeedType.Set
				playData.speedOverrideValue = newSpeed
			end

			playData.blendOverrideType = AnimKitBlendType.Set
			playData.blendOverrideMS = key.eventFields.blendIn * 1000 --milliseconds
			playData.blendOutOverrideMS = key.eventFields.blendOut * 1000 --milliseconds
			playData.blendWeightOverride = key.eventFields.blendWeight

			actor.timelineAnimationKitInstances[id] = actor:PlayAnimKitEx(playData)
		end,
	
		RemoveState = function(property, actor, key, time)
			if (not actor.timelineAnimationKitInstances) then
				return
			end
			local id = property.GetUniqueID(key)
			local instance = actor.timelineAnimationKitInstances[id]
			if (instance) then
				actor.timelineAnimationKitInstances[id] = nil
				instance:Stop()
			end
		end,
	})
end


-- WoW.tools debug output: SceneScript name: Timeline Tables - RTC

cameraMode = {
	{
		label = "Target",
		value = 772,
	},	
	{
		label = "Target W/O Letterboxing",
		value = 522,
	},
	{
		label = "Target W/ Smoothing",
		value = 776,
	},
	{
		label = "Full Transform",
		value = 1168,
	},
	{
		label = "Full Transform W/O letterboxing",
		value = 1202,
	},
	{
		label = "Full Transform W/ Smoothing",
		value = 1186,
	},
}

ScreenEffectMode = {
	["FadeFromBlack"] 		= 1142,
	["FadeToBlack"] 		= 827,
	["FlashToBlack"] 		= 1361,
	["FlashToFromBlack"] 	= 1380,
	["FlashToWhite"] 		= 1151,
	["FadeToWhite"] 		= 1001,
	["FlashToFromWhite"] 	= 1381,
}

--WoW.tools debug output: End of package 3190



-- WoW.tools debug output: SceneScript name: 10.0_[TCM]_Documentation_IGC

--[[ 

	--= WORLDPORT =--
		worldport 2444, -3302.81, -3004.94, 1243.65, 199.57

	--= CONSOLE CHEAT =--
		10AzureTuskarrCookOff

	--= TO VIEW IN GAME =--
		1. Make a new Dragonflight character.
		2. Teleport to Big Kinook at Iskaara.
			worldport 2444, -4457.25, 4011.62, 0.436076, 76.903
		3. Run the event cheat
			10AzureTuskarrCookOff
		4. Play through the content.

	--= CONTACT =--
		- Quest Designer: 		Paul Kubit
		- T2 Producer: 			Gayeong Yoo
		- Cinematic Designer: 	Sherman Ohms

--]] 

-- WoW.tools debug output: SceneScript name: 10.0_[TCM]__Global_IGC

SceneTimelineAddFileData([[10.0_[TCM]__Global_IGC]], 
{
	["actors"] = 
	{
		["_Director"] = 
		{
			["properties"] = 
			{
				["ScreenEffect"] = 
				{
					["events"] = 
					{
						{["props"] = {screenEffectID=1139},
						 [0.000] = {},
						 [1.000] = {},},
						{["props"] = {screenEffectID=2084},
						 [10.500] = {},
						 [11.485] = {},},
						{["props"] = {screenEffectID=1923},
						 [14.800] = {},
						 [16.800] = {},},
					},
				},
				["Camera"] = 
				{
					["events"] = 
					{
						{[0.000] = {cameraModeID=772, position=[[10.0_[TCM]_Shot_1010_IGC\_Camera]], target=[[10.0_[TCM]_Shot_1010_IGC\_CameraTarget]], FOV=90.000, farBlurAmount=0.500, focalDepthFar=60.000, focalLength=0.000, grayscaleAlpha=0.000, blendTime=0.000, shotNumber=1010},},
						{[2.700] = {cameraModeID=772, position=[[10.0_[TCM]_Shot_1020_IGC\_Camera]], target=[[10.0_[TCM]_Shot_1020_IGC\_CameraTarget]], FOV=37.900, farBlurAmount=0.000, focalDepthFar=0.000, focalLength=0.000, grayscaleAlpha=0.000, blendTime=0.000, shotNumber=1020},},
						{[4.400] = {cameraModeID=772, position=[[10.0_[TCM]_Shot_1030_IGC\_Camera]], target=[[10.0_[TCM]_Shot_1030_IGC\_CameraTarget]], FOV=47.900, farBlurAmount=1.000, focalDepthFar=15.000, focalLength=0.000, grayscaleAlpha=0.000, blendTime=0.000, shotNumber=1030},},
						{[7.167] = {cameraModeID=772, position=[[10.0_[TCM]_Shot_1040_IGC\_Camera]], target=[[10.0_[TCM]_Shot_1040_IGC\_CameraTarget]], FOV=47.900, farBlurAmount=0.690, focalDepthFar=30.000, focalLength=0.000, grayscaleAlpha=0.000, blendTime=0.000, shotNumber=1040},},
						{[10.733] = {cameraModeID=772, position=[[10.0_[TCM]_Shot_1050_IGC\_Camera]], target=[[10.0_[TCM]_Shot_1050_IGC\_CameraTarget]], FOV=27.000, farBlurAmount=0.000, focalDepthFar=0.000, focalLength=0.000, grayscaleAlpha=0.000, blendTime=0.000, shotNumber=1050},},
						{[12.412] = {cameraModeID=797, position=[[10.0_[TCM]_Shot_1050_IGC\_Camera]], target=[[10.0_[TCM]_Shot_1050_IGC\_CameraTarget_B]], FOV=59.500, farBlurAmount=0.690, focalDepthFar=40.000, focalLength=0.000, grayscaleAlpha=0.000, blendTime=0.500, shotNumber=1050},},
					},
				},
				["End"] = 
				{
					["events"] = 
					{
						{[16.000] = {},},
					},
				},
			},
		},
		["_FadeRegion"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
						{[10.533] = {snap=true},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.605, y=4023.239, z=0.745}, yaw=127.322, pitch=0.000, roll=0.000}},},
					},
				},
				["CustomScript"] = 
				{
					["events"] = 
					{
						{[0.010] = {script=[[scene:AddFadeRegionExcludedGameObject(377379)]]},},
					},
				},
				["FadeRegion"] = 
				{
					["events"] = 
					{
						{[0.300] = {enabled=true, radius=5000.000, includePlayer=true, excludePlayers=false, excludeNonPlayers=false, includeSounds=false, includeWMOs=false},},
						{[15.200] = {enabled=false, radius=5000.000, includePlayer=true, excludePlayers=false, excludeNonPlayers=false, includeSounds=false, includeWMOs=false},},
					},
				},
			},
		},
		["c_Assistant"] = 
		{
			["properties"] = 
			{
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(186547), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=1.000, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4452.708, y=4017.795, z=0.206}, yaw=-148.925, pitch=0.000, roll=0.000}},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[10.733] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=52, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [10.533] = {},
						 [11.733] = {},},
						{["props"] = {animID=54, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [11.647] = {},
						 [12.514] = {},},
						{["props"] = {animID=125, variation=0, looping=true, speed=0.700, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [12.514] = {},
						 [16.000] = {},},
					},
				},
			},
		},
		["c_Player"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(167875), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=true, isPlayerCloneNative=true, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4456.142, y=4017.135, z=0.195}, yaw=93.008, pitch=0.000, roll=0.000}},},
						{[10.733] = {transform={position={x=-4455.643, y=4016.630, z=0.257}, yaw=-3.139, pitch=0.000, roll=-0.000}},},
					},
				},
				["Sheathe"] = 
				{
					["events"] = 
					{
						{[0.000] = {isSheathed=true, isRanged=false, animated=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=0, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [0.000] = {},
						 [13.294] = {},},
						{["props"] = {animID=80, variation=0, looping=false, speed=0.750, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [12.912] = {},
						 [16.176] = {},},
					},
				},
			},
		},
		["l_Cookpot_Omni"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(1083712), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=1.000, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4456.123, y=4021.444, z=4.455}, yaw=80.904, pitch=0.000, roll=0.000}},},
						{[4.400] = {transform={position={x=-4456.243, y=4022.811, z=4.701}, yaw=80.904, pitch=0.000, roll=0.000}},},
						{[7.167] = {transform={position={x=-4455.028, y=4022.318, z=3.765}, yaw=80.904, pitch=0.000, roll=0.000}},},
						{[10.733] = {transform={position={x=-4454.236, y=4023.397, z=4.229}, yaw=80.904, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.080, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
			},
		},
		["l_Cookpot_Omni_O"] = 
		{
			["properties"] = 
			{
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=3.000, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(1083712), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.184, y=4021.444, z=2.065}, yaw=80.904, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.100, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=2, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [0.000] = {},
						 [16.176] = {},},
					},
				},
			},
		},
		["l_Cookpot_Omni_Y"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=1.000, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(1083712), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4456.123, y=4021.444, z=4.455}, yaw=80.904, pitch=0.000, roll=0.000}},},
						{[4.400] = {transform={position={x=-4456.243, y=4022.811, z=4.701}, yaw=80.904, pitch=0.000, roll=0.000}},},
						{[7.167] = {transform={position={x=-4455.028, y=4022.318, z=3.765}, yaw=80.904, pitch=0.000, roll=0.000}},},
						{[10.733] = {transform={position={x=-4454.236, y=4023.397, z=4.229}, yaw=80.904, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.080, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=3, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [0.000] = {},
						 [16.176] = {},},
					},
				},
			},
		},
	},
})


-- WoW.tools debug output: SceneScript name: 10.0_[TCM]_Extras_IGC

SceneTimelineAddFileData([[10.0_[TCM]_Extras_IGC]], 
{
	["actors"] = 
	{
		["c_Kid_Nau"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(187679), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4448.550, y=4021.790, z=0.006}, yaw=-130.952, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=1.000, time=0.000},},
						{[4.400] = {alpha=0.000, time=0.000},},
						{[7.167] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
				["PlaySpellState"] = 
				{
					["events"] = 
					{
						{["props"] = {spellVisualID=120839, target=[[10.0_[TCM]_Extras_IGC\c_Kid_Nau]]},
						 [10.478] = {},
						 [18.190] = {},},
					},
				},
			},
		},
		["c_Kid_Neelo"] = 
		{
			["properties"] = 
			{
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4448.939, y=4023.065, z=0.006}, yaw=-146.104, pitch=0.000, roll=0.000}},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(187674), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=1.000, time=0.000},},
						{[4.400] = {alpha=0.000, time=0.000},},
						{[7.167] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
				["PlaySpellState"] = 
				{
					["events"] = 
					{
						{["props"] = {spellVisualID=120839, target=[[10.0_[TCM]_Extras_IGC\c_Kid_Nau]]},
						 [10.733] = {},
						 [18.190] = {},},
					},
				},
			},
		},
		["c_Kid_Pleeqi"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(196620), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4448.170, y=4023.680, z=0.181}, yaw=176.839, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=1.000, time=0.000},},
						{[4.400] = {alpha=0.000, time=0.000},},
						{[7.167] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
				["PlaySpellState"] = 
				{
					["events"] = 
					{
						{["props"] = {spellVisualID=120839, target=[[10.0_[TCM]_Extras_IGC\c_Kid_Nau]]},
						 [9.766] = {},
						 [18.190] = {},},
					},
				},
			},
		},
		["c_Kid_Scaps"] = 
		{
			["properties"] = 
			{
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(187680), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4448.673, y=4020.751, z=0.006}, yaw=-163.997, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=1.000, time=0.000},},
						{[4.400] = {alpha=0.000, time=0.000},},
						{[7.167] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=97, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [7.167] = {},
						 [18.190] = {},},
					},
				},
				["Animation_RightShoulder"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=580, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [10.261] = {},
						 [11.261] = {},},
						{["props"] = {animID=19, variation=0, looping=false, speed=1.500, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [11.040] = {},
						 [11.976] = {},},
						{["props"] = {animID=580, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [11.791] = {},
						 [13.012] = {},},
						{["props"] = {animID=19, variation=0, looping=true, speed=1.500, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [12.822] = {},
						 [14.261] = {},},
						{["props"] = {animID=580, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [14.100] = {},
						 [16.100] = {},},
						{["props"] = {animID=19, variation=0, looping=true, speed=1.500, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [15.900] = {},
						 [16.845] = {},},
						{["props"] = {animID=580, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [16.718] = {},
						 [17.718] = {},},
					},
				},
				["PlaySpellState"] = 
				{
					["events"] = 
					{
						{["props"] = {spellVisualID=121557, target=[[10.0_[TCM]_Extras_IGC\c_Kid_Scaps]]},
						 [10.261] = {},
						 [17.718] = {},},
					},
				},
				["Animation_UpperBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=0, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [10.261] = {},
						 [17.718] = {},},
					},
				},
				["Animation_RightArm"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=580, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [10.261] = {},
						 [11.261] = {},},
						{["props"] = {animID=225, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [11.040] = {},
						 [11.976] = {},},
						{["props"] = {animID=580, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [11.791] = {},
						 [13.012] = {},},
						{["props"] = {animID=225, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [12.822] = {},
						 [14.261] = {},},
						{["props"] = {animID=580, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [14.100] = {},
						 [16.100] = {},},
						{["props"] = {animID=225, variation=0, looping=false, speed=0.500, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [15.900] = {},
						 [16.845] = {},},
						{["props"] = {animID=580, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [16.718] = {},
						 [17.718] = {},},
					},
				},
				["Animation_Jaw"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=60, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [10.261] = {},
						 [17.718] = {},},
					},
				},
				["Animation_LeftShoulder"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=97, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.500, blendOut=0.500, blendWeight=0.750},
						 [10.261] = {},
						 [17.718] = {},},
					},
				},
				["Animation_RightHand"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=580, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [10.261] = {},
						 [17.718] = {},},
					},
				},
			},
		},
		["d_Bowl_LilKi"] = 
		{
			["properties"] = 
			{
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.700, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(199397), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4453.781, y=4017.214, z=0.807}, yaw=105.686, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[10.733] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
			},
		},
		["d_Bowl_Scaps"] = 
		{
			["properties"] = 
			{
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4448.908, y=4020.640, z=0.006}, yaw=-163.997, pitch=0.000, roll=0.000}},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.500, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(199397), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[10.733] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
			},
		},
		["d_Fork"] = 
		{
			["properties"] = 
			{
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=1.000, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(960870), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.167, y=4017.499, z=0.823}, yaw=-131.532, pitch=0.000, roll=0.000}},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[10.733] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
			},
		},
		["d_IceChunk"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(4545617), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.907, y=4022.771, z=-0.463}, yaw=148.940, pitch=-10.209, roll=-173.907}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=1.000, time=0.000},},
						{[2.700] = {alpha=0.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
			},
		},
		["d_Spoon"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=1.000, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4453.627, y=4016.528, z=0.823}, yaw=-170.264, pitch=0.000, roll=0.000}},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(960882), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[10.733] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
			},
		},
		["d_Table"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.600, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4450.702, y=4019.872, z=-0.078}, yaw=84.375, pitch=0.000, roll=0.000}},},
						{[2.700] = {transform={position={x=-4450.933, y=4019.244, z=-0.078}, yaw=69.504, pitch=0.000, roll=0.000}},},
						{[3.700] = {transform={position={x=-4451.150, y=4018.667, z=-0.078}, yaw=69.504, pitch=0.000, roll=0.000}},},
						{[10.733] = {transform={position={x=-4453.771, y=4017.151, z=0.095}, yaw=24.727, pitch=0.000, roll=0.000}},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(3857163), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[10.733] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
				["MoveSpline"] = 
				{
					["events"] = 
					{
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [0.500] = {position={position={x=-4450.702, y=4019.872, z=-0.078}, yaw=84.375, pitch=0.000, roll=0.000}},
						 [2.700] = {position={position={x=-4451.150, y=4018.667, z=-0.078}, yaw=69.504, pitch=0.000, roll=0.000}},},
					},
				},
			},
		},
		["fx_Bowl_Glow"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(615880), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.500, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4453.775, y=4017.184, z=0.739}, yaw=105.686, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[10.733] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=158, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [10.733] = {},
						 [15.000] = {},},
					},
				},
			},
		},
		["fx_Bowl_Halo"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(1611185), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.075, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4453.781, y=4017.214, z=0.805}, yaw=105.686, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[10.733] = {alpha=0.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=158, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [10.733] = {},
						 [15.000] = {},},
					},
				},
			},
		},
	},
})


-- WoW.tools debug output: SceneScript name: 10.0_[TCM]_FX_IGC

SceneTimelineAddFileData([[10.0_[TCM]_FX_IGC]], 
{
	["actors"] = 
	{
		["d_Bubbles_01"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.500, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(243926), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.498, y=4022.104, z=1.515}, yaw=0.000, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[2.000] = {alpha=1.000, time=0.000},},
					},
				},
			},
		},
		["d_Bubbles_02_Sm"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(243926), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.200, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.871, y=4020.923, z=1.515}, yaw=-151.449, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[3.450] = {alpha=1.000, time=0.000},},
					},
				},
			},
		},
		["d_Bubbles_03_Sm"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.200, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4453.854, y=4021.443, z=1.716}, yaw=-151.449, pitch=0.000, roll=0.000}},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(243926), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[3.450] = {alpha=1.000, time=0.000},},
					},
				},
			},
		},
		["d_Bubbles_04_Sm"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.200, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.563, y=4022.756, z=1.716}, yaw=-95.051, pitch=0.000, roll=0.000}},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(243926), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[3.450] = {alpha=1.000, time=0.000},},
					},
				},
			},
		},
		["d_Bubbles_05_Sm"] = 
		{
			["properties"] = 
			{
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.300, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(243926), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.559, y=4022.651, z=1.515}, yaw=-64.337, pitch=0.000, roll=-0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[3.450] = {alpha=1.000, time=0.000},},
					},
				},
			},
		},
		["d_Bubbles_06_Sm"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(243926), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.300, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4453.939, y=4020.550, z=1.716}, yaw=-64.337, pitch=0.000, roll=-0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[3.450] = {alpha=1.000, time=0.000},},
					},
				},
			},
		},
		["d_Bubbles_07_Sm"] = 
		{
			["properties"] = 
			{
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(243926), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.174, y=4020.321, z=1.515}, yaw=-95.051, pitch=0.000, roll=0.000}},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.200, duration=0.000},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[3.450] = {alpha=1.000, time=0.000},},
					},
				},
			},
		},
		["d_Bubbles_Boiling_A"] = 
		{
			["properties"] = 
			{
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.500, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(243926), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.498, y=4022.104, z=1.328}, yaw=0.000, pitch=0.000, roll=0.000}},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[7.470] = {alpha=1.000, time=0.000},},
					},
				},
				["AnimKit"] = 
				{
					["events"] = 
					{
						{["props"] = {animKitID=6096},
						 [7.157] = {},
						 [10.877] = {},},
					},
				},
				["MoveSpline"] = 
				{
					["events"] = 
					{
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [7.470] = {position={position={x=-4454.498, y=4022.104, z=1.328}, yaw=0.000, pitch=0.000, roll=0.000}},
						 [8.677] = {position={position={x=-4454.498, y=4022.225, z=1.804}, yaw=0.000, pitch=0.000, roll=0.000}},},
					},
				},
			},
		},
		["d_Bubbles_Boiling_B"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.500, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(243926), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.293, y=4022.104, z=1.328}, yaw=145.285, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[7.470] = {alpha=1.000, time=0.000},},
					},
				},
				["AnimKit"] = 
				{
					["events"] = 
					{
						{["props"] = {animKitID=6096},
						 [7.328] = {},
						 [10.877] = {},},
					},
				},
				["MoveSpline"] = 
				{
					["events"] = 
					{
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [7.470] = {position={position={x=-4455.293, y=4022.104, z=1.328}, yaw=145.285, pitch=0.000, roll=0.000}},
						 [8.677] = {position={position={x=-4455.293, y=4021.878, z=1.804}, yaw=145.285, pitch=0.000, roll=0.000}},},
					},
				},
			},
		},
		["d_Steam_01"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=1.000, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.869, y=4021.583, z=1.365}, yaw=0.000, pitch=0.000, roll=0.000}},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(2746888), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[3.450] = {alpha=1.000, time=1.000},},
					},
				},
			},
		},
		["d_Steam_02"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(2746888), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.500, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.573, y=4021.138, z=1.818}, yaw=180.000, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[4.606] = {alpha=1.000, time=1.000},},
					},
				},
			},
		},
		["d_Steam_Intense_01"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(2831314), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=1.000, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.869, y=4019.649, z=2.131}, yaw=0.000, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[7.167] = {alpha=1.000, time=1.000},},
						{[10.877] = {alpha=0.000, time=0.000},},
					},
				},
			},
		},
		["d_Steam_Sm_01"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.200, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.942, y=4021.547, z=1.818}, yaw=180.000, pitch=0.000, roll=0.000}},},
						{[4.400] = {transform={position={x=-4454.942, y=4024.659, z=1.818}, yaw=180.000, pitch=0.000, roll=0.000}},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(2746888), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[1.700] = {alpha=1.000, time=1.000},},
					},
				},
			},
		},
		["fx_SteamBlast_A"] = 
		{
			["properties"] = 
			{
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.891, y=4020.705, z=-1.186}, yaw=32.682, pitch=0.000, roll=0.000}},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(120271), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["PlaySpellState"] = 
				{
					["events"] = 
					{
						{["props"] = {spellVisualID=123964, target=""},
						 [9.733] = {},
						 [11.233] = {},},
					},
				},
			},
		},
		["fx_SteamBlast_B"] = 
		{
			["properties"] = 
			{
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.713, y=4020.705, z=-1.186}, yaw=32.682, pitch=0.000, roll=0.000}},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(120271), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["PlaySpellState"] = 
				{
					["events"] = 
					{
						{["props"] = {spellVisualID=123964, target=""},
						 [9.837] = {},
						 [11.337] = {},},
					},
				},
			},
		},
		["fx_SteamBlast_C"] = 
		{
			["properties"] = 
			{
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(120271), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4453.940, y=4019.865, z=-1.186}, yaw=32.682, pitch=0.000, roll=0.000}},},
					},
				},
				["PlaySpellState"] = 
				{
					["events"] = 
					{
						{["props"] = {spellVisualID=123964, target=""},
						 [9.904] = {},
						 [11.404] = {},},
					},
				},
			},
		},
		["fx_SteamBlast_D"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(120271), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.448, y=4020.140, z=-1.186}, yaw=32.682, pitch=0.000, roll=0.000}},},
					},
				},
				["PlaySpellState"] = 
				{
					["events"] = 
					{
						{["props"] = {spellVisualID=123964, target=""},
						 [9.904] = {},
						 [11.404] = {},},
					},
				},
			},
		},
		["fx_SteamBlast_E"] = 
		{
			["properties"] = 
			{
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.268] = {creatureID=cid(120271), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.268] = {transform={position={x=-4456.275, y=4019.998, z=-1.186}, yaw=32.682, pitch=0.000, roll=0.000}},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.268] = {snap=true},},
					},
				},
				["PlaySpellState"] = 
				{
					["events"] = 
					{
						{["props"] = {spellVisualID=123964, target=""},
						 [9.904] = {},
						 [11.404] = {},},
					},
				},
			},
		},
		["fx_SteamPoof"] = 
		{
			["properties"] = 
			{
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(120271), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
						{[9.733] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(4550068), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
						{[10.733] = {creatureID=cid(120271), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.891, y=4022.528, z=2.651}, yaw=32.682, pitch=0.000, roll=0.000}},},
					},
				},
			},
		},
	},
})


-- WoW.tools debug output: SceneScript name: 10.0_[TCM]_Set_IGC

SceneTimelineAddFileData([[10.0_[TCM]_Set_IGC]], 
{
	["actors"] = 
	{
		["d_Cookpot"] = 
		{
			["properties"] = 
			{
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.750, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(4616653), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=true},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.918, y=4021.737, z=-0.157}, yaw=173.242, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
			},
		},
		["d_Stool"] = 
		{
			["properties"] = 
			{
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=2.000, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.100, y=4025.500, z=0.104}, yaw=-65.000, pitch=0.000, roll=-0.000}},},
						{[0.200] = {transform={position={x=-4455.342, y=4024.910, z=-0.064}, yaw=-85.181, pitch=0.000, roll=-0.000}},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(953802), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
			},
		},
	},
})


-- WoW.tools debug output: SceneScript name: 10.0_[TCM]_Shot_1010_IGC

SceneTimelineAddFileData([[10.0_[TCM]_Shot_1010_IGC]], 
{
	["actors"] = 
	{
		["_Camera"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4461.197, y=4013.276, z=5.064}, yaw=52.705, pitch=-17.225, roll=-0.000}},},
					},
				},
				["MoveSpline"] = 
				{
					["events"] = 
					{
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [1.000] = {position={position={x=-4461.197, y=4013.276, z=5.064}, yaw=52.705, pitch=-17.225, roll=-0.000}},
						 [2.800] = {position={position={x=-4460.976, y=4013.567, z=4.951}, yaw=52.705, pitch=-17.224, roll=0.000}},},
					},
				},
			},
		},
		["_CameraTarget"] = 
		{
			["properties"] = 
			{
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4441.546, y=4036.653, z=-4.046}, yaw=63.809, pitch=0.000, roll=0.000}},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
			},
		},
		["c_Assistant"] = 
		{
			["properties"] = 
			{
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=1.000, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(186547), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.755, y=4014.493, z=0.086}, yaw=-136.676, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[0.500] = {alpha=1.000, time=0.000},},
						{[4.609] = {alpha=0.000, time=0.000},},
					},
				},
				["Animation_UpperBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=29, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [0.347] = {},
						 [2.167] = {},},
					},
				},
				["MoveSpline"] = 
				{
					["events"] = 
					{
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [0.347] = {position={position={x=-4454.755, y=4014.493, z=0.086}, yaw=-136.676, pitch=0.000, roll=0.000}},
						 [2.167] = {position={position={x=-4454.750, y=4014.918, z=0.282}, yaw=-166.673, pitch=0.000, roll=0.000}},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=0, variation=0, looping=true, speed=0.500, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.330, blendOut=0.330, blendWeight=1.000},
						 [2.167] = {},
						 [4.609] = {},},
					},
				},
			},
		},
		["c_BigKinook"] = 
		{
			["properties"] = 
			{
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(4569793), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.150, y=4025.540, z=1.015}, yaw=-93.075, pitch=0.000, roll=0.000}},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["AnimKit"] = 
				{
					["events"] = 
					{
						{["props"] = {animKitID=23219},
						 [0.000] = {},
						 [1.000] = {},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=1.000, time=0.000},},
						{[2.700] = {alpha=0.000, time=0.000},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=1452, variation=0, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.000, blendOut=0.000, blendWeight=1.000},
						 [1.000] = {},
						 [2.700] = {},},
					},
				},
			},
		},
		["d_Table"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=true},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.600, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(3857163), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.695, y=4016.393, z=-0.078}, yaw=-154.334, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=1.000, time=0.000},},
						{[4.609] = {alpha=0.000, time=0.000},},
					},
				},
				["FacingTarget"] = 
				{
					["events"] = 
					{
						{[0.100] = {target=[[10.0_[TCM]_Shot_1010_IGC\n_FacingBunny_Table]], offset={x=0.000, y=0.000, z=0.000}, FacingTurnRate=16.000},},
					},
				},
				["MoveSpline"] = 
				{
					["events"] = 
					{
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [0.347] = {position={position={x=-4454.695, y=4016.393, z=-0.078}, yaw=35.666, pitch=0.000, roll=0.000}},
						 [2.167] = {position={position={x=-4454.654, y=4016.914, z=0.011}, yaw=-172.385, pitch=0.000, roll=0.000}},},
					},
				},
			},
		},
		["n_FacingBunny_Table"] = 
		{
			["properties"] = 
			{
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(120271), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4479.032, y=4017.289, z=4.096}, yaw=9.943, pitch=0.000, roll=0.000}},},
					},
				},
			},
		},
	},
})


-- WoW.tools debug output: SceneScript name: 10.0_[TCM]_Shot_1020_IGC

SceneTimelineAddFileData([[10.0_[TCM]_Shot_1020_IGC]], 
{
	["actors"] = 
	{
		["_Camera"] = 
		{
			["properties"] = 
			{
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4462.824, y=4020.972, z=18.463}, yaw=4.902, pitch=-65.360, roll=0.000}},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["MoveSpline"] = 
				{
					["events"] = 
					{
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [2.700] = {position={position={x=-4462.824, y=4020.972, z=18.463}, yaw=4.902, pitch=-65.360, roll=0.000}},
						 [4.400] = {position={position={x=-4462.486, y=4020.993, z=17.730}, yaw=4.902, pitch=-65.360, roll=0.000}},},
					},
				},
			},
		},
		["_CameraTarget"] = 
		{
			["properties"] = 
			{
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.329, y=4021.702, z=-0.129}, yaw=21.696, pitch=0.000, roll=0.000}},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
			},
		},
		["c_BigKinook"] = 
		{
			["properties"] = 
			{
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=1.000, duration=0.000},},
						{[0.200] = {scale=0.900, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(4569793), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.150, y=4025.540, z=1.015}, yaw=-93.075, pitch=0.000, roll=0.000}},},
						{[0.200] = {transform={position={x=-4455.135, y=4025.727, z=1.015}, yaw=-96.938, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[2.700] = {alpha=1.000, time=0.000},},
						{[4.400] = {alpha=0.000, time=0.000},},
					},
				},
				["AnimKit"] = 
				{
					["events"] = 
					{
						{["props"] = {animKitID=23220},
						 [1.700] = {},
						 [2.700] = {},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=1452, variation=1, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.000, blendOut=0.000, blendWeight=1.000},
						 [2.700] = {},
						 [4.400] = {},},
					},
				},
			},
		},
	},
})


-- WoW.tools debug output: SceneScript name: 10.0_[TCM]_Shot_1030_IGC

SceneTimelineAddFileData([[10.0_[TCM]_Shot_1030_IGC]], 
{
	["actors"] = 
	{
		["_Camera"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4459.338, y=4023.844, z=3.849}, yaw=7.916, pitch=4.878, roll=0.000}},},
					},
				},
				["MoveSpline"] = 
				{
					["events"] = 
					{
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [4.400] = {position={position={x=-4459.338, y=4023.844, z=3.849}, yaw=7.937, pitch=-0.235, roll=0.000}},
						 [7.167] = {position={position={x=-4458.877, y=4023.907, z=3.847}, yaw=7.937, pitch=-0.235, roll=0.000}},},
					},
				},
			},
		},
		["_CameraTarget"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4427.932, y=4028.222, z=3.719}, yaw=7.916, pitch=4.878, roll=0.000}},},
					},
				},
				["MoveSpline"] = 
				{
					["events"] = 
					{
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [4.400] = {position={position={x=-4427.932, y=4028.222, z=3.719}, yaw=7.916, pitch=0.000, roll=0.000}},
						 [7.167] = {position={position={x=-4428.068, y=4029.179, z=3.719}, yaw=7.916, pitch=0.000, roll=0.000}},},
					},
				},
			},
		},
		["c_BigKinook"] = 
		{
			["properties"] = 
			{
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.900, duration=0.000},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(4569793), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.135, y=4025.727, z=1.015}, yaw=-96.938, pitch=0.000, roll=0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[4.400] = {alpha=1.000, time=0.000},},
						{[7.167] = {alpha=0.000, time=0.000},},
					},
				},
				["AnimKit"] = 
				{
					["events"] = 
					{
						{["props"] = {animKitID=23221},
						 [3.400] = {},
						 [4.400] = {},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=1452, variation=2, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.000, blendOut=0.000, blendWeight=1.000},
						 [4.400] = {},
						 [7.167] = {},},
					},
				},
			},
		},
	},
})


-- WoW.tools debug output: SceneScript name: 10.0_[TCM]_Shot_1040_IGC

SceneTimelineAddFileData([[10.0_[TCM]_Shot_1040_IGC]], 
{
	["actors"] = 
	{
		["_Camera"] = 
		{
			["properties"] = 
			{
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.110, y=4015.812, z=3.532}, yaw=88.902, pitch=-5.971, roll=0.000}},},
					},
				},
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["MoveSpline"] = 
				{
					["events"] = 
					{
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [7.167] = {position={position={x=-4455.110, y=4015.812, z=3.532}, yaw=88.909, pitch=-3.601, roll=0.000}},
						 [10.733] = {position={position={x=-4455.100, y=4016.575, z=3.484}, yaw=88.909, pitch=-3.601, roll=0.000}},},
					},
				},
			},
		},
		["_CameraTarget"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.715, y=4036.529, z=2.228}, yaw=176.923, pitch=0.000, roll=0.000}},},
					},
				},
				["MoveSpline"] = 
				{
					["events"] = 
					{
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [8.667] = {position={position={x=-4454.715, y=4036.529, z=2.228}, yaw=177.152, pitch=0.000, roll=0.000}},
						 [9.098] = {position={position={x=-4454.716, y=4036.529, z=3.786}, yaw=-26.565, pitch=0.000, roll=-0.000}},
						 [9.600] = {position={position={x=-4454.715, y=4036.528, z=2.535}, yaw=-26.565, pitch=0.000, roll=-0.000}},},
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [9.600] = {position={position={x=-4454.715, y=4036.528, z=2.535}, yaw=-43.608, pitch=0.000, roll=-0.000}},
						 [10.478] = {position={position={x=-4454.714, y=4036.528, z=5.486}, yaw=177.152, pitch=0.000, roll=0.000}},},
						{["props"] = {overrideSpeed=0.000, useModelRunSpeed=false, useModelWalkSpeed=false, yawUsesSplineTangent=true, yawUsesNodeTransform=false, yawBlendDisabled=false, pitchUsesSplineTangent=false, pitchUsesNodeTransform=false, rollUsesNodeTransform=false},
						 [10.478] = {position={position={x=-4454.714, y=4036.528, z=5.486}, yaw=177.152, pitch=0.000, roll=0.000}},
						 [10.733] = {position={position={x=-4454.714, y=4036.528, z=5.841}, yaw=177.152, pitch=0.000, roll=0.000}},},
					},
				},
			},
		},
		["c_BigKinook"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Scale"] = 
				{
					["events"] = 
					{
						{[0.000] = {scale=0.900, duration=0.000},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.150, y=4025.181, z=0.757}, yaw=-90.510, pitch=0.000, roll=0.000}},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(0), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(4569793), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[7.167] = {alpha=1.000, time=0.000},},
						{[8.667] = {alpha=1.000, time=0.000},},
						{[10.733] = {alpha=0.000, time=0.000},},
					},
				},
				["AnimKit"] = 
				{
					["events"] = 
					{
						{["props"] = {animKitID=23222},
						 [6.167] = {},
						 [7.167] = {},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=1452, variation=3, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.000, blendOut=0.000, blendWeight=1.000},
						 [7.167] = {},
						 [10.733] = {},},
					},
				},
			},
		},
	},
})


-- WoW.tools debug output: SceneScript name: 10.0_[TCM]_Shot_1050_IGC

SceneTimelineAddFileData([[10.0_[TCM]_Shot_1050_IGC]], 
{
	["actors"] = 
	{
		["_Camera"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4455.161, y=4010.760, z=1.831}, yaw=77.647, pitch=-3.254, roll=0.000}},},
					},
				},
			},
		},
		["_CameraTarget"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4453.556, y=4017.960, z=0.854}, yaw=77.247, pitch=0.000, roll=0.000}},},
					},
				},
			},
		},
		["_CameraTarget_B"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4453.556, y=4017.960, z=1.739}, yaw=77.247, pitch=0.000, roll=0.000}},},
					},
				},
			},
		},
		["c_Kinook"] = 
		{
			["properties"] = 
			{
				["GroundSnap"] = 
				{
					["events"] = 
					{
						{[0.000] = {snap=false},},
					},
				},
				["Appearance"] = 
				{
					["events"] = 
					{
						{[0.000] = {creatureID=cid(186126), creatureDisplaySetIndex=0, creatureDisplayInfoID=0, fileDataID=fid(0), wmoGameObjectDisplayID=gdi(0), itemID=iid(0), isPlayerClone=false, isPlayerCloneNative=false, playerSummon=false, playerGroupIndex=0, smoothPhase=false},},
					},
				},
				["Transform"] = 
				{
					["events"] = 
					{
						{[0.000] = {transform={position={x=-4454.191, y=4025.469, z=0.811}, yaw=-84.815, pitch=0.000, roll=-0.000}},},
					},
				},
				["Fade"] = 
				{
					["events"] = 
					{
						{[0.000] = {alpha=0.000, time=0.000},},
						{[10.733] = {alpha=1.000, time=0.000},},
						{[14.900] = {alpha=0.000, time=0.000},},
					},
				},
				["PlaySpellState"] = 
				{
					["events"] = 
					{
						{["props"] = {spellVisualID=114742, target=[[10.0_[TCM]_Shot_1050_IGC\c_Kinook]]},
						 [10.733] = {},
						 [16.043] = {},},
					},
				},
				["Animation_UpperBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=91, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [10.733] = {},
						 [12.329] = {},},
						{["props"] = {animID=0, variation=3, looping=false, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=0.600},
						 [11.874] = {},
						 [16.233] = {},},
					},
				},
				["Animation_FullBody"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=0, variation=0, looping=true, speed=1.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.000, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [10.733] = {},
						 [16.233] = {},},
					},
				},
				["Animation_RightShoulder"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=522, variation=0, looping=false, speed=0.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.600, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [12.329] = {},
						 [16.233] = {},},
					},
				},
				["Animation_LeftShoulder"] = 
				{
					["events"] = 
					{
						{["props"] = {animID=522, variation=0, looping=false, speed=0.000, randomSpeed=false, randomSpeedRangeStart=0.000, randomSpeedRangeEnd=0.000, startTime=0.600, randomStartTime=false, randomStartTimeRangeStart=0.000, randomStartTimeRangeEnd=0.000, blendIn=0.150, blendOut=0.150, blendWeight=1.000},
						 [12.329] = {},
						 [16.233] = {},},
					},
				},
			},
		},
	},
})


-- WoW.tools debug output: SceneScript name: 10.0_[TCM]_Sound_IGC

SceneTimelineAddFileData([[10.0_[TCM]_Sound_IGC]], 
{
	["actors"] = 
	{
		["Looping_"] = 
		{
			["properties"] = 
			{
				["SoundKit"] = 
				{
					["events"] = 
					{
						{["props"] = {soundKitID=216483, stereoAudio=true, looping=true, sourceActor=""},
						 [0.777] = {},
						 [15.811] = {},},
					},
				},
			},
		},
		["Looping_1"] = 
		{
			["properties"] = 
			{
				["SoundKit"] = 
				{
					["events"] = 
					{
						{["props"] = {soundKitID=216484, stereoAudio=true, looping=true, sourceActor=""},
						 [11.660] = {},
						 [15.811] = {},},
					},
				},
			},
		},
		["laugh_01"] = 
		{
			["properties"] = 
			{
				["SoundKit"] = 
				{
					["events"] = 
					{
						{["props"] = {soundKitID=216485, stereoAudio=true, looping=false, sourceActor=""},
						 [12.231] = {},
						 [13.231] = {},},
						{["props"] = {soundKitID=216485, stereoAudio=true, looping=false, sourceActor=""},
						 [14.518] = {},
						 [15.518] = {},},
					},
				},
			},
		},
		["laugh_02"] = 
		{
			["properties"] = 
			{
				["SoundKit"] = 
				{
					["events"] = 
					{
						{["props"] = {soundKitID=216485, stereoAudio=true, looping=false, sourceActor=""},
						 [13.316] = {},
						 [14.316] = {},},
						{["props"] = {soundKitID=216485, stereoAudio=true, looping=false, sourceActor=""},
						 [14.796] = {},
						 [15.796] = {},},
					},
				},
			},
		},
	},
})


-- WoW.tools debug output: SceneScript name: 10.0.0_[TCM]_Music_IGC

SceneTimelineAddFileData([[10.0.0_[TCM]_Music_IGC]], 
{
	["actors"] = 
	{
		["Music"] = 
		{
			["properties"] = 
			{
				["SoundKit"] = 
				{
					["events"] = 
					{
						{["props"] = {soundKitID=217870, stereoAudio=true, looping=false, sourceActor=""},
						 [0.101] = {},
						 [16.163] = {},},
					},
				},
			},
		},
	},
})
