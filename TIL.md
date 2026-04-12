# TIL

- In Godot 4, `Timer.one_shot = true` makes the timer fire once and stop, which is ideal for temporary power-up effects like the freeze collectible duration.
- Setting `is_frozen` on a `Node2D` and returning early from `_process` is a clean way to pause individual entity movement without affecting the rest of the scene tree.
- Enemies spawned *during* an active freeze should also be frozen — handle this at spawn time in the spawner, not just when the effect starts.
