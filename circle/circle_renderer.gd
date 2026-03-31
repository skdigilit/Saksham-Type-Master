class_name CircleRenderer
extends Node2D
## Draws the circle geometry (interior, outline, dots) inside a SubViewport.
## Rendered output is sampled as a texture by GameCircle's Sprite2D,
## which then has the squiggle shader applied to it.

## Set by GameCircle so this node can read current dot state
var filled_dots: int = 0
var active_dot_index: int = -1


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
