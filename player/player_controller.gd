class_name PlayerController
extends Node
## Handles keyboard input for navigating the letter grid.
## The player types an adjacent letter to move to that cell.

## Emitted when the player successfully moves to a new cell
signal moved_to(row: int, col: int, letter: String)

## Emitted when the player types a letter that isn't adjacent
signal invalid_move(typed_letter: String)

## Current position in the grid
var current_row: int = 2
var current_col: int = 2

## Reference to the letter grid (set by GameManager)
var grid: LetterGrid = null

## Whether input is currently accepted
var is_input_enabled: bool = true


## Highlights the starting cell when the game begins.
## Defaults to the center of the dynamically computed grid.
func initialize(p_grid: LetterGrid, start_row: int = -1, start_col: int = -1) -> void:
	grid = p_grid
	if start_row < 0 or start_col < 0:
		var center_pos: Vector2i = GridHelpers.center_position()
		current_row = center_pos.x
		current_col = center_pos.y
	else:
		current_row = start_row
		current_col = start_col
	_update_highlight()


func _unhandled_input(event: InputEvent) -> void:
	if not is_input_enabled:
		return
	if grid == null:
		return
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return

	## Convert keycode to uppercase letter
	var keycode: int = event.keycode
	if keycode < KEY_A or keycode > KEY_Z:
		return

	var typed_letter: String = char(keycode)
	_try_move(typed_letter)
	get_viewport().set_input_as_handled()


## Attempts to move to an adjacent cell matching the typed letter.
func _try_move(letter: String) -> void:
	var neighbors: Array[Vector2i] = GridHelpers.get_neighbors(current_row, current_col)

	## Find the neighbor that has the typed letter
	for n in neighbors:
		var cell: LetterCell = grid.get_cell(n.x, n.y)
		if cell and cell.get_letter() == letter:
			## Clear old highlight
			var old_cell: LetterCell = grid.get_cell(current_row, current_col)
			if old_cell:
				old_cell.set_state(LetterCell.CellState.NORMAL)

			## Move to new cell
			current_row = n.x
			current_col = n.y
			_update_highlight()
			moved_to.emit(current_row, current_col, letter)
			return

	## No matching adjacent cell found
	invalid_move.emit(letter)


## Highlights the player's current cell.
func _update_highlight() -> void:
	var cell: LetterCell = grid.get_cell(current_row, current_col)
	if cell:
		cell.set_state(LetterCell.CellState.HIGHLIGHTED)


## Returns the pixel position of the player's current cell center.
func get_current_pixel_position() -> Vector2:
	return GridHelpers.cell_position(
		current_row, current_col,
		GameTheme.CIRCLE_CENTER, GameTheme.GRID_CELL_SIZE
	)


## Programmatically sets the player's position (for resets).
func set_position_in_grid(row: int, col: int) -> void:
	## Clear old highlight
	var old_cell: LetterCell = grid.get_cell(current_row, current_col)
	if old_cell:
		old_cell.set_state(LetterCell.CellState.NORMAL)

	current_row = row
	current_col = col
	_update_highlight()
