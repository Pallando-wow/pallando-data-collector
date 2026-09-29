# Pallando Data Collector

Privacy-focused World of Warcraft development data collector for **WoW Forever**.

The addon observes technical facts that are useful for addon development and stores them in WoW SavedVariables. The collected data is designed to be imported, validated and normalized by **Pallando's WoW Addon Studio** before selected facts are published in `Pallando-wow/wow-development-data`.

## Current scope

Version 0.1.0 provides the collector foundation:

- WoW Forever client version, build, Interface and locale
- a curated API availability scan
- support/observation tracking for selected WoW events
- bounded, deduplicated SavedVariables storage
- `/pdc status`, `/pdc scan` and guarded `/pdc reset confirm` commands

No quest, item, spell, NPC, map, profession or pet gameplay data is collected yet.

## Privacy principles

- no network access from the addon
- no character names, player GUIDs or Battle.net identities
- no guild, friend, whisper or chat data
- no machine, installation or persistent user identifiers
- raw SavedVariables are evidence, not an authoritative public dataset
- public data is validated before publication

## Project layout

This repository is also a managed Pallando's WoW Addon Studio project:

```text
project.json
AddOns/
└─ PallandoDataCollector/
Documentation/
```

The runtime addon folder contains no documentation or repository-only files.

## Data flow

```text
WoW Forever
 ↓
PallandoDataCollector
 ↓
SavedVariables
 ↓
Pallando's WoW Addon Studio
 ↓
validation / normalization / aggregation
 ↓
Pallando WoW Development Data
```

The normalized public data contract is maintained in `Pallando-wow/wow-development-data`. Collector export and published entity schemas currently use schema version 2.

## License

Pallando Data Collector is licensed under the GNU General Public License v3.0 or later (GPL-3.0-or-later).

World of Warcraft and Blizzard Entertainment are trademarks or registered trademarks of Blizzard Entertainment, Inc. This project is not affiliated with or endorsed by Blizzard Entertainment.
