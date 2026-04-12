# Journal

## 2025-04-12 — Freeze Collectible

Added a new **freeze collectible** that pauses all enemies for a configurable duration when collected. Ice-blue letter appears on the grid with a ~15% spawn chance. On collection, all active `ChordEnemy` instances freeze in place (movement halted, sprite tinted ice-blue) for `FREEZE_EFFECT_DURATION` seconds. Enemies spawned during an active freeze also start frozen. The collectible expires from the board after `FREEZE_COLLECTIBLE_DURATION` seconds if not collected.

**Files changed:**
- `theme/game_theme.gd` — new colour and timing constants
- `grid/letter_cell.gd` — `FREEZE_COLLECTIBLE` cell state and visual handling
- `collectibles/collectible_manager.gd` — `FREEZE` enum value, spawn/timer/expiry logic
- `enemies/chord_enemy.gd` — `is_frozen` flag and `set_frozen()` method
- `enemies/enemy_spawner.gd` — `freeze_all_enemies()`, `_end_freeze()`, freeze effect timer
- `managers/game_manager.gd` — route freeze collectible to enemy spawner
