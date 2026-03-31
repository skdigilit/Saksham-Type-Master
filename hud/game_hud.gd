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

## Heart textures and slot nodes shown under the title.
var _heart_full_texture: Texture2D = null
var _heart_outline_texture: Texture2D = null
var _heart_slots: Array[TextureRect] = []

## How far the HUD labels sit from the screen edges (in pixels).
## Increase to push score and title further inward; decrease to move them closer to the edge.
const MARGIN: float = 32.0

## The vertical distance between each line of HUD text at the bottom of the screen (in pixels).
## Increase for more breathing room between the score and collected-count lines.
const LINE_SPACING: float = 44.0

## The extra gap between the "GAME OVER" text and the "NEW GAME" button below it (in pixels).
## Increase to push the button further away from the game over label.
const BUTTON_GAP: float = 16.0
const HEART_TOP_GAP: float = 68.0
const HEART_SLOT_SIZE: Vector2 = Vector2(42.0, 42.0)
const HEART_SLOT_SPACING: float = 12.0
const HEART_FLY_SIZE: Vector2 = Vector2(26.0, 26.0)
const HEART_FLY_DURATION: float = 0.8
const LIFE_LOSS_POPUP_RISE: float = 54.0
const LIFE_LOSS_POPUP_DURATION: float = 1.25


func _ready() -> void:
	_heart_full_texture = load("res://sprites/heart_full.png") as Texture2D
	_heart_outline_texture = load("res://sprites/heart_outline.png") as Texture2D
	_create_hud_elements()
	refresh_layout(get_viewport().get_visible_rect().size)


## Builds all HUD label nodes and positions them.
func _create_hud_elements() -> void:
	## Title label (top-left)
	_title_label = _create_hud_label()
	_title_label.text = "SAKSHAM TYPING MASTER"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(_title_label)

	_create_heart_slots()

	## Score label (bottom-left, first line)
	_score_label = _create_hud_label()
	_score_label.text = "M 000"
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(_score_label)

	## Collected label (bottom-left, second line)
	_collected_label = _create_hud_label()
	_collected_label.text = "O 000"
	_collected_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(_collected_label)

	## Game over label (centered, hidden initially)
	_game_over_label = _create_hud_label()
	_game_over_label.text = "GAME OVER"
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
	_restart_button = _create_restart_button()
	_restart_button.visible = false
	add_child(_restart_button)


func _create_heart_slots() -> void:
	_heart_slots.clear()
	for i in range(3):
		var heart := TextureRect.new()
		heart.texture = _heart_outline_texture
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = HEART_SLOT_SIZE
		heart.size = HEART_SLOT_SIZE
		heart.position = Vector2(
			MARGIN + i * (HEART_SLOT_SIZE.x + HEART_SLOT_SPACING),
			MARGIN + HEART_TOP_GAP
		)
		add_child(heart)
		_heart_slots.append(heart)


## Builds the styled restart button centered in the lower half of the screen.
func _create_restart_button() -> Button:
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


func update_lives(current_lives: int) -> void:
	for i in range(_heart_slots.size()):
		_heart_slots[i].texture = _heart_full_texture if i < current_lives else _heart_outline_texture


func animate_life_gain(from_position: Vector2, target_life_index: int) -> void:
	if _heart_full_texture == null:
		return
	if target_life_index < 0 or target_life_index >= _heart_slots.size():
		return

	var flying_heart := TextureRect.new()
	flying_heart.texture = _heart_full_texture
	flying_heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flying_heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	flying_heart.custom_minimum_size = HEART_FLY_SIZE
	flying_heart.size = HEART_FLY_SIZE
	flying_heart.position = from_position - HEART_FLY_SIZE * 0.5
	add_child(flying_heart)

	var target_center: Vector2 = get_heart_slot_center(target_life_index)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(flying_heart, "position", target_center - HEART_FLY_SIZE * 0.5, HEART_FLY_DURATION)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(flying_heart, "scale", Vector2(0.65, 0.65), HEART_FLY_DURATION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(flying_heart, "modulate:a", 0.0, HEART_FLY_DURATION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(func() -> void:
		flying_heart.queue_free()
	)


func animate_life_loss(from_position: Vector2) -> void:
	var popup := _create_hud_label()
	popup.text = "-1"
	popup.label_settings = GameTheme.create_label_settings(
		GameTheme.COLOR_ENEMY,
		72,
		GameTheme.COLOR_CIRCLE_OUTLINE,
		5
	)
	popup.size = Vector2(140, 90)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.position = from_position + Vector2(-popup.size.x * 0.5, -48.0)
	popup.scale = Vector2(0.55, 0.55)
	add_child(popup)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "position:y", popup.position.y - LIFE_LOSS_POPUP_RISE, LIFE_LOSS_POPUP_DURATION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup, "modulate:a", 0.0, LIFE_LOSS_POPUP_DURATION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_property(popup, "scale", Vector2(1.55, 1.55), 0.28)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(popup, "scale", Vector2(0.92, 0.92), 0.24)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(popup, "scale", Vector2(1.2, 1.2), 0.26)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func() -> void:
		popup.queue_free()
	)


func get_heart_slot_center(index: int) -> Vector2:
	if index < 0 or index >= _heart_slots.size():
		return Vector2.ZERO
	return _heart_slots[index].position + _heart_slots[index].size * 0.5


func refresh_layout(viewport_size: Vector2) -> void:
	var hud_font_size: int = clampi(int(minf(GameTheme.FONT_SIZE_HUD, viewport_size.x * 0.045)), 28, GameTheme.FONT_SIZE_HUD)

	if _title_label:
		_title_label.label_settings = GameTheme.create_label_settings(
			GameTheme.COLOR_HUD,
			hud_font_size,
			GameTheme.COLOR_LETTER_OUTLINE,
			3
		)
		_title_label.size = Vector2(maxf(240.0, viewport_size.x - MARGIN * 2.0), 60.0)
		_title_label.position = Vector2(MARGIN, MARGIN)

	for i in range(_heart_slots.size()):
		_heart_slots[i].position = Vector2(
			MARGIN + i * (HEART_SLOT_SIZE.x + HEART_SLOT_SPACING),
			MARGIN + HEART_TOP_GAP
		)

	if _score_label:
		_score_label.label_settings = GameTheme.create_label_settings(
			GameTheme.COLOR_HUD,
			hud_font_size,
			GameTheme.COLOR_LETTER_OUTLINE,
			3
		)
		_score_label.position = Vector2(MARGIN, viewport_size.y - MARGIN - LINE_SPACING * 2)

	if _collected_label:
		_collected_label.label_settings = GameTheme.create_label_settings(
			GameTheme.COLOR_HUD,
			hud_font_size,
			GameTheme.COLOR_LETTER_OUTLINE,
			3
		)
		_collected_label.position = Vector2(MARGIN, viewport_size.y - MARGIN - LINE_SPACING)

	if _game_over_label:
		_game_over_label.size = Vector2(minf(400.0, viewport_size.x - MARGIN * 2.0), 60.0)
		_game_over_label.position = Vector2(
			(viewport_size.x - _game_over_label.size.x) * 0.5,
			viewport_size.y * 0.5 - LINE_SPACING
		)

	if _restart_button:
		_restart_button.position = Vector2(
			(viewport_size.x - _restart_button.size.x) * 0.5,
			viewport_size.y * 0.5 + LINE_SPACING + BUTTON_GAP
		)


## Shows the game over label and the restart button.
func show_game_over() -> void:
	if _game_over_label:
		_game_over_label.visible = true
	if _restart_button:
		_restart_button.visible = true
