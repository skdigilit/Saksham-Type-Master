class_name CollectibleManager
extends Node
## Manages the spawning and collection of yellow target letters.
## Tracks collection progress and updates the circle's perimeter dots.

enum CollectibleType {
	REGULAR,
	LIFE,
}

## Emitted when a collectible is picked up.
signal collectible_collected(total: int, collectible_type: CollectibleType, world_position: Vector2)

## Emitted when all collectibles for the round are collected
signal all_collected()

## Reference to the letter grid (set by GameManager)
var grid: LetterGrid = null

## Reference to the game circle (set by GameManager)
var game_circle: GameCircle = null

## Reference to the player controller (set by GameManager)
var player: PlayerController = null

## Current collectible position in the grid (-1,-1 means none active)
var active_collectible_pos: Vector2i = Vector2i(-1, -1)

## Type of the currently active collectible.
var active_collectible_type: CollectibleType = CollectibleType.REGULAR

## Number of collectibles gathered so far
var collected_count: int = 0

## Total collectibles needed to complete the round (matches circle dot count)
var target_count: int = GameTheme.CIRCLE_DOT_COUNT

## Optional callback used by the game manager to disable life spawns when already full.
var can_spawn_life_collectible: Callable = Callable()

## Timer used to expire the temporary life collectible.
var _life_collectible_timer: Timer = null


## Sets up references and connects to player movement signal.
func initialize(p_grid: LetterGrid, p_circle: GameCircle, p_player: PlayerController) -> void:
	grid = p_grid
	game_circle = p_circle
	player = p_player
	player.moved_to.connect(_on_player_moved)

	if _life_collectible_timer == null:
		_life_collectible_timer = Timer.new()
		_life_collectible_timer.one_shot = true
		_life_collectible_timer.timeout.connect(_on_life_collectible_expired)
		add_child(_life_collectible_timer)


## Spawns a new collectible at a random cell that is not the player's current position.
func spawn_collectible() -> void:
	if grid == null:
		return

	var all_positions: Array[Vector2i] = GridHelpers.all_positions()
	var player_pos: Vector2i = Vector2i(player.current_row, player.current_col)

	## Any cell except the one the player is standing on
	var candidates: Array[Vector2i] = []
	for pos in all_positions:
		if pos != player_pos:
			candidates.append(pos)

	## Pick a random candidate
	if candidates.is_empty():
		return

	var chosen: Vector2i = candidates[randi() % candidates.size()]
	active_collectible_pos = chosen
	active_collectible_type = _choose_collectible_type()

	## Set the cell to collectible state
	var cell: LetterCell = grid.get_cell(chosen.x, chosen.y)
	if cell:
		if active_collectible_type == CollectibleType.LIFE:
			cell.set_state(LetterCell.CellState.LIFE_COLLECTIBLE)
			_life_collectible_timer.start(GameTheme.LIFE_COLLECTIBLE_DURATION)
		else:
			cell.set_state(LetterCell.CellState.COLLECTIBLE)
			_life_collectible_timer.stop()

	## Update the circle to show the next target dot
	if game_circle:
		game_circle.set_active_dot(collected_count)


## Called when the player moves to a new cell.
func _on_player_moved(row: int, col: int, _letter: String) -> void:
	if active_collectible_pos == Vector2i(row, col):
		_collect()


## Handles collecting the current collectible.
func _collect() -> void:
	var collected_cell: LetterCell = grid.get_cell(active_collectible_pos.x, active_collectible_pos.y)
	var collect_world_position: Vector2 = Vector2.ZERO
	if collected_cell:
		collect_world_position = collected_cell.global_position + GameTheme.GRID_CELL_SIZE * 0.5

	_life_collectible_timer.stop()

	if active_collectible_type == CollectibleType.REGULAR:
		collected_count += 1

		## Update circle dots
		if game_circle:
			game_circle.set_filled_dots(collected_count)

	## Clear the active collectible
	active_collectible_pos = Vector2i(-1, -1)
	var collected_type: CollectibleType = active_collectible_type
	active_collectible_type = CollectibleType.REGULAR

	collectible_collected.emit(collected_count, collected_type, collect_world_position)

	## Check if round is complete
	if collected_count >= target_count:
		all_collected.emit()
	else:
		## Spawn the next collectible
		spawn_collectible()


## Resets the collectible system for a new round.
func reset() -> void:
	collected_count = 0
	active_collectible_pos = Vector2i(-1, -1)
	active_collectible_type = CollectibleType.REGULAR
	if game_circle:
		game_circle.set_filled_dots(0)
		game_circle.set_active_dot(-1)
	if _life_collectible_timer:
		_life_collectible_timer.stop()


func _choose_collectible_type() -> CollectibleType:
	if can_spawn_life_collectible.is_valid() and can_spawn_life_collectible.call() and randf() <= GameTheme.LIFE_COLLECTIBLE_CHANCE:
		return CollectibleType.LIFE
	return CollectibleType.REGULAR


func _on_life_collectible_expired() -> void:
	if active_collectible_type != CollectibleType.LIFE:
		return

	var expired_cell: LetterCell = grid.get_cell(active_collectible_pos.x, active_collectible_pos.y)
	if expired_cell:
		expired_cell.set_state(LetterCell.CellState.NORMAL)

	active_collectible_pos = Vector2i(-1, -1)
	active_collectible_type = CollectibleType.REGULAR
	spawn_collectible()
