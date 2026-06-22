# CLAUDE.md - MMOSkillTranslationsPack

> **DEPRECATED — not maintained.** This pack was never published. All MMOSkillTree translations (all 9 languages) now ship bundled inside the mod jar at `Server/Languages/<bcp47>/mmoskilltree.lang`. Do not add or edit translations here; edit the jar's `.lang` files in the main MMOSkillTree repo. This working tree is kept for reference only.

This directory is a standalone Hytale content pack that ships translations for the [MMOSkillTree mod](https://www.curseforge.com/hytale/mods/mmo-skill-tree). Translations live as standard Hytale `.lang` files; the mod's jar does not ship any non-English language defaults beyond `EnglishDefaults.java`.

The pack is consumed natively by Hytale's `I18nModule` (`com.hypixel.hytale.server.core.modules.i18n.I18nModule`). No MMOSkillTree-specific asset type or custom merge handler is involved. The mod's `LocalizationConfig.lookupViaI18n` prepends a `"mmoskilltree."` prefix at the lookup boundary, which mirrors the prefix Hytale's loader prepends from the `mmoskilltree.lang` filename.

## Layout

```
skill-translations-pack/
├── manifest.json                                  Hytale plugin manifest
├── CLAUDE.md                                      this file
├── README.md                                      public-facing contributor guide
├── CURSEFORGE.md                                  CurseForge listing copy
├── LICENSE                                        MIT
├── MMOSkillTranslationsPack.zip                   built artifact (gitignored if you regenerate)
├── build.ps1                                      rebuild the zip
└── Server/
    └── Languages/                                 Hytale-native i18n path
        ├── es-ES/mmoskilltree.lang
        ├── fr-FR/mmoskilltree.lang
        ├── de-DE/mmoskilltree.lang
        ├── it-IT/mmoskilltree.lang
        ├── pt-BR/mmoskilltree.lang
        ├── ru-RU/mmoskilltree.lang
        ├── hu-HU/mmoskilltree.lang
        └── tr-TR/mmoskilltree.lang
```

One `mmoskilltree.lang` per locale.

## Build & deploy

Same pattern as `../skill-mastery-pack/` plus one extra requirement: explicit directory entries inside the zip. Hytale's `I18nModule.loadMessagesFromPack` gates on `Files.isDirectory(pack.getRoot()/Server/Languages)`, and Java's `ZipFileSystem` returns `false` for that check when the zip has only file entries. The build script emits a directory entry for every ancestor path before writing each file.

```powershell
.\build.ps1                  # rebuild the zip, and install it if a Mods folder is known
.\build.ps1 -Install:$false  # rebuild only, no copy
```

`build.ps1` is self-locating and cross-platform (Windows PowerShell, or `pwsh ./build.ps1` on macOS/Linux). To auto-install on build, set `HYTALE_MODS_DIR` once to your Hytale `UserData/Mods` folder (or pass `-ModsDir <path>`); without it the script just builds the zip. Top-level docs (`CLAUDE.md`, `README.md`, `CURSEFORGE.md`), `LICENSE`, `.gitignore`, and `manifest.json` are excluded from the zip.

## `.lang` file conventions

### Path

`Server/Languages/<bcp47>/mmoskilltree.lang`. The directory name is the BCP 47 locale code (`it-IT`, not `it`). One file per locale.

### Why `mmoskilltree.lang` (not `messages.lang` or split by namespace)

Hytale's `I18nModule.loadMessagesFrom` does this (read `loadMessagesFrom` / `getPrefix` in `hytale-shared-source/HytaleServer/CoreServer/src/main/java/com/hypixel/hytale/server/core/modules/i18n/I18nModule.java`):

```java
String prefix = name.substring(0, name.length() - ".lang".length());  // filename minus .lang
String storedKey = prefix + "." + entryKey;  // every key in the file gets the prefix prepended
```

So a file named `ui.lang` containing `settings.title = ...` makes Hytale store the key as `ui.settings.title`. A file named `messages.lang` containing `ui.settings.title = ...` would store it as `messages.ui.settings.title` (double-prefixed).

The mod's `LocalizationConfig.lookupViaI18n` prepends a constant `"mmoskilltree."` to every lookup:

```java
private static final String I18N_KEY_PREFIX = "mmoskilltree.";
String prefixedKey = I18N_KEY_PREFIX + key;
i18n.getMessage(bcp47, prefixedKey);
```

By naming each file `mmoskilltree.lang`, Hytale stores keys as `mmoskilltree.<original-key>`, which is exactly what `lookupViaI18n` asks for. Contributors write bare keys (`ui.settings.title`) inside the file; the prefix is invisible to them.

Splitting one locale across multiple sibling `.lang` files would give each file a different filename-prefix and break the lookup. One file per locale is the supported shape.

### Format

```
# Comment lines start with #
key = value
key.with.dots = Another value
quoted = "leading and trailing whitespace preserved"
multiline = first part \
continued on the next line
escapes = newline becomes \n and tab becomes \t
```

UTF-8 encoded, no BOM. Built and saved by PowerShell's `[System.Text.UTF8Encoding]::new($false)`.

### Empty values are rejected

Hytale's `LangFileParser` throws `TranslationParseException` on any line whose value is empty (`key = `). One bad line aborts the whole file. Omit a key entirely (so it falls through to English) instead of shipping an empty string.

### Placeholders

MMOSkillTree uses positional placeholders (`{0}`, `{1}`, ...) that `Messages.get(skills, key, args...)` substitutes after the lookup. Keep them verbatim in translations; `LangFileParser` treats them as opaque value text.

## Three-layer precedence (admin > pack > English)

MMOSkillTree's `LocalizationConfig.get(langCode, key)` walks:

1. **Owner override** — `mods/mmoskilltree/localization/messages-<iso>.json` on the server. Highest priority. Admin per-server customization.
2. **`I18nModule.getMessage(bcp47, "mmoskilltree." + key)`** — every `.lang` file Hytale found, including the JAR-bundled English in MMOSkillTree's own jar (`src/main/resources/Server/Languages/en-US/mmoskilltree.lang`).
3. **`I18nModule.getMessage("en-US", "mmoskilltree." + key)`** — per-key fallback to English via Hytale's own pipeline.
4. **`EnglishDefaults.java`** in-code map — last-resort safety net for very early plugin startup before `I18nModule` finishes loading packs.
5. Empty string if nothing matched.

Empty-string values from owner files DO suppress fallback (they're treated as deliberate overrides). To fall back to English, omit the key from your owner file entirely.

## Sync with the mod

When MMOSkillTree adds new i18n keys, those keys land in `EnglishDefaults.java`. The mod's JAR-bundled `mmoskilltree.lang` regenerates from that file via `EnglishLangExportTest` (gated, disabled by default — see the mod's `.claude/skills/localization/SKILL.md`). Pack languages won't have the new keys until this pack is updated; until then, players see English for the new keys via the fallback chain. Graceful degradation, no crashes.

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

A third-party pack contributing a new BCP 47 directory (e.g. `ko-KR`) will load and serve any player whose Hytale client reports that locale. The in-game picker on `/mmoconfig` lists MMOSkillTree's known set plus any server-side admin owner files; to make a novel language pickable, an admin creates a matching empty `messages-<iso>.json` owner file.

## Verification

1. Build the mod: `./gradlew build` from the monorepo root, two levels up (`../../`).
2. Build the pack zip: `.\build.ps1` (also copies to the local Hytale mods folder when `HYTALE_MODS_DIR` is set; pass `-Install:$false` to build only).
3. Start the Hytale server. In the server log, look for one line per locale:
   ```
   [I18nModule|P] Loaded N entries for 'it-IT' from /Server/Languages
   ```
   Absence of these lines means `Files.isDirectory(pack.getRoot()/Server/Languages)` returned false (zip missing directory entries) and the whole pack was silently skipped.
4. In-game: open `/mmoconfig`, switch language to e.g. Italian, confirm UI updates and combat/skill text renders in Italian.
5. Edit a value in `mods/mmoskilltree/localization/messages-it.json` on the server, run `/mmoconfig reload`, confirm the owner-layer change applies live.
6. Remove a key from `it-IT/mmoskilltree.lang`, repack, restart. Confirm Italian UI for that key renders the English string via the fallback chain.
