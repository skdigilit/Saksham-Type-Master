class_name BackgroundLetters
extends Control
## Fills the viewport with a grid of faded letters that drift in a slow wavy motion.

## The label displaying all background text
var _bg_label: Label = null

## The text that tiles across the entire background.
## It repeats over and over to fill the screen with letters.
const REPEAT_STRING: String = "SAKSHAMTYPINGMASTERSUPERTYPER"

## How many pixels apart each background letter is horizontally.
## Increase to spread letters further apart; decrease to pack them tighter.
const LETTER_SPACING_X: float = 50.0

## How many pixels apart each background letter is vertically (row height).
## Increase for more space between rows; decrease for tighter rows.
const LETTER_SPACING_Y: float = 48.0

## How many extra columns/rows of letters to generate beyond the screen edge.
## This prevents a blank gap appearing when the background drifts.
## You should not need to change this unless the screen is very large.
const OVERFLOW_CELLS: int = 4

## How fast the whole background slowly scrolls to the right (pixels per second).
## 0 = no horizontal drift; higher = faster rightward scroll.
const DRIFT_SPEED_X: float = 18.0

## How fast the whole background slowly scrolls downward (pixels per second).
## 0 = no vertical drift; higher = faster downward scroll.
const DRIFT_SPEED_Y: float = 10.0

## How many pixels the background sways side-to-side in the wave motion.
## Higher = a bigger, more noticeable sway; 0 = no wave, just straight scrolling.
const WAVE_AMPLITUDE: float = 24.0

## How quickly the wave sways back and forth (cycles per second).
## Higher = faster, more jittery wave; lower = a slow, gentle ocean-like sway.
const WAVE_SPEED: float = 0.4

var _time: float = 0.0
var _origin: Vector2 = Vector2.ZERO


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var viewport_size: Vector2 = get_viewport_rect().size
	var cols: int = int(viewport_size.x / LETTER_SPACING_X) + OVERFLOW_CELLS * 2 + 2
	var rows: int = int(viewport_size.y / LETTER_SPACING_Y) + OVERFLOW_CELLS * 2 + 2
	var total_chars: int = cols * rows

	_bg_label = Label.new()
	_bg_label.label_settings = GameTheme.create_label_settings(
		GameTheme.COLOR_BG_LETTER,
		GameTheme.FONT_SIZE_BG,
		Color.TRANSPARENT,
		0
	)
	_bg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_bg_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	## Size the label to cover the oversized grid
	var label_w: float = cols * LETTER_SPACING_X
	var label_h: float = rows * LETTER_SPACING_Y
	_bg_label.size = Vector2(label_w, label_h)

	add_child(_bg_label)
	GameTheme.apply_squiggle_shader(_bg_label, GameTheme.SQUIGGLE_STRENGTH_BG)

	## Build text by tiling REPEAT_STRING
	var flat: String = ""
	var src_len: int = REPEAT_STRING.length()
	for i in range(total_chars):
		flat += REPEAT_STRING[i % src_len]

	var text: String = ""
	for row in range(rows):
		for col in range(cols):
			text += flat[row * cols + col]
			if col < cols - 1:
				text += " "
		if row < rows - 1:
			text += "\n"
	_bg_label.text = text

	## Start centered so overflow is equal on all sides
	_origin = Vector2(
		-OVERFLOW_CELLS * LETTER_SPACING_X,
		-OVERFLOW_CELLS * LETTER_SPACING_Y
	)
	_bg_label.position = _origin


func _process(delta: float) -> void:
	_time += delta

	## Primary drift: slow continuous scroll in a diagonal direction
	var drift: Vector2 = Vector2(
		fmod(_time * DRIFT_SPEED_X, LETTER_SPACING_X * 2.0),
		fmod(_time * DRIFT_SPEED_Y, LETTER_SPACING_Y * 2.0)
	)

	## Secondary wave: sine oscillation on the perpendicular axis
	var wave_offset: Vector2 = Vector2(
		sin(_time * WAVE_SPEED) * WAVE_AMPLITUDE,
		cos(_time * WAVE_SPEED * 0.7) * WAVE_AMPLITUDE * 0.6
	)

	_bg_label.position = _origin + drift + wave_offset
