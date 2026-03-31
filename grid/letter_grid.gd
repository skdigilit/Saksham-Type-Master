class_name LetterGrid
extends Control
## Manages the grid of LetterCell instances inside the circle.
## Uses the virtual grid overlay algorithm from GridHelpers.

## 2D sparse array of LetterCell nodes: cells[row][col]
## null for cells outside the circle
var cells: Array[Array] = []


func _ready() -> void:
	## Compute the grid layout (cell sizes, active cells)
	GridHelpers.compute_layout()
	_generate_grid()


## How much each letter is randomly nudged left or right from its grid position,
## as a fraction of the cell width. 0.07 = up to 7% of the cell width in each direction.
## Increase for a messier, more handwritten look; set to 0 for a perfectly straight grid.
const STAGGER_FRACTION_X: float = 0.07

## How much each letter is randomly nudged up or down from its grid position,
## as a fraction of the cell height. Higher than X so the vertical scatter is more noticeable.
## Increase for more vertical randomness; set to 0 for perfectly level rows.
const STAGGER_FRACTION_Y: float = 0.15


## Creates LetterCell instances for every active cell in the virtual grid.
func _generate_grid() -> void:
	var letters: Array[String] = _generate_letters()
	var letter_index: int = 0

	for row in range(GridHelpers.grid_rows):
		var row_cells: Array = []
		row_cells.resize(GridHelpers.grid_cols)

		for col in range(GridHelpers.grid_cols):
			if not GridHelpers.is_valid_cell(row, col):
				row_cells[col] = null
				continue

			var cell := LetterCell.new()
			cell.setup(letters[letter_index], row, col)
			letter_index += 1

			## Position the cell centered around the circle center
			var pos: Vector2 = GridHelpers.cell_position(
				row, col, GameTheme.CIRCLE_CENTER, GameTheme.GRID_CELL_SIZE
			)

			## Apply a random stagger within a fraction of the cell size
			var stagger: Vector2 = Vector2(
				randf_range(-GameTheme.GRID_CELL_SIZE.x * STAGGER_FRACTION_X, GameTheme.GRID_CELL_SIZE.x * STAGGER_FRACTION_X),
				randf_range(-GameTheme.GRID_CELL_SIZE.y * STAGGER_FRACTION_Y, GameTheme.GRID_CELL_SIZE.y * STAGGER_FRACTION_Y)
			)

			cell.position = pos - GameTheme.GRID_CELL_SIZE * 0.5 + stagger
			add_child(cell)
			row_cells[col] = cell

		cells.append(row_cells)


## Generates unique letters ensuring no two adjacent cells share the same letter
## and no cell has duplicate letters among its neighbors (for unambiguous input).
func _generate_letters() -> Array[String]:
	var all_positions: Array[Vector2i] = GridHelpers.all_positions()
	var result: Array[String] = []
	result.resize(GridHelpers.total_cells)

	## Fill with empty strings initially
	for i in range(GridHelpers.total_cells):
		result[i] = ""

	## Try to assign letters with constraint satisfaction
	var alphabet: Array[String] = []
	for i in range(26):
		alphabet.append(char(65 + i))  ## A-Z

	var position_index: int = 0
	for pos in all_positions:
		var forbidden: Array[String] = _get_neighborhood_letters(pos, all_positions, result)

		## Build list of allowed letters
		var allowed: Array[String] = []
		for ch in alphabet:
			if ch not in forbidden:
				allowed.append(ch)

		## Pick a random allowed letter
		if allowed.size() > 0:
			result[position_index] = allowed[randi() % allowed.size()]
		else:
			## Fallback: pick any letter (very unlikely with 26 letters and max 8 neighbors)
			result[position_index] = alphabet[randi() % alphabet.size()]

		position_index += 1

	return result


## Collects all letters already assigned to neighbors and neighbors-of-neighbors
## to ensure typing a letter is unambiguous from any adjacent cell.
func _get_neighborhood_letters(
	pos: Vector2i,
	all_positions: Array[Vector2i],
	current_letters: Array[String]
) -> Array[String]:
	var forbidden: Array[String] = []
	var neighbors: Array[Vector2i] = GridHelpers.get_neighbors(pos.x, pos.y)

	## Forbid letters of direct neighbors
	for n in neighbors:
		var idx: int = _pos_to_index(n, all_positions)
		if idx >= 0 and current_letters[idx] != "":
			if current_letters[idx] not in forbidden:
				forbidden.append(current_letters[idx])

		## Also forbid letters of neighbor's other neighbors (sibling check)
		## This ensures that from any cell, each adjacent letter is unique
		var sibling_neighbors: Array[Vector2i] = GridHelpers.get_neighbors(n.x, n.y)
		for sn in sibling_neighbors:
			var sn_idx: int = _pos_to_index(sn, all_positions)
			if sn_idx >= 0 and current_letters[sn_idx] != "":
				if current_letters[sn_idx] not in forbidden:
					forbidden.append(current_letters[sn_idx])

	return forbidden


## Converts a Vector2i position to its flat index in the all_positions array.
func _pos_to_index(pos: Vector2i, all_positions: Array[Vector2i]) -> int:
	for i in range(all_positions.size()):
		if all_positions[i] == pos:
			return i
	return -1


## Returns the LetterCell at the given grid position, or null if inactive.
func get_cell(row: int, col: int) -> LetterCell:
	if row >= 0 and row < cells.size() and col >= 0 and col < cells[row].size():
		return cells[row][col]
	return null


## Returns all grid positions containing the given letter.
func find_cells_by_letter(letter: String) -> Array[Vector2i]:
	var matches: Array[Vector2i] = []
	for pos in GridHelpers.all_positions():
		var cell: LetterCell = get_cell(pos.x, pos.y)
		if cell and cell.get_letter() == letter:
			matches.append(pos)
	return matches


## Returns the letters adjacent to the given cell position.
func get_adjacent_letters(row: int, col: int) -> Array[String]:
	var result: Array[String] = []
	var neighbors: Array[Vector2i] = GridHelpers.get_neighbors(row, col)
	for n in neighbors:
		var cell: LetterCell = get_cell(n.x, n.y)
		if cell:
			result.append(cell.get_letter())
	return result


## Tweens every cell's modulate alpha to the given target value.
## Used on game over to dim all letters simultaneously.
func fade_out(target_alpha: float, duration: float = 0.8) -> void:
	for pos in GridHelpers.all_positions():
		var cell: LetterCell = get_cell(pos.x, pos.y)
		if cell:
			var tween: Tween = cell.create_tween()
			tween.tween_property(cell, "modulate:a", target_alpha, duration)


## Reshuffles all letters in the grid while maintaining adjacency constraints.
func randomize_grid() -> void:
	var new_letters: Array[String] = _generate_letters()
	var all_positions: Array[Vector2i] = GridHelpers.all_positions()
	for i in range(all_positions.size()):
		var pos: Vector2i = all_positions[i]
		var cell: LetterCell = get_cell(pos.x, pos.y)
		if cell:
			cell.set_letter(new_letters[i])
