local _, ns = ...

local eventNames = {
    "PLAYER_ENTERING_WORLD",
    "ZONE_CHANGED",
    "ZONE_CHANGED_INDOORS",
    "ZONE_CHANGED_NEW_AREA",
    "QUEST_ACCEPTED",
    "QUEST_TURNED_IN",
    "QUEST_LOG_UPDATE",
    "SPELLS_CHANGED",
    "BAG_UPDATE_DELAYED",
    "SKILL_LINES_CHANGED",
    "UNIT_PET",
    "PET_BAR_UPDATE",
    "PET_UI_UPDATE",
    "UPDATE_MOUSEOVER_UNIT",
}

local mapEvents = {
    PLAYER_ENTERING_WORLD = true,
    ZONE_CHANGED = true,
    ZONE_CHANGED_INDOORS = true,
    ZONE_CHANGED_NEW_AREA = true,
}

local eventFrame
local initialized = false

function ns.InitializeEventCollector()
    if initialized then
        return
    end

    initialized = true
    eventFrame = CreateFrame("Frame")

    eventFrame:SetScript("OnEvent", function(_, eventName)
        ns.RecordObservation(
            "event",
            { key = eventName },
            {
                supported = true,
                observed = true,
            }
        )

        if mapEvents[eventName] and ns.CollectCurrentMap then
            ns.CollectCurrentMap()
        end
    end)

    for _, eventName in ipairs(eventNames) do
        local ok, result = pcall(
            eventFrame.RegisterEvent,
            eventFrame,
            eventName
        )

        local supported = ok and result ~= false

        ns.RecordObservation(
            "event",
            { key = eventName },
            {
                supported = supported,
            }
        )
    end
end
