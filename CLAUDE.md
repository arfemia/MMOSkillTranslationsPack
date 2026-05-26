# CLAUDE.md — MMOSkillTranslationsPack

This directory is a standalone Hytale content pack that ships translations for the [hyMMO plugin](../). The plugin's jar no longer ships any `*Defaults.java` for non-English languages — they live here as JSON, contributable by the community.

English stays baked into the mod jar (`EnglishDefaults.java`) as the authoritative reference + per-key fallback for every other language.

## Layout

```
skill-translations-pack/
├── manifest.json                                  Hytale plugin manifest
├── CLAUDE.md                                      this file
├── README.md                                      public-facing contributor guide
├── CURSEFORGE.md                                  CurseForge listing copy
├── MMOSkillTranslationsPack.zip                   built artifact (gitignored if you regenerate)
├── tools/
│   └── build.ps1                                  rebuild the zip
└── Server/
    └── MMOSkillTree/
        ├── Control/MMOSkillTranslationsPack.json  declares "Localizations": "add"
        └── Localizations/*.json                   40 files — 8 languages x 5 namespaces
```

## Build & deploy

Same pattern as `../skill-mastery-pack/` — use `[IO.Compression.ZipFile]` with forward-slash entry paths. PowerShell's `Compress-Archive` writes backslash separators on Windows that Hytale silently drops.

```powershell
pwsh skill-translations-pack/tools/build.ps1            # rebuild zip
pwsh skill-translations-pack/tools/build.ps1 install    # rebuild + copy to D:\Games\Hytale\UserData\Mods\
```

Top-level docs (CLAUDE.md, README.md, CURSEFORGE.md) are excluded from the zip — they're for humans, not Hytale.

## Pack JSON conventions

### Filename = asset key (PascalCase, uppercase-first)

Hytale's `KeyedCodec` requires JSON keys to start uppercase, and the asset id is derived from the filename. So `Italian_UI.json` produces asset id `Italian_UI`. `italian_ui.json` would parse-fail at server startup.

### Schema

```json
{
  "Id": "Italian_UI",
  "Payload": {
    "language": "it",
    "displayName": "Italiano",
    "messages": {
      "ui.settings.title": "Impostazioni",
      "ui.settings.show_xp_gains": "Mostra guadagni XP"
    }
  }
}
```

Fields:

- **`Id`** — must echo the filename (without `.json`). Uppercase-first. The mod doesn't read this field directly (it uses `Payload.language` for grouping), but Hytale's loader requires it.
- **`Payload.language`** — **required**. Lowercase ISO 639-1 code (`it`, `es`, `ko`, …). The handler in `LocalizationConfig.mergePackLayer` groups every asset with the same `language` into one bundle.
- **`Payload.displayName`** — optional. Native-language name (`Italiano`). Convention is to set this only on the `_UI` file per language — it's redundant with the `language.name` message key (which is what the runtime actually looks up via `LocalizationConfig.getLanguageName()`), but pack authors can set it without knowing about the magic key.
- **`Payload.messages`** — flat key→string map. Insertion order is preserved (LinkedHashMap on the receiving side).

### Namespace split

For readability + reviewability, each language is split into 5 files by key-prefix. The split is purely organizational — the handler merges all assets with the same `Payload.language` regardless of filename, so a pack author can collapse to one file (`Italian.json`) or split further (`Italian_Abilities_Combat.json` + `Italian_Abilities_Gathering.json`) — anything goes as long as each asset has a unique `Id`.

| File                    | Key prefixes covered                                |
|-------------------------|-----------------------------------------------------|
| `<Lang>_UI.json`        | `ui.*`, `language.name`                             |
| `<Lang>_Skills.json`    | `skill.*`, `reward.*`                               |
| `<Lang>_Abilities.json` | `ability.*`                                         |
| `<Lang>_Content.json`   | `mastery.*`, `quest.*`, `achievement.*`, `currency.*` |
| `<Lang>_System.json`    | everything else                                     |

## Three-layer precedence (defaults < pack < owner)

`LocalizationConfig` composes three layers at lookup time:

1. **Defaults** (in-mod JAR) — English only. `EnglishDefaults.java`.
2. **Pack** — JSONs from this directory. Multiple translation packs can coexist; the asset store merges them by `Id` with last-pack-wins.
3. **Owner** — admin edits in `mods/mmoskilltree/localization/messages-{lang}.json`. Highest priority. On first pack-install, the mod seeds these files from the composed defaults+pack view so admins have an editable file on disk per language.

A missing key in any layer falls through to the next; final fallback is English. Empty-string values are still values — they suppress fallback. Use a missing key (or omit it from your JSON entirely) to fall back, not an empty string.

## Sync with the plugin

When the plugin adds new i18n keys (new UI, new skill, new ability), `EnglishDefaults.java` gets the new entries in code. Other languages won't have them until this pack is updated. The mod's per-key English fallback means players see English for the new keys until then — graceful degradation, no crashes.

When updating a language file in this pack, prefer **only adding the new keys** (preserve existing translations untouched). The mod merges layer-by-layer per-key, so partial updates are safe.

## Verification

1. Build the plugin: `./gradlew build` from the parent directory (`..`).
2. Build the pack zip: `pwsh tools/build.ps1 install` (also copies to the local Hytale mods folder).
3. Start the Hytale server. Confirm in the server log:
   - `[Localizations] Merged 40 pack asset(s) covering 8 language(s): [es, fr, pt, hu, tr, de, it, ru]`
   - No `Failed to decode asset:` or `Asset validation FAILED` lines (those mean the JSON shape is off — usually a missing `Payload`).
4. In-game: open `/mmoconfig`, switch language to e.g. Italian, confirm UI updates and combat/skill text renders in Italian.
5. Edit a value in `mods/mmoskilltree/localization/messages-it.json`, run `/mmoconfig reload`, confirm the change applies live.
