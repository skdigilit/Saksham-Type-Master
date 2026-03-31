class_name GridHelpers
## Static utility class for the letter grid inside the circle.
##
## Algorithm: A virtual grid of GRID_ROWS x GRID_COLS is overlaid on the circle
## (diameter x diameter). Cell size = diameter / grid dimension. A letter is placed
## in every cell whose center falls inside the circle. Font size = 0.8 * cell height.

## Which virtual grid cells are active (center inside circle)
## Stored as a 2D bool array: _active[row][col]
static var _active: Array[Array] = []

## Flat list of active (row, col) positions
static var _active_positions: Array[Vector2i] = []

## Total number of active cells
static var total_cells: int = 0

## Virtual grid dimensions (from theme)
static var grid_rows: int = 0
static var grid_cols: int = 0

static var _layout_computed: bool = false


## Computes the layout by overlaying a virtual grid on the circle.
## Cell size is derived from circle diameter / grid dimensions.
## Only cells whose center is inside the circle are active.
static func compute_layout() -> void:
	grid_rows = GameTheme.GRID_ROWS
	grid_cols = GameTheme.GRID_COLS
	var radius: float = GameTheme.CIRCLE_RADIUS

	## Effective grid area is the circle diameter scaled by (1 - padding fraction)
	var effective_size: float = radius * 2.0 * (1.0 - GameTheme.LETTER_GRID_PADDING)

	## Compute cell size from the padded effective area
	var cell_w: float = effective_size / float(grid_cols)
	var cell_h: float = effective_size / float(grid_rows)
	GameTheme.GRID_CELL_SIZE = Vector2(cell_w, cell_h)

	## Derive grid font size as 0.8 * cell height
	GameTheme.FONT_SIZE_GRID = int(cell_h * GameTheme.GRID_CELL_FONT_RATIO)

	## Build the active cell map.
	## The virtual grid is centered on the circle — its top-left corner is at
	## (-effective_size/2, -effective_size/2) relative to the circle center.
	_active.clear()
	_active_positions.clear()
	total_cells = 0

	var half: float = effective_size * 0.5

	for row in range(grid_rows):
		var row_active: Array[bool] = []
		for col in range(grid_cols):
			## Cell center in local coordinates relative to circle center
			var cx: float = (col + 0.5) * cell_w - half
			var cy: float = (row + 0.5) * cell_h - half

			## Check if cell center is inside the circle
			var inside: bool = (cx * cx + cy * cy) <= (radius * radius)
			row_active.append(inside)

			if inside:
				_active_positions.append(Vector2i(row, col))
				total_cells += 1

		_active.append(row_active)

	_layout_computed = true


## Ensures the layout has been computed.
static func _ensure_layout() -> void:
	if not _layout_computed:
		compute_layout()


## Returns true if the cell at (row, col) is active (inside the circle).
static func is_valid_cell(row: int, col: int) -> bool:
	_ensure_layout()
	if row < 0 or row >= grid_rows:
		return false
	if col < 0 or col >= grid_cols:
		return false
	return _active[row][col]


## Returns all valid neighbor positions (cardinal + diagonals) for a given cell.
## Only returns neighbors that are active (inside the circle).
static func get_neighbors(row: int, col: int) -> Array[Vector2i]:
	_ensure_layout()
	var neighbors: Array[Vector2i] = []

	## All 8 directions: left, right, up, down, and 4 diagonals
	var offsets: Array[Vector2i] = [
		Vector2i(0, -1), Vector2i(0, 1),   ## left, right
		Vector2i(-1, 0), Vector2i(1, 0),   ## up, down
		Vector2i(-1, -1), Vector2i(-1, 1), ## up-left, up-right
		Vector2i(1, -1), Vector2i(1, 1),   ## down-left, down-right
	]

	for offset in offsets:
		var nr: int = row + offset.x
		var nc: int = col + offset.y
		if is_valid_cell(nr, nc):
			neighbors.append(Vector2i(nr, nc))

	return neighbors


## Returns true if two cells are adjacent in the grid.
static func are_neighbors(row_a: int, col_a: int, row_b: int, col_b: int) -> bool:
	var dr: int = absi(row_a - row_b)
	var dc: int = absi(col_a - col_b)
	return dr <= 1 and dc <= 1 and (dr + dc) > 0


## Calculates the pixel position for a cell center, relative to the circle center.
## The virtual grid is centered within the padded effective area.
static func cell_position(row: int, col: int, center: Vector2, cell_size: Vector2) -> Vector2:
	_ensure_layout()
	var half: float = GameTheme.CIRCLE_RADIUS * (1.0 - GameTheme.LETTER_GRID_PADDING)

	## Cell center in local coords (top-left of padded grid is at -half, -half)
	var x: float = center.x + (col + 0.5) * cell_size.x - half
	var y: float = center.y + (row + 0.5) * cell_size.y - half

	return Vector2(x, y)


## Returns a flat array of all active (row, col) positions in the grid.
static func all_positions() -> Array[Vector2i]:
	_ensure_layout()
	return _active_positions.duplicate()


## BFS from (start_row, start_col) across active cells.
## Returns a Dictionary mapping Vector2i -> int (minimum keystrokes to reach each cell).
static func bfs_distances(start_row: int, start_col: int) -> Dictionary:
	_ensure_layout()
	var dist: Dictionary = {}
	var queue: Array[Vector2i] = []
	var start: Vector2i = Vector2i(start_row, start_col)
	dist[start] = 0
	queue.append(start)
	var head: int = 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		var neighbors: Array[Vector2i] = get_neighbors(current.x, current.y)
		for n in neighbors:
			if not dist.has(n):
				dist[n] = dist[current] + 1
				queue.append(n)
	return dist


## Returns the center row and column indices (for player starting position).
static func center_position() -> Vector2i:
	_ensure_layout()
	return Vector2i(grid_rows / 2, grid_cols / 2)
