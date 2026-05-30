# MMOSkillTranslationsPack

Community-maintained translations for the [MMO Skill Tree](https://www.curseforge.com/hytale/mmoskilltree) mod for Hytale.

Ships 8 languages out of the box:

| Language    | BCP 47 code | Native name |
|-------------|-------------|-------------|
| Spanish     | `es-ES`     | Español     |
| French      | `fr-FR`     | Français    |
| German      | `de-DE`     | Deutsch     |
| Italian     | `it-IT`     | Italiano    |
| Portuguese  | `pt-BR`     | Português   |
| Russian     | `ru-RU`     | Русский     |
| Hungarian   | `hu-HU`     | Magyar      |
| Turkish     | `tr-TR`     | Türkçe      |

English ships inside the main mod jar (also as a `.lang` file at `Server/Languages/en-US/`), so the mod runs English-only without this pack. Install this pack to get the languages above.

## How it works

Hytale has a built-in localization system. Every installed asset pack can drop `.lang` files at `Server/Languages/<bcp47>/` and the engine auto-discovers them. This pack ships nothing but those files plus a manifest — no custom Java, no special asset type.

Internally, MMOSkillTree's `Messages.get(...)` calls resolve through:
1. Server admin override (`mods/mmoskilltree/localization/messages-<iso>.json` if the admin customized it)
2. Hytale's `I18nModule` (the JAR-bundled English + every translation pack on disk)
3. In-code English fallback (so untranslated keys always render readably)

## Install (server admins)

1. Download `MMOSkillTranslationsPack.zip` from the [releases page](https://github.com/arfemia/MMOSkillTranslationsPack/releases) (or the CurseForge listing).
2. Drop the zip into your Hytale server's `UserData/Mods/` folder.
3. Restart the server.
4. Confirm via the server log: `I18nModule` reports loading translations from the pack.

Players pick their language via the in-game settings menu (`/mmoconfig`). MMOSkillTree stores language codes as ISO 639-1 (`it`, `es`, etc.) and bridges to BCP 47 (`it-IT`, `es-ES`) at the `I18nModule` boundary, so the picker stays simple while the pack files match Hytale conventions.

## Edit translations locally

Server admins can override any string per-server by creating `mods/mmoskilltree/localization/messages-<iso>.json` on disk (e.g. `messages-it.json` for Italian). Owner-file values win over the pack content. Run `/mmoconfig reload` after editing to pick up changes without a restart.

## Contribute a new language

The pack is open source. PRs welcome.

### Adding a brand-new language

1. Pick a [BCP 47 locale code](https://en.wikipedia.org/wiki/IETF_language_tag) — e.g. `ko-KR` for Korean, `pl-PL` for Polish, `ja-JP` for Japanese.
2. Create a new directory: `Server/Languages/<bcp47>/`
3. Copy an existing language's 5 files (e.g. `Server/Languages/it-IT/*.lang`) into your new directory.
4. Translate each value. Keep keys exactly as-is. `{0}`, `{1}` placeholders must stay in place (they're filled at runtime with names and numbers).
5. Add a `language.name = <native-name>` entry to your `ui.lang` (so the in-game language picker shows the native label).
6. Rebuild the zip: `pwsh tools/build.ps1`
7. Open a PR.

Brand-new languages won't appear in the in-game picker by default — MMOSkillTree's picker lists a fixed known-language set plus any server-side owner files. The translations still load and serve any player whose Hytale client reports that locale. To make it pickable, an admin creates an empty `messages-<iso>.json` owner file (the ISO 639-1 form of your locale).

### Improving an existing language

Open the relevant `Server/Languages/<bcp47>/<namespace>.lang` file, edit the values, rebuild the zip, open a PR.

### Namespace convention

Each language splits into 5 sibling files by key-prefix so reviewers can focus on one area at a time:

| File              | Key prefixes                                          |
|-------------------|-------------------------------------------------------|
| `ui.lang`         | `ui.*`, `language.name`                               |
| `skills.lang`     | `skill.*`, `reward.*`                                 |
| `abilities.lang`  | `ability.*`                                           |
| `content.lang`    | `mastery.*`, `quest.*`, `achievement.*`, `currency.*` |
| `system.lang`     | `command.*`, `notify.*`, `error.*`, etc.              |

The split is purely organizational. Hytale's `I18nModule` merges all sibling `.lang` files under the same locale dir into one flat key namespace, so you can split further or collapse to a single file as you prefer. Do not nest into subdirectories — subdirectories add a dot-prefix to every key, which would mangle our key naming.

### Per-key English fallback

Don't have to translate every key. Untranslated keys fall back to English at lookup time (via Hytale's `I18nModule`, then via the mod's in-code defaults), so partial translations work fine. Ship what you have, the rest stays in English until someone else picks it up.

## `.lang` file format

Plain text key-value pairs, UTF-8, no BOM. See [Hytale's bundled `server.lang`](https://github.com/HytaleModding/site) for canonical examples.

```
# Comments start with #
key = value
key.with.dots = Another value
key.with.placeholders = Welcome, {0}! You earned {1} XP.
key.with.quoted_whitespace = "  preserved leading and trailing space  "
multiline.example = first part \
continued on next line
```

## Project structure

```
skill-translations-pack/
├── manifest.json                                  Hytale plugin manifest
├── README.md                                      this file
├── CLAUDE.md                                      contributor / agent notes
├── CURSEFORGE.md                                  CurseForge listing copy
├── LICENSE                                        MIT
├── MMOSkillTranslationsPack.zip                   built artifact (gitignored)
├── tools/
│   └── build.ps1                                  rebuild the zip
└── Server/
    └── Languages/
        ├── es-ES/{ui,skills,abilities,content,system}.lang
        ├── fr-FR/{ui,skills,abilities,content,system}.lang
        └── ... (8 languages × 5 files = 40 files)
```

## License

MIT. Translations themselves are dedicated to the public domain (CC0) — they're community-contributed strings, not authored content.
