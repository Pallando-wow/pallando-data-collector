local _, ns = ...

local function printMessage(message)
    print("|cff66ccffPDC|r: " .. message)
end

local function showStatus()
    local db = ns.EnsureDatabase()

    if not db then
        printMessage(ns.STORAGE_ERROR or "SavedVariables are unavailable.")
        return
    end

    local client = db.client or {}
    local records = ns.CountRecords()

    printMessage(
        string.format(
            "v%s | client %s | build %s | interface %s | %d records | %d observations",
            ns.VERSION,
            tostring(client.version or "?"),
            tostring(client.build or "?"),
            tostring(client.interface or "?"),
            records,
            tonumber(db.stats and db.stats.totalObservations) or 0
        )
    )
end

local function showHelp()
    printMessage("/pdc status - show collector status")
    printMessage("/pdc scan - rescan APIs and the current map")
    printMessage("/pdc map - rescan the current map and its parent maps")
    printMessage("/pdc reset confirm - delete collected SavedVariables")
end

local function scanCurrentMap()
    local count = ns.CollectCurrentMap()
    printMessage(
        string.format(
            "Map scan completed (%d map records observed).",
            tonumber(count) or 0
        )
    )
end

SLASH_PALLANDODATACOLLECTOR1 = "/pdc"

SlashCmdList.PALLANDODATACOLLECTOR = function(message)
    local command = string.lower(
        string.match(message or "", "^%s*(.-)%s*$") or ""
    )

    if command == "" or command == "status" then
        showStatus()
        return
    end

    if command == "scan" then
        ns.ScanApis()
        local count = ns.CollectCurrentMap()
        printMessage(
            string.format(
                "API and map scan completed (%d map records observed).",
                tonumber(count) or 0
            )
        )
        return
    end

    if command == "map" then
        scanCurrentMap()
        return
    end

    if command == "reset confirm" then
        ns.ResetDatabase()
        ns.CollectClientMetadata()
        ns.ScanApis()
        ns.CollectCurrentMap()
        printMessage("Collected data has been reset.")
        return
    end

    showHelp()
end

local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(_, eventName, argument)
    if eventName == "ADDON_LOADED" then
        if argument == ns.ADDON_NAME then
            ns.EnsureDatabase()
        end
        return
    end

    if eventName == "PLAYER_LOGIN" then
        local db = ns.EnsureDatabase()
        if not db then
            return
        end

        db.stats.sessions = (db.stats.sessions or 0) + 1
        ns.CollectClientMetadata()
        ns.ScanApis()
        ns.CollectCurrentMap()
        ns.InitializeEventCollector()
        return
    end

    if eventName == "PLAYER_LOGOUT" then
        local db = ns.EnsureDatabase()
        if db then
            db.updatedAtEpoch = ns.Now()
        end
    end
end)
