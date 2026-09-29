local _, ns = ...

local apiPaths = {
    "GetBuildInfo",
    "GetLocale",
    "GetServerTime",
    "GetTime",
    "GetQuestLogTitle",
    "GetSpellInfo",
    "GetItemInfo",
    "GetPetHappiness",
    "GetPetLoyalty",
    "UnitBuff",
    "C_AddOns.GetAddOnMetadata",
    "C_QuestLog.GetTitleForQuestID",
    "C_Map.GetBestMapForUnit",
    "C_Map.GetMapInfo",
    "C_Spell.GetSpellInfo",
    "C_Item.GetItemInfo",
    "C_UnitAuras.GetUnitAuras",
}

local function resolvePath(path)
    local value = _G

    for part in string.gmatch(path, "[^.]+") do
        if type(value) ~= "table" then
            return nil
        end

        value = value[part]
        if value == nil then
            return nil
        end
    end

    return value
end

function ns.ScanApis()
    for _, path in ipairs(apiPaths) do
        local value = resolvePath(path)

        ns.RecordObservation(
            "api",
            { key = path },
            {
                available = value ~= nil,
                valueType = type(value),
            }
        )
    end
end
