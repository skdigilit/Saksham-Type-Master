class_name LetterCell
extends Control
## Represents a single letter in the diamond grid.
## Manages its own visual state: normal, highlighted, collectible, or empty.

enum CellState {
	NORMAL,       ## Default dark letter
	HIGHLIGHTED,  ## Player's current position (bright text + background)
	COLLECTIBLE,  ## Yellow letter the player must collect
	EMPTY,        ## Faded / inactive cell
	DEAD,         ## Player was killed here — red letter
}

## The uppercase letter displayed by this cell
var letter: String = ""

## Position within the diamond grid
var grid_row: int = 0
var grid_col: int = 0

## Current visual state
var cell_state: CellState = CellState.NORMAL

## When true the letter turns red because an enemy is physically passing over it.
## Automatically set and cleared by GameManager each frame.
## Does not affect HIGHLIGHTED or DEAD cells — only NORMAL and COLLECTIBLE ones.
var is_scorched: bool = false

## Child nodes created in setup
var _letter_label: Label = null

## Internal timer that increases every frame to drive the swinging animation.
var _swing_time: float = 0.0

## A random starting offset for each letter's swing so they all sway at different moments,
## like leaves on a tree rather than soldiers marching in sync.
var _swing_phase: float = 0.0

## How far left and right each letter tilts when it swings (in radians).
## 0.1 radians ≈ 6 degrees. Increase for a more dramatic tilt; decrease for a subtle sway.
const SWING_AMPLITUDE: float = 0.1

## How quickly each letter swings back and forth (cycles per second).
## Higher = faster, more energetic swinging; lower = slow, gentle rocking.
const SWING_SPEED: float = 1.8

## How much bigger the active (player's current) letter appears compared to normal.
## 1.2 means 20% larger. Increase to make the player's position even more obvious.
const HIGHLIGHT_SCALE: float = 1.2

## Cached LabelSettings for each state
var _settings_normal: LabelSettings = null
var _settings_highlighted: LabelSettings = null
var _settings_collectible: LabelSettings = null
var _settings_empty: LabelSettings = null
var _settings_dead: LabelSettings = null
var _settings_scorched: LabelSettings = null


## Initializes the cell with its letter, grid position, and builds child nodes.
func setup(p_letter: String, p_row: int, p_col: int) -> void:
	letter = p_letter
	grid_row = p_row
	grid_col = p_col

	## Set the cell size so children can anchor properly
	custom_minimum_size = GameTheme.GRID_CELL_SIZE
	size = GameTheme.GRID_CELL_SIZE

	## Random phase so each letter swings independently
	_swing_phase = randf() * TAU

	_create_label_settings()
	_create_children()
	_apply_visual_state()
	if GameTheme.DEBUG_COLLISION:
		queue_redraw()


## Creates LabelSettings for each cell state.
func _create_label_settings() -> void:
	_settings_normal = GameTheme.create_label_settings(
		GameTheme.COLOR_LETTER_NORMAL,
		GameTheme.FONT_SIZE_GRID,
		GameTheme.COLOR_LETTER_OUTLINE,
		GameTheme.FONT_SIZE_GRID_OUTLINE
	)
	_settings_highlighted = GameTheme.create_label_settings(
		GameTheme.COLOR_LETTER_HIGHLIGHT_TEXT,
		GameTheme.FONT_SIZE_GRID,
		GameTheme.COLOR_CIRCLE_OUTLINE,
		GameTheme.FONT_SIZE_GRID_OUTLINE + 6
	)
	_settings_collectible = GameTheme.create_label_settings(
		GameTheme.COLOR_LETTER_COLLECTIBLE,
		GameTheme.FONT_SIZE_GRID,
		GameTheme.COLOR_CIRCLE_OUTLINE,
		GameTheme.FONT_SIZE_GRID_OUTLINE + 1
	)
	_settings_empty = GameTheme.create_label_settings(
		GameTheme.COLOR_LETTER_NORMAL.lerp(GameTheme.COLOR_CIRCLE_INTERIOR, 0.6),
		GameTheme.FONT_SIZE_GRID,
		Color.TRANSPARENT,
		0
	)
	_settings_dead = GameTheme.create_label_settings(
		GameTheme.COLOR_ENEMY,
		GameTheme.FONT_SIZE_GRID,
		GameTheme.COLOR_CIRCLE_OUTLINE,
		GameTheme.FONT_SIZE_GRID_OUTLINE + 2
	)
	## Scorched: same red as dead but normal scale — used when an enemy passes over this letter
	_settings_scorched = GameTheme.create_label_settings(
		GameTheme.COLOR_ENEMY,
		GameTheme.FONT_SIZE_GRID,
		GameTheme.COLOR_CIRCLE_OUTLINE,
		GameTheme.FONT_SIZE_GRID_OUTLINE
	)


