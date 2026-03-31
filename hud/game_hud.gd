class_name GameHUD
extends CanvasLayer
## Displays the game HUD: title, score, collected count, and game over state.

## Emitted when the player clicks the new game button after game over
signal restart_requested()

## Score label (crown icon + number)
var _score_label: Label = null

## Collected count label (target icon + number)
var _collected_label: Label = null

## Title label (top-left)
var _title_label: Label = null

## Game over label (bottom-right, hidden until game over)
var _game_over_label: Label = null

## New game button (shown below game over label on game over)
var _restart_button: Button = null

## How far the HUD labels sit from the screen edges (in pixels).
## Increase to push score and title further inward; decrease to move them closer to the edge.
const MARGIN: float = 32.0

## The vertical distance between each line of HUD text at the bottom of the screen (in pixels).
## Increase for more breathing room between the score and collected-count lines.
const LINE_SPACING: float = 44.0

## The extra gap between the "GAME OVER" text and the "NEW GAME" button below it (in pixels).
## Increase to push the button further away from the game over label.
const BUTTON_GAP: float = 16.0


func _ready() -> void:
	_create_hud_elements()


## Builds all HUD label nodes and positions them.
func _create_hud_elements() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	## Title label (top-left)
	_title_label = _create_hud_label()
	_title_label.text = "SAKSHAM TYPING MASTER"
	_title_label.size = Vector2(600, 60)
	_title_label.position = Vector2(MARGIN, MARGIN)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(_title_label)

	## Score label (bottom-left, first line)
	_score_label = _create_hud_label()
	_score_label.text = "M 000"
	_score_label.position = Vector2(MARGIN, viewport_size.y - MARGIN - LINE_SPACING * 2)
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(_score_label)

	## Collected label (bottom-left, second line)
	_collected_label = _create_hud_label()
	_collected_label.text = "O 000"
	_collected_label.position = Vector2(MARGIN, viewport_size.y - MARGIN - LINE_SPACING)
	_collected_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(_collected_label)

	## Game over label (centered, hidden initially)
	_game_over_label = _create_hud_label()
	_game_over_label.text = "GAME OVER"
	_game_over_label.size = Vector2(400, 60)
	_game_over_label.position = Vector2(
		(viewport_size.x - 400) * 0.5,
		viewport_size.y * 0.5 - LINE_SPACING
	)
	_game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_game_over_label.label_settings = GameTheme.create_label_settings(
		GameTheme.COLOR_ENEMY,
		GameTheme.FONT_SIZE_HUD,
		GameTheme.COLOR_CIRCLE_OUTLINE,
		4
	)
	GameTheme.apply_squiggle_shader(_game_over_label, GameTheme.SQUIGGLE_STRENGTH_HUD)
	_game_over_label.visible = false
	add_child(_game_over_label)

	## Restart button (below the game over label, hidden initially)
	_restart_button = _create_restart_button(viewport_size)
	_restart_button.visible = false
	add_child(_restart_button)


## Builds the styled restart button centered in the lower half of the screen.
func _create_restart_button(viewport_size: Vector2) -> Button:
	var btn := Button.new()
	btn.text = "NEW GAME"

	## Apply our font and colors via a custom theme — no shader on the button
	## (ShaderMaterial on a Button blocks mouse input in Godot 4)
	var btn_theme := Theme.new()
	var font: FontFile = GameTheme.get_font()
	btn_theme.set_font("font", "Button", font)
	btn_theme.set_font_size("font_size", "Button", GameTheme.FONT_SIZE_HUD)
	btn_theme.set_color("font_color", "Button", GameTheme.COLOR_HUD)
	btn_theme.set_color("font_hover_color", "Button", GameTheme.COLOR_LETTER_COLLECTIBLE)
	btn_theme.set_color("font_pressed_color", "Button", GameTheme.COLOR_ENEMY)
	## Transparent style boxes — no visual chrome
	var empty_style := StyleBoxEmpty.new()
	btn_theme.set_stylebox("normal", "Button", empty_style)
	btn_theme.set_stylebox("hover", "Button", empty_style)
	btn_theme.set_stylebox("pressed", "Button", empty_style)
	btn_theme.set_stylebox("focus", "Button", empty_style)
	btn.theme = btn_theme

	var btn_width: float = 300.0
	var btn_height: float = 60.0
	btn.size = Vector2(btn_width, btn_height)
	## Center horizontally, place just below vertical center
	btn.position = Vector2(
		(viewport_size.x - btn_width) * 0.5,
		viewport_size.y * 0.5 + LINE_SPACING + BUTTON_GAP
	)
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER

	btn.pressed.connect(func() -> void: restart_requested.emit())
	return btn


## Creates a styled HUD label with squiggle shader.
func _create_hud_label() -> Label:
	var label := Label.new()
	label.label_settings = GameTheme.create_label_settings(
		GameTheme.COLOR_HUD,
		GameTheme.FONT_SIZE_HUD,
		GameTheme.COLOR_LETTER_OUTLINE,
		3
	)
	label.size = Vector2(300, 60)
	GameTheme.apply_squiggle_shader(label, GameTheme.SQUIGGLE_STRENGTH_HUD)
	return label


## Updates the score display. Formats as 3-digit zero-padded number.
func update_score(value: int) -> void:
	if _score_label:
		_score_label.text = "M %03d" % value


## Updates the collected count display.
func update_collected(value: int) -> void:
	if _collected_label:
		_collected_label.text = "O %03d" % value


## Shows the game over label and the restart button.
func show_game_over() -> void:
	if _game_over_label:
		_game_over_label.visible = true
	if _restart_button:
		_restart_button.visible = true
