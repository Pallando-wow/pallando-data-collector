local _, ns = ...

function ns.CollectClientMetadata()
    local db = ns.EnsureDatabase()
    if not db then
        return false
    end

    local version, build, _, interface = GetBuildInfo()

    db.client = {
        id = ns.CLIENT_ID,
        version = tostring(version or ""),
        build = tonumber(build) or 0,
        interface = tonumber(interface) or 0,
    }

    db.locale = type(GetLocale) == "function" and GetLocale() or ""
    db.updatedAtEpoch = ns.Now()

    return true
end
