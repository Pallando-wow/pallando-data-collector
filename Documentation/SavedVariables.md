# SavedVariables format

`PallandoDataCollectorDB` is the raw evidence store written by the WoW addon.

It is deliberately not identical to the public JSON dataset format. Pallando's WoW Addon Studio is responsible for importing the Lua SavedVariables file, validating it and producing normalized JSON that follows the schemas in `Pallando-wow/wow-development-data`.

## Root structure

The storage schema is version 1.

```text
schemaVersion
collector
client
locale
createdAtEpoch
updatedAtEpoch
observations
stats
```

The collector records no character name, player GUID, Battle.net identity, guild, friend, chat, machine identifier or persistent user identifier.

## Observations

Observations are bucketed by kind and stable entity identity.

Numeric WoW entities use:

```lua
entity = { id = 12345 }
```

Named technical entities use:

```lua
entity = { key = "GetBuildInfo" }
```

Each stored record contains small machine-readable facts plus:

- first seen epoch
- last seen epoch
- observation count
- distinct observed builds

Repeated observations update the existing record rather than appending an unbounded event log.

## Current collectors

Version 0.1.1 records:

- exact client version, build, Interface number and locale
- availability/type of a curated list of addon-development APIs
- support and observation of a curated list of relevant WoW events
- the player's current UI map and its parent-map chain when map/zone state changes

Map records can include the localized map name, map type, parent map id, flags, level ranges, map art id and world dimensions when the WoW API provides them.

No quest, item, spell, NPC, profession or pet gameplay data is collected yet. Those collectors will be added separately once their exact data contracts are defined.
