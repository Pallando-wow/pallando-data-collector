# Pallando Data Collector

Privacy-focused World of Warcraft development data collector for **WoW Forever**.

The addon observes technical facts that are useful for addon development and stores them in WoW SavedVariables. The collected data is designed to be imported, validated and normalized by **Pallando's WoW Addon Studio** before selected facts are published in `Pallando-wow/wow-development-data`.

## Principles

- WoW Forever only
- no network access from the addon
- no character names, player GUIDs or Battle.net identities
- no guild, friend, whisper or chat data
- no machine, installation or persistent user identifiers
- raw SavedVariables are evidence, not an authoritative public dataset
- public data is validated before publication

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

## License

Pallando Data Collector is licensed under the GNU General Public License v3.0 or later (GPL-3.0-or-later).

World of Warcraft and Blizzard Entertainment are trademarks or registered trademarks of Blizzard Entertainment, Inc. This project is not affiliated with or endorsed by Blizzard Entertainment.
