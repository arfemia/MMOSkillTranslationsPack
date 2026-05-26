# MMO Skill Translations Pack

Community translations for the **MMO Skill Tree** mod — Spanish, French, German, Italian, Portuguese, Russian, Hungarian, Turkish.

## What is it?

The MMO Skill Tree mod ships with English by default. This pack adds 8 more languages.

Players pick their language via the in-game settings menu, and every UI page, skill name, ability tooltip, quest, achievement, mastery node, command output, and notification message gets translated.

## Why is this a separate pack?

So the community can contribute.

The translations live in plain JSON files. Anyone can fork the [GitHub repo](https://github.com/...), edit a value, and open a pull request. Adding a brand-new language is as simple as dropping a new JSON file in.

The main mod stays small and English-only; this pack carries the translation work that benefits from many eyes.

## Install

1. Download `MMOSkillTranslationsPack.zip` from this page.
2. Place it in your Hytale server's `Mods/` folder alongside the `MMOSkillTree` jar.
3. Restart the server.

Players can then switch languages in-game.

## Server admin tips

- On first load, the mod writes a per-language file to `mods/mmoskilltree/localization/messages-<code>.json` on your server. Edit those files to customize translations for your server — your edits take priority over the pack content.
- Run `/mmoconfig reload` after editing the files to pick up changes without a restart.
- If you uninstall this pack, the per-language files keep working (snapshot of pack content). Re-install or replace the pack to update.

## Languages shipped

Spanish · French · German · Italian · Portuguese · Russian · Hungarian · Turkish.

Want a new language? See the GitHub repo for the contributor guide.

## Requires

- MMO Skill Tree v1.1.7 or later.
- Hytale Update 5 (server `0.5.x`).
