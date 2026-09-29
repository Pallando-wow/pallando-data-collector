local _, ns = ...

local function now()
    if type(GetServerTime) == "function" then
        local value = GetServerTime()
        if type(value) == "number" and value > 0 then
            return value
        end
    end

    if type(time) == "function" then
        return time()
    end

    return 0
end

local function newDatabase()
    local timestamp = now()

    return {
        schemaVersion = ns.STORAGE_SCHEMA_VERSION,
        collector = {
            name = "PallandoDataCollector",
            version = ns.VERSION,
            exportSchemaVersion = ns.EXPORT_SCHEMA_VERSION,
        },
        client = {},
        locale = "",
        createdAtEpoch = timestamp,
        updatedAtEpoch = timestamp,
        observations = {},
        stats = {
            sessions = 0,
            totalObservations = 0,
        },
    }
end

local function copyEntity(entity)
    if type(entity) ~= "table" then
        return nil
    end

    if type(entity.id) == "number" and entity.id > 0 then
        return { id = entity.id }
    end

    if type(entity.key) == "string" and entity.key ~= "" then
        return { key = entity.key }
    end

    return nil
end

local function identityKey(entity)
    if entity.id then
        return "id:" .. tostring(entity.id)
    end

    return "key:" .. entity.key
end

local function sanitizeFactValue(value)
    local valueType = type(value)

    if valueType == "boolean" or valueType == "number" then
        return value
    end

    if valueType == "string" then
        if #value > 256 then
            return string.sub(value, 1, 256)
        end
        return value
    end

    if valueType == "table" then
        local result = {}

        for index = 1, math.min(#value, 100) do
            if type(value[index]) ~= "number" then
                return nil
            end
            result[index] = value[index]
        end

        return result
    end

    return nil
end

function ns.Now()
    return now()
end

function ns.EnsureDatabase()
    if type(PallandoDataCollectorDB) ~= "table" then
        PallandoDataCollectorDB = newDatabase()
    end

    local db = PallandoDataCollectorDB

    if db.schemaVersion ~= ns.STORAGE_SCHEMA_VERSION then
        ns.STORAGE_ERROR = "Unsupported SavedVariables schema version."
        return nil
    end

    db.collector = db.collector or {}
    db.collector.name = "PallandoDataCollector"
    db.collector.version = ns.VERSION
    db.collector.exportSchemaVersion = ns.EXPORT_SCHEMA_VERSION
    db.client = db.client or {}
    db.observations = db.observations or {}
    db.stats = db.stats or {}
    db.stats.sessions = db.stats.sessions or 0
    db.stats.totalObservations = db.stats.totalObservations or 0
    db.updatedAtEpoch = now()

    return db
end

function ns.ResetDatabase()
    PallandoDataCollectorDB = newDatabase()
    ns.STORAGE_ERROR = nil
    return PallandoDataCollectorDB
end

function ns.RecordObservation(kind, entity, facts)
    if type(kind) ~= "string" or kind == "" then
        return false
    end

    local normalizedEntity = copyEntity(entity)
    if not normalizedEntity then
        return false
    end

    local db = ns.EnsureDatabase()
    if not db then
        return false
    end

    local kindBucket = db.observations[kind]
    if type(kindBucket) ~= "table" then
        kindBucket = {}
        db.observations[kind] = kindBucket
    end

    local key = identityKey(normalizedEntity)
    local timestamp = now()
    local record = kindBucket[key]

    if type(record) ~= "table" then
        record = {
            entity = normalizedEntity,
            facts = {},
            firstSeenEpoch = timestamp,
            lastSeenEpoch = timestamp,
            observationCount = 0,
            builds = {},
        }
        kindBucket[key] = record
    end

    if type(facts) == "table" then
        for factName, value in pairs(facts) do
            if type(factName) == "string" and factName ~= "" then
                local normalized = sanitizeFactValue(value)
                if normalized ~= nil then
                    record.facts[factName] = normalized
                end
            end
        end
    end

    record.lastSeenEpoch = timestamp
    record.observationCount = (record.observationCount or 0) + 1

    local build = tonumber(db.client and db.client.build)
    if build and build > 0 then
        record.builds[tostring(build)] = true
    end

    db.stats.totalObservations = (db.stats.totalObservations or 0) + 1
    db.updatedAtEpoch = timestamp

    return true
end

function ns.CountRecords()
    local db = ns.EnsureDatabase()
    if not db then
        return 0
    end

    local count = 0

    for _, bucket in pairs(db.observations) do
        if type(bucket) == "table" then
            for _ in pairs(bucket) do
                count = count + 1
            end
        end
    end

    return count
end