## Builds the letter label as a child node.
func _create_children() -> void:
	## The letter label itself
	_letter_label = Label.new()
	_letter_label.text = letter
	_letter_label.label_settings = _settings_normal
	_letter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_letter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_letter_label.size = GameTheme.GRID_CELL_SIZE
	add_child(_letter_label)

	## Apply squiggle shader to the label for hand-drawn wobble
	GameTheme.apply_squiggle_shader(_letter_label, GameTheme.SQUIGGLE_STRENGTH_NORMAL)


## Animates a subtle swinging rotation each frame.
func _process(delta: float) -> void:
	_swing_time += delta
	var angle: float = sin(_swing_time * SWING_SPEED + _swing_phase) * SWING_AMPLITUDE
	if _letter_label:
		_letter_label.rotation = angle
		## Keep the label pivoted around its center
		_letter_label.pivot_offset = GameTheme.GRID_CELL_SIZE * 0.5


## Changes the cell's visual state and updates appearance.
func set_state(new_state: CellState) -> void:
	cell_state = new_state
	_apply_visual_state()


## Called by GameManager every frame to mark this cell as being covered by an enemy.
## Only affects NORMAL and COLLECTIBLE cells — the player's position and dead state are untouched.
func set_scorched(value: bool) -> void:
	if is_scorched == value:
		return
	is_scorched = value
	_apply_visual_state()
	if GameTheme.DEBUG_COLLISION:
		queue_redraw()


## Updates child node visuals based on the current cell_state and scorch flag.
## Scorch only applies to NORMAL and COLLECTIBLE — it never overrides HIGHLIGHTED or DEAD.
func _apply_visual_state() -> void:
	if _letter_label == null:
		return

	match cell_state:
		CellState.NORMAL:
			_letter_label.label_settings = _settings_scorched if is_scorched else _settings_normal
			_letter_label.scale = Vector2.ONE
		CellState.HIGHLIGHTED:
			_letter_label.label_settings = _settings_highlighted
			_letter_label.scale = Vector2(HIGHLIGHT_SCALE, HIGHLIGHT_SCALE)
		CellState.COLLECTIBLE:
			_letter_label.label_settings = _settings_scorched if is_scorched else _settings_collectible
			_letter_label.scale = Vector2.ONE
		CellState.EMPTY:
			_letter_label.label_settings = _settings_empty
			_letter_label.scale = Vector2.ONE
		CellState.DEAD:
			_letter_label.label_settings = _settings_dead
			_letter_label.scale = Vector2(HIGHLIGHT_SCALE, HIGHLIGHT_SCALE)


## Draws debug overlays when DEBUG_COLLISION is enabled.
## Shows a cyan border around the cell and a white dot at its centre.
func _draw() -> void:
	if not GameTheme.DEBUG_COLLISION:
		return
	var cell_size: Vector2 = GameTheme.GRID_CELL_SIZE
	## Draw cell boundary
	draw_rect(Rect2(Vector2.ZERO, cell_size), Color(0.0, 1.0, 1.0, 0.6), false, 1.5)
	## Draw centre dot to show where collision checks measure from
	draw_circle(cell_size * 0.5, 4.0, Color(1.0, 1.0, 1.0, 0.8))


## Returns this cell's letter.
func get_letter() -> String:
	return letter


## Updates the displayed letter text (used when reshuffling the grid).
func set_letter(new_letter: String) -> void:
	letter = new_letter
	if _letter_label:
		_letter_label.text = letter
