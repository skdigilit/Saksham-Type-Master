class_name CollectibleManager
extends Node
## Manages the spawning and collection of yellow target letters.
## Tracks collection progress and updates the circle's perimeter dots.

## Emitted when a collectible is picked up, with the new total count
signal collectible_collected(total: int)

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

## Number of collectibles gathered so far
var collected_count: int = 0

## Total collectibles needed to complete the round (matches circle dot count)
var target_count: int = GameTheme.CIRCLE_DOT_COUNT


## Sets up references and connects to player movement signal.
func initialize(p_grid: LetterGrid, p_circle: GameCircle, p_player: PlayerController) -> void:
	grid = p_grid
	game_circle = p_circle
	player = p_player
	player.moved_to.connect(_on_player_moved)


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

	## Set the cell to collectible state
	var cell: LetterCell = grid.get_cell(chosen.x, chosen.y)
	if cell:
		cell.set_state(LetterCell.CellState.COLLECTIBLE)

	## Update the circle to show the next target dot
	if game_circle:
		game_circle.set_active_dot(collected_count)


## Called when the player moves to a new cell.
func _on_player_moved(row: int, col: int, _letter: String) -> void:
	if active_collectible_pos == Vector2i(row, col):
		_collect()


## Handles collecting the current collectible.
func _collect() -> void:
	collected_count += 1

	## Update circle dots
	if game_circle:
		game_circle.set_filled_dots(collected_count)

	## Clear the active collectible
	active_collectible_pos = Vector2i(-1, -1)

	collectible_collected.emit(collected_count)

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
	if game_circle:
		game_circle.set_filled_dots(0)
		game_circle.set_active_dot(-1)
