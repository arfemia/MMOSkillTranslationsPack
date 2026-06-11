# MMOSkillTranslationsPack

> **DEPRECATED — not maintained.** This pack was never published. All MMOSkillTree translations (all 9 languages) now ship bundled inside the mod jar at `Server/Languages/<bcp47>/mmoskilltree.lang`. Do not add or edit translations here; edit the jar's `.lang` files in the main MMOSkillTree repo. This working tree is kept for reference only.

Community-maintained translations for the [MMO Skill Tree](https://www.curseforge.com/hytale/mmoskilltree) mod for Hytale.

Ships 8 languages out of the box as standard Hytale `.lang` files:

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

English ships inside the MMOSkillTree mod jar (also as a `.lang` file at `Server/Languages/en-US/mmoskilltree.lang`), so the mod runs English-only without this pack. Install this pack to get the languages above.

## How it works

Hytale has a built-in localization system. Every installed asset pack can drop `.lang` files at `Server/Languages/<bcp47>/` and the engine auto-discovers them. This pack ships nothing but those files plus a manifest. No custom Java, no special asset type.

Internally, MMOSkillTree's `Messages.get(...)` calls resolve through:
1. Server admin override (`mods/mmoskilltree/localization/messages-<iso>.json` if the admin customized it)
2. Hytale's `I18nModule` (the JAR-bundled English + every translation pack on disk)
3. In-code English fallback (so untranslated keys always render readably)

## Install (server admins)

1. Download `MMOSkillTranslationsPack.zip` from the [releases page](https://github.com/arfemia/MMOSkillTranslationsPack/releases) (or the CurseForge listing).
2. Drop the zip into your Hytale server's `UserData/Mods/` folder.
3. Restart the server.
4. Confirm via the server log: per-locale lines like `[I18nModule|P] Loaded N entries for 'it-IT' from /Server/Languages`.

Players pick their language via the in-game settings menu (`/mmoconfig`). MMOSkillTree stores language codes as ISO 639-1 (`it`, `es`, etc.) and bridges to BCP 47 (`it-IT`, `es-ES`) at the `I18nModule` boundary, so the picker stays simple while the pack files match Hytale conventions.

## Edit translations locally

Server admins can override any string per-server by creating `mods/mmoskilltree/localization/messages-<iso>.json` on disk (e.g. `messages-it.json` for Italian). Owner-file values win over the pack content. Run `/mmoconfig reload` after editing to pick up changes without a restart.

## Pack structure

```
Server/Languages/
├── es-ES/mmoskilltree.lang
├── fr-FR/mmoskilltree.lang
├── de-DE/mmoskilltree.lang
├── it-IT/mmoskilltree.lang
├── pt-BR/mmoskilltree.lang
├── ru-RU/mmoskilltree.lang
├── hu-HU/mmoskilltree.lang
└── tr-TR/mmoskilltree.lang
```

One `mmoskilltree.lang` file per locale. Each file contains the full translation for that language.

**Why one file per locale (and the specific name):** Hytale's `I18nModule` loader prepends the filename (minus `.lang`) as a dot-separated prefix to every key in the file. Naming the file `mmoskilltree.lang` makes Hytale load keys as `mmoskilltree.<original-key>`, which the MMOSkillTree mod adjusts for at the lookup boundary so contributors write bare keys (`ui.settings.title`) inside the file. Splitting one locale across multiple sibling `.lang` files would give each file a different prefix and break the lookup, so the convention is one file per locale.

## Contribute a new language

The pack is open source. PRs welcome.

### Adding a brand-new language

1. Pick a [BCP 47 locale code](https://en.wikipedia.org/wiki/IETF_language_tag) (e.g. `ko-KR` for Korean, `pl-PL` for Polish, `ja-JP` for Japanese).
2. Create a new directory: `Server/Languages/<bcp47>/`
3. Copy an existing language's `mmoskilltree.lang` (e.g. `Server/Languages/it-IT/mmoskilltree.lang`) into your new directory.
4. Translate each value. Keep keys exactly as-is. `{0}`, `{1}` placeholders must stay in place (they're filled at runtime with names and numbers).
5. Make sure your file includes `language.name = <native-name>` so the in-game language picker shows the native label.
6. Rebuild the zip: `.\build.ps1 -Install:$false` (or `pwsh ./build.ps1 -Install:$false` on macOS/Linux).
7. Open a PR.

Brand-new languages won't appear in the in-game picker by default. MMOSkillTree's picker lists a fixed known-language set (the 8 above plus English) plus any server-side admin owner files. The translations still load and serve any player whose Hytale client reports that locale. To make a new language pickable, an admin creates a matching empty `messages-<iso>.json` owner file on their server (the ISO 639-1 form of your locale, e.g. `messages-ko.json` for Korean).

### Improving an existing language

Open the relevant `Server/Languages/<bcp47>/mmoskilltree.lang`, edit the values, rebuild the zip (`.\build.ps1 -Install:$false`), open a PR.

### Per-key English fallback

You don't have to translate every key. Untranslated keys fall back to English at lookup time (via Hytale's `I18nModule` first, then via the mod's in-code defaults), so partial translations work fine. Ship what you have; the rest stays in English until someone else picks it up.

### Empty-value gotcha

`LangFileParser` rejects empty values (`key = ` with nothing after the `=`) and aborts the entire file. Don't ship empty strings. If you want a key to fall through to English, omit it entirely from your `.lang` file.

## `.lang` file format

Plain text, UTF-8, no BOM.

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
├── build.ps1                                      rebuild the zip
└── Server/
    └── Languages/
        └── <bcp47>/mmoskilltree.lang              (8 locales)
```

## License

MIT. Translations themselves are dedicated to the public domain (CC0) — they're community-contributed strings, not authored content.
