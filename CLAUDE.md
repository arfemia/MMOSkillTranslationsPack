# CLAUDE.md - MMOSkillTranslationsPack

This directory is a standalone Hytale content pack that ships translations for the [MMOSkillTree mod](https://www.curseforge.com/hytale/mmoskilltree). Translations live as standard Hytale `.lang` files; the mod's jar does not ship any non-English language defaults beyond `EnglishDefaults.java`.

The pack is consumed natively by Hytale's `I18nModule` (`com.hypixel.hytale.server.core.modules.i18n.I18nModule`) - no MMOSkillTree-specific asset type or custom merge handler. The mod's `LocalizationConfig.get(...)` delegates to `I18nModule.getMessage(bcp47, key)` after layering admin owner-file overrides on top.

## Layout

```
skill-translations-pack/
├── manifest.json                                  Hytale plugin manifest
├── CLAUDE.md                                      this file
├── README.md                                      public-facing contributor guide
├── CURSEFORGE.md                                  CurseForge listing copy
├── LICENSE                                        MIT
├── MMOSkillTranslationsPack.zip                   built artifact (gitignored if you regenerate)
├── tools/
│   └── build.ps1                                  rebuild the zip
└── Server/
    └── Languages/                                 Hytale-native i18n path
        ├── es-ES/{ui,skills,abilities,content,system}.lang
        ├── fr-FR/...  (5 files each)
        ├── de-DE/...
        ├── it-IT/...
        ├── pt-BR/...
        ├── ru-RU/...
        ├── hu-HU/...
        └── tr-TR/...  (8 languages x 5 namespaces = 40 files)
```

## Build & deploy

Same pattern as `../skill-mastery-pack/` - `[IO.Compression.ZipFile]` with forward-slash entry paths, because PowerShell's `Compress-Archive` writes backslash separators that Hytale's asset loader silently drops.

```powershell
pwsh skill-translations-pack/tools/build.ps1            # rebuild zip
pwsh skill-translations-pack/tools/build.ps1 install    # rebuild + copy to D:\Games\Hytale\UserData\Mods\
```

Top-level docs (`CLAUDE.md`, `README.md`, `CURSEFORGE.md`), `LICENSE`, and `.gitignore` are excluded from the zip - they're for humans browsing the repo, not for Hytale to load.

## `.lang` file conventions

### Path

`Server/Languages/<bcp47>/<namespace>.lang`. The directory name is the BCP 47 locale code (`it-IT`, not `it`). Sibling `.lang` files in the same locale directory merge into one flat key namespace at load time. Do not nest deeper - subdirectories prepend a dot-prefix to every key, which would mangle MMOSkillTree's key naming.

### Format

Per `LangFileParser` in HytaleServer.jar:

```
# Comment lines start with #
key = value
key.with.dots = Another value
quoted = "leading and trailing whitespace preserved"
multiline = first part \
continued on the next line
escapes = newline becomes \n and tab becomes \t
```

UTF-8 encoded, no BOM. The parser strips whitespace around the `=` and around the value unless the value is double-quoted.

### Placeholders

MMOSkillTree uses positional placeholders (`{0}`, `{1}`, ...) that `Messages.get(skills, key, args...)` substitutes after the lookup. Keep them verbatim in translations. The `.lang` parser treats placeholders as opaque value text, so this works transparently.

### Namespace split

The 5-file convention (`ui`, `skills`, `abilities`, `content`, `system`) is organizational only. The mod's `Messages.get(...)` doesn't care which file a key came from - all sibling files merge before lookup. Contributors who prefer a single combined file can ship one `messages.lang` instead.

| File              | Key prefixes covered                                  |
|-------------------|-------------------------------------------------------|
| `ui.lang`         | `ui.*`, `language.name`                               |
| `skills.lang`     | `skill.*`, `reward.*`                                 |
| `abilities.lang`  | `ability.*`                                           |
| `content.lang`    | `mastery.*`, `quest.*`, `achievement.*`, `currency.*` |
| `system.lang`     | `command.*`, `notify.*`, `error.*`, everything else   |

## Three-layer precedence (admin > pack > English)

MMOSkillTree's `LocalizationConfig.get(langCode, key)` walks:

1. **Owner override** - `mods/mmoskilltree/localization/messages-<iso>.json` on the server. Highest priority. Admin per-server customization.
2. **`I18nModule.getMessage(bcp47, key)`** - merged view of every `.lang` file Hytale found, including the JAR-bundled English in MMOSkillTree's own jar (`src/main/resources/Server/Languages/en-US/messages.lang`).
3. **`I18nModule.getMessage("en-US", key)`** - per-key fallback to English via Hytale's own pipeline.
4. **`EnglishDefaults.java`** in-code map - last-resort safety net (covers very early plugin startup before `I18nModule` finishes loading packs).
5. Empty string if nothing matched.

A missing key in your translation falls through to the next layer; final fallback is English. Empty-string values are still values - they suppress fallback. Use a missing key (or omit it from your `.lang` entirely) to fall back, not an empty string.

## Sync with the mod

When MMOSkillTree adds new i18n keys, those keys land in `EnglishDefaults.java`. The mod's JAR-bundled `messages.lang` regenerates from that file via `EnglishLangExportTest` (gated, disabled by default - see the mod's `.claude/skills/localization/SKILL.md`). Pack languages won't have the new keys until this pack is updated - until then, players see English for the new keys via the fallback chain. Graceful degradation, no crashes.

