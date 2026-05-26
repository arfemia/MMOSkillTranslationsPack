# MMOSkillTranslationsPack

Community-maintained translations for the [MMO Skill Tree](https://www.curseforge.com/hytale/mmoskilltree) mod for Hytale.

Ships 8 languages out of the box:

| Language    | Code | Native name |
|-------------|------|-------------|
| Spanish     | `es` | Español     |
| French      | `fr` | Français    |
| German      | `de` | Deutsch     |
| Italian     | `it` | Italiano    |
| Portuguese  | `pt` | Português   |
| Russian     | `ru` | Русский     |
| Hungarian   | `hu` | Magyar      |
| Turkish     | `tr` | Türkçe      |

English ships inside the main mod jar — install the mod, you get English; install this pack, you get the languages above.

## Install (server admins)

1. Download `MMOSkillTranslationsPack.zip` from the [releases page](https://github.com/arfemia/MMOSkillTranslationsPack/releases) (or the CurseForge listing).
2. Drop the zip into your Hytale server's `UserData/Mods/` folder.
3. Restart the server.
4. Confirm via the server log: `[Localizations] Merged N pack asset(s) covering 8 language(s)`.

Players pick their language via the in-game settings menu (`/mmoconfig`).

## Edit translations locally

Once the pack has loaded for the first time, the mod writes a per-language file to `mods/mmoskilltree/localization/messages-{lang}.json` on disk. Edit those files freely — your edits override the pack content for that server. Run `/mmoconfig reload` (or restart) to pick up changes.

If you uninstall the pack, your `messages-{lang}.json` files keep working (they're a snapshot of pack content from when it was first seeded).

## Contribute a new language

The pack is open source — PRs welcome.

### Adding a brand-new language

1. Pick an [ISO 639-1 lang code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) (`ko` for Korean, `pl` for Polish, etc.).
2. Copy `Server/MMOSkillTree/Localizations/Italian_UI.json` (or any UI file) as a starting template.
3. Rename to `<EnglishLanguageName>_UI.json` (e.g. `Korean_UI.json`).
4. Edit the file:
   - `"Id"`: match the new filename (without `.json`) — e.g. `"Korean_UI"`. **Must start with an uppercase letter** (Hytale's `KeyedCodec` requires this).
   - `"Payload.language"`: lowercase ISO 639-1 code, e.g. `"ko"`.
   - `"Payload.displayName"`: native name of the language, e.g. `"한국어"` (only needed in the `_UI` file — it's the language's "primary" file).
   - `"Payload.messages"`: translate each value. Keep keys exactly as-is. `{0}`, `{1}` placeholders must stay in place (they're filled at runtime with names/numbers).
5. Repeat for the other namespaces (`_Skills.json`, `_Abilities.json`, `_Content.json`, `_System.json`) — or stuff everything into one file with a single `Id` like `"Korean"` if you prefer.
6. Rebuild the zip: `pwsh tools/build.ps1`
7. Open a PR.

### Improving an existing language

Open the relevant `<Language>_<Namespace>.json` file, edit the message values, rebuild the zip, open a PR.

### Namespace convention (optional)

Each language splits into 5 files by key-prefix so reviewers can focus on one area at a time:

| File                  | Key prefixes                                  |
|-----------------------|-----------------------------------------------|
| `<Lang>_UI.json`      | `ui.*`, `language.name`                       |
| `<Lang>_Skills.json`  | `skill.*`, `reward.*`                         |
| `<Lang>_Abilities.json` | `ability.*`                                 |
| `<Lang>_Content.json` | `mastery.*`, `quest.*`, `achievement.*`, `currency.*` |
| `<Lang>_System.json`  | everything else (`command.*`, `notify.*`, `error.*`, …) |

The split is just a convention — the mod merges every `Payload.language: "<code>"` asset into one bundle at load time, regardless of filename. If you'd rather ship one big file, name it `<Lang>.json` and put everything in `Payload.messages`.

### Per-key English fallback

You don't have to translate every key. Untranslated keys fall back to English at lookup time, so partial translations work fine — ship what you have, the rest stays in English until someone else picks it up.

## Project structure

```
skill-translations-pack/
├── manifest.json                                  Hytale plugin manifest
├── README.md                                      this file
├── CLAUDE.md                                      contributor / agent notes
├── CURSEFORGE.md                                  CurseForge listing copy
├── MMOSkillTranslationsPack.zip                   built artifact (gitignored)
├── tools/
│   └── build.ps1                                  rebuild the zip
└── Server/
    └── MMOSkillTree/
        ├── Control/MMOSkillTranslationsPack.json  pack-control manifest
        └── Localizations/
            ├── Spanish_UI.json,    Spanish_Skills.json,    ...   (5 files)
            ├── French_UI.json,     French_Skills.json,     ...   (5 files)
            ├── ... (8 languages × 5 namespaces = 40 files)
```

## License

MIT. Translations themselves are dedicated to the public domain (CC0) — they're community-contributed strings, not authored content.
