class_name GameCircle
extends Node2D
## Draws the circle boundary with a filled interior and perimeter dots.
## No shader applied — clean geometric rendering.

var filled_dots: int = 0
var active_dot_index: int = -1


func _ready() -> void:
	position = GameTheme.CIRCLE_CENTER


func _draw() -> void:
	var radius: float = GameTheme.CIRCLE_RADIUS
	var dot_count: int = GameTheme.CIRCLE_DOT_COUNT

	## 1. Filled circle interior
	draw_circle(Vector2.ZERO, radius, GameTheme.COLOR_CIRCLE_INTERIOR)

	## 2. Circle outline
	draw_arc(
		Vector2.ZERO,
		radius,
		0.0,
		TAU,
		128,
		GameTheme.COLOR_CIRCLE_OUTLINE,
		GameTheme.CIRCLE_OUTLINE_WIDTH,
		true
	)

	## 3. Perimeter dots
	for i in range(dot_count):
		var angle: float = -PI / 2.0 + (float(i) / float(dot_count)) * TAU
		var dot_pos: Vector2 = Vector2(cos(angle), sin(angle)) * radius

		var dot_color: Color
		if i == active_dot_index or i < filled_dots:
			dot_color = GameTheme.COLOR_CIRCLE_DOT_FILLED
		else:
			dot_color = GameTheme.COLOR_CIRCLE_DOT_EMPTY

		draw_circle(dot_pos, GameTheme.CIRCLE_DOT_RADIUS, dot_color)


## Updates the number of filled dots and redraws.
func set_filled_dots(count: int) -> void:
	filled_dots = count
	queue_redraw()


## Sets which dot is the active target (shown in yellow).
func set_active_dot(index: int) -> void:
	active_dot_index = index
	queue_redraw()


## Returns the world position of a specific perimeter dot.
func get_dot_position(index: int) -> Vector2:
	var angle: float = -PI / 2.0 + (float(index) / float(GameTheme.CIRCLE_DOT_COUNT)) * TAU
	var local_pos: Vector2 = Vector2(cos(angle), sin(angle)) * GameTheme.CIRCLE_RADIUS
	return position + local_pos
