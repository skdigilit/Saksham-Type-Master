class_name EnemySpawner
extends Node2D
## Manages the timed spawning of ChordEnemy instances.
## Adjusts spawn rate and max enemies based on difficulty.

## Emitted when an enemy collides with the player
signal enemy_hit_player()

## Spawn timing
var spawn_interval: float = 4.0
var _spawn_timer: Timer = null

## Maximum number of active enemies at once (starts at theme value, escalates over time)
var max_active_enemies: int = GameTheme.ENEMY_MAX_COUNT_INITIAL

## How often (seconds) the max enemy count increases by 1 (from theme)
const ESCALATION_INTERVAL: float = GameTheme.ENEMY_ESCALATION_INTERVAL
var _escalation_timer: Timer = null

## Circle parameters for chord generation
var circle_center: Vector2 = GameTheme.CIRCLE_CENTER
var circle_radius: float = GameTheme.CIRCLE_RADIUS

## Reference to the player controller (set by GameManager)
var player: PlayerController = null

## Whether spawning is active
var is_active: bool = false

## Timer that controls how long the freeze effect lasts after the player collects a freeze pickup.
var _freeze_effect_timer: Timer = null

## True while all enemies are frozen by the freeze collectible.
var _is_freeze_active: bool = false


func _ready() -> void:
	## Create the spawn timer
	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = spawn_interval
	_spawn_timer.one_shot = false
	_spawn_timer.timeout.connect(_on_spawn_timer)
	add_child(_spawn_timer)

	## Create the escalation timer
	_escalation_timer = Timer.new()
	_escalation_timer.wait_time = ESCALATION_INTERVAL
	_escalation_timer.one_shot = false
	_escalation_timer.timeout.connect(_on_escalation_timer)
	add_child(_escalation_timer)

	## Create the freeze effect timer
	_freeze_effect_timer = Timer.new()
	_freeze_effect_timer.one_shot = true
	_freeze_effect_timer.timeout.connect(_on_freeze_effect_ended)
	add_child(_freeze_effect_timer)


## Increments the max enemy count by 1 every escalation interval.
func _on_escalation_timer() -> void:
	max_active_enemies += 1


## Starts the enemy spawning system.
func start_spawning() -> void:
	is_active = true
	_spawn_timer.start()
	_escalation_timer.start()


## Stops spawning and removes all active enemies.
func stop_spawning() -> void:
	is_active = false
	_spawn_timer.stop()
	_escalation_timer.stop()
	_end_freeze()
	_clear_all_enemies()


## Spawns a new chord enemy if under the active limit.
func _on_spawn_timer() -> void:
	if not is_active:
		return
	if _get_active_enemy_count() >= max_active_enemies:
		return

	var enemy := ChordEnemy.new()
	enemy.setup(circle_center, circle_radius)
	## If a freeze is currently active, the new enemy spawns frozen too
	if _is_freeze_active:
		enemy.set_frozen(true)
	add_child(enemy)


## Returns the number of enemies that still count toward the active cap.
## Enemies that have entered AND exited the circle no longer count,
## allowing a new spawn slot to open up as soon as they leave.
func _get_active_enemy_count() -> int:
	var count: int = 0
	for child in get_children():
		if child is ChordEnemy and not child.has_exited_circle:
			count += 1
	return count


## Removes all active ChordEnemy children.
func _clear_all_enemies() -> void:
	for child in get_children():
		if child is ChordEnemy:
			child.queue_free()


## Checks if any active enemy overlaps the player this frame using a swept segment test.
## The threshold is the sum of the enemy's visual radius and the player's cell half-size,
## so a hit registers exactly when the enemy circle visually overlaps the letter.
func check_player_collision(player_pixel_pos: Vector2) -> bool:
	## Combined radius: enemy background circle + padding fraction of one grid cell width.
	## Adjust ENEMY_HIT_PADDING in game_theme.gd to make collisions more or less forgiving.
	var hit_radius: float = GameTheme.ENEMY_BG_RADIUS + GameTheme.GRID_CELL_SIZE.x * GameTheme.ENEMY_HIT_PADDING

	for child in get_children():
		if not (child is ChordEnemy):
			continue

		## Swept test: find the closest point on the segment [prev → current] to the player.
		## This prevents fast enemies from tunneling through a cell between frames.
		var seg_start: Vector2 = child.prev_position
		var seg_end: Vector2 = child.position
		var closest: Vector2 = _closest_point_on_segment(seg_start, seg_end, player_pixel_pos)

		if closest.distance_to(player_pixel_pos) < hit_radius:
			return true

	return false


## Returns the closest point on the segment [a, b] to point p.
func _closest_point_on_segment(a: Vector2, b: Vector2, p: Vector2) -> Vector2:
	var ab: Vector2 = b - a
	var len_sq: float = ab.length_squared()
	if len_sq == 0.0:
		return a
	var t: float = clampf((p - a).dot(ab) / len_sq, 0.0, 1.0)
	return a + ab * t


## Adjusts spawn parameters based on difficulty level.
## Higher difficulty = faster spawns and more simultaneous enemies.
func set_difficulty(level: int) -> void:
	## Each difficulty adds enemies on top of the initial theme value
	var base: int = GameTheme.ENEMY_MAX_COUNT_INITIAL
	match level:
		0:  ## EASY
			spawn_interval = 4.0
			max_active_enemies = base
		1:  ## MEDIUM
			spawn_interval = 3.0
			max_active_enemies = base + 1
		2:  ## HARD
			spawn_interval = 2.0
			max_active_enemies = base + 2
		3:  ## HELL
			spawn_interval = 1.5
			max_active_enemies = base + 3

	if _spawn_timer:
		_spawn_timer.wait_time = spawn_interval


## Freezes all current enemies and starts the freeze effect timer.
func freeze_all_enemies(duration: float) -> void:
	_is_freeze_active = true
	for child in get_children():
		if child is ChordEnemy:
			child.set_frozen(true)
	_freeze_effect_timer.start(duration)


## Called when the freeze effect timer expires.
func _on_freeze_effect_ended() -> void:
	_end_freeze()


## Unfreezes all enemies and clears the freeze state.
func _end_freeze() -> void:
	_is_freeze_active = false
	if _freeze_effect_timer:
		_freeze_effect_timer.stop()
	for child in get_children():
		if child is ChordEnemy:
			child.set_frozen(false)


func refresh_layout() -> void:
	circle_center = GameTheme.CIRCLE_CENTER
	circle_radius = GameTheme.CIRCLE_RADIUS
	_clear_all_enemies()
