# MMO Skill Translations Pack

> **DEPRECATED - not maintained.** This pack was never published. All MMOSkillTree translations (all 9 languages) ship bundled inside the mod jar at `Server/Languages/<bcp47>/mmoskilltree.lang`. Do not add or edit translations here; edit the jar's `.lang` files in the main MMOSkillTree repo. This working tree is kept for reference only.

Community translations for the **MMO Skill Tree** mod - Spanish, French, German, Italian, Portuguese, Russian, Hungarian, Turkish.

## What is it?

The MMO Skill Tree mod ships with English by default. This pack adds 8 more languages, delivered as standard Hytale `.lang` files at `Server/Languages/<locale>/`.

Players pick their language via the in-game settings menu, and every UI page, skill name, ability tooltip, quest, achievement, mastery node, command output, and notification message gets translated.

## Why is this a separate pack?

So the community can contribute.

The translations live in plain `.lang` files, Hytale's standard localization format. Anyone can fork the [GitHub repo](https://github.com/arfemia/MMOSkillTranslationsPack), edit a value, and open a pull request. Adding a brand-new language is as simple as dropping a new directory of `.lang` files in.

The main mod stays small and English-only; this pack carries the translation work that benefits from many eyes.

## Install

1. Download `MMOSkillTranslationsPack.zip` from this page.
2. Place it in your Hytale server's `Mods/` folder alongside the `MMOSkillTree` jar.
3. Restart the server.

Players can then switch languages in-game.

## Server admin tips

- To customize translations for your specific server, drop a `messages-<iso>.json` file at `mods/mmoskilltree/localization/` (e.g. `messages-it.json` for Italian). Your overrides win over the pack content.
- Run `/mmoconfig reload` after editing the owner files to pick up changes without a restart.
- If a key is missing in your translation, it falls back to English via Hytale's own pipeline. No crashes, just a readable default.

## Languages shipped

Spanish (es-ES), French (fr-FR), German (de-DE), Italian (it-IT), Portuguese (pt-BR), Russian (ru-RU), Hungarian (hu-HU), Turkish (tr-TR).

Want a new language? See the GitHub repo for the contributor guide.

## Requires

Nothing anymore: this pack is deprecated and was never published. Every translation it describes ships inside the MMO Skill Tree jar itself.
