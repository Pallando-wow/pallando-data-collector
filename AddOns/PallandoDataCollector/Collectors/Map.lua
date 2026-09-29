local _, ns = ...

local MAX_PARENT_DEPTH = 16

local function setFact(facts, key, value)
    if value ~= nil then
        facts[key] = value
    end
end

local function collectMapLevels(mapID, facts)
    if type(C_Map.GetMapLevels) ~= "function" then
        return
    end

    local ok, playerMinLevel, playerMaxLevel, petMinLevel, petMaxLevel =
        pcall(C_Map.GetMapLevels, mapID)

    if not ok then
        return
    end

    setFact(facts, "playerMinLevel", tonumber(playerMinLevel))
    setFact(facts, "playerMaxLevel", tonumber(playerMaxLevel))
    setFact(facts, "petMinLevel", tonumber(petMinLevel))
    setFact(facts, "petMaxLevel", tonumber(petMaxLevel))
end

local function collectWorldSize(mapID, facts)
    if type(C_Map.GetMapWorldSize) ~= "function" then
        return
    end

    local ok, width, height = pcall(C_Map.GetMapWorldSize, mapID)
    if not ok then
        return
    end

    setFact(facts, "worldWidth", tonumber(width))
    setFact(facts, "worldHeight", tonumber(height))
end

local function collectMapArtID(mapID, facts)
    if type(C_Map.GetMapArtID) ~= "function" then
        return
    end

    local ok, mapArtID = pcall(C_Map.GetMapArtID, mapID)
    if ok then
        setFact(facts, "mapArtId", tonumber(mapArtID))
    end
end

local function collectMap(mapID, visited, depth)
    mapID = tonumber(mapID)

    if not mapID or mapID <= 0 then
        return 0
    end

    if depth > MAX_PARENT_DEPTH or visited[mapID] then
        return 0
    end

    visited[mapID] = true

    if type(C_Map) ~= "table" or type(C_Map.GetMapInfo) ~= "function" then
        return 0
    end

    local ok, info = pcall(C_Map.GetMapInfo, mapID)
    if not ok or type(info) ~= "table" then
        return 0
    end

    local facts = {}

    if type(info.name) == "string" and info.name ~= "" then
        setFact(facts, "name", info.name)
    end

    setFact(facts, "mapType", tonumber(info.mapType))
    setFact(facts, "parentMapId", tonumber(info.parentMapID))
    setFact(facts, "flags", tonumber(info.flags))

    collectMapLevels(mapID, facts)
    collectWorldSize(mapID, facts)
    collectMapArtID(mapID, facts)

    local recorded = ns.RecordObservation(
        "map",
        { id = mapID },
        facts
    )

    local count = recorded and 1 or 0
    local parentMapID = tonumber(info.parentMapID)

    if parentMapID and parentMapID > 0 and parentMapID ~= mapID then
        count = count + collectMap(parentMapID, visited, depth + 1)
    end

    return count
end

function ns.CollectCurrentMap()
    if type(C_Map) ~= "table" or
        type(C_Map.GetBestMapForUnit) ~= "function"
    then
        return 0
    end

    local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
    if not ok then
        return 0
    end

    return collectMap(mapID, {}, 1)
end