Prefer additive updates: only add new keys when syncing, leave existing translations alone unless improving them. The mod merges layer-by-layer per-key, so partial updates are safe.

## Language code mapping

MMOSkillTree stores language preferences as ISO 639-1 (`it`, `es`, `pt`, ...) on `SkillComponent.language`. Hytale's `I18nModule` indexes by BCP 47 (`it-IT`, `es-ES`, `pt-BR`, ...). `LocalizationConfig.ISO_TO_BCP47` bridges the two:

| ISO 639-1 | BCP 47 (pack dir) | Notes                                                      |
|-----------|-------------------|------------------------------------------------------------|
| en        | en-US             | English ships in the MMOSkillTree jar, not in this pack    |
| es        | es-ES             |                                                            |
| fr        | fr-FR             |                                                            |
| de        | de-DE             |                                                            |
| it        | it-IT             |                                                            |
| pt        | pt-BR             | Brazilian Portuguese; pt-PT clients fall back via Hytale   |
| ru        | ru-RU             |                                                            |
| hu        | hu-HU             |                                                            |
| tr        | tr-TR             |                                                            |

A third-party language pack contributing a new BCP 47 directory (e.g. `ko-KR`) will load and serve any player whose Hytale client reports that locale. The in-game picker on `/mmoconfig` lists MMOSkillTree's known set plus any server-side owner files - to make a novel language pickable, an admin creates a matching empty `messages-<iso>.json` owner file.

## Verification

1. Build the mod: `./gradlew build` from the parent directory (`..`).
2. Build the pack zip: `pwsh tools/build.ps1 install` (also copies to the local Hytale mods folder).
3. Start the Hytale server. Confirm in the server log:
   - `I18nModule` reports loading translations from the pack (typically logged at INFO with file counts per language).
   - No `LangFileParser` parse errors (those mean the `.lang` file has a malformed entry - usually a stray `=` in the value not wrapped in quotes).
4. In-game: open `/mmoconfig`, switch language to e.g. Italian, confirm UI updates and combat/skill text renders in Italian.
5. Edit a value in `mods/mmoskilltree/localization/messages-it.json` on the server, run `/mmoconfig reload`, confirm the owner-layer change applies live.
6. Remove a key from `it-IT/ui.lang`, repack, restart. Confirm Italian UI for that key renders the English string via the fallback chain.
