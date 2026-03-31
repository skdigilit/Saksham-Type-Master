class_name ChordEnemy
extends Node2D
## A single enemy that travels along a random chord across the circle.
## Appears from outside the circle boundary, crosses through, and exits on the other side.

## Emitted when the enemy has exited the circle and should be freed
signal exited()

## Start and end points of the chord (extended beyond the circle)
var start_point: Vector2 = Vector2.ZERO
var end_point: Vector2 = Vector2.ZERO

## Movement speed in pixels per second
var speed: float = GameTheme.ENEMY_SPEED

## Current travel progress: 0.0 = at start, 1.0 = at end
var progress: float = 0.0

## Total distance of the chord path
var _total_distance: float = 0.0

## Position at the start of the current frame, used for swept collision
var prev_position: Vector2 = Vector2.ZERO

## Tracks whether this enemy has entered and then exited the circle.
## Once has_exited_circle is true it no longer counts toward the active cap.
var has_entered_circle: bool = false
var has_exited_circle: bool = false

## The sprite used to render the enemy
var _enemy_sprite: Sprite2D = null


func _ready() -> void:
	_create_visuals()


## Creates the enemy sprite, sized to match ENEMY_BG_RADIUS and tinted red.
func _create_visuals() -> void:
	_enemy_sprite = Sprite2D.new()
	_enemy_sprite.texture = load("res://sprites/enemy_sprite.png")
	## Modulate to the enemy red color
	_enemy_sprite.modulate = GameTheme.COLOR_ENEMY
	## Scale the sprite so it fits within the enemy background radius
	var texture_size: Vector2 = _enemy_sprite.texture.get_size()
	var target_size: float = GameTheme.ENEMY_BG_RADIUS * 2.0
	_enemy_sprite.scale = Vector2.ONE * (target_size / maxf(texture_size.x, texture_size.y))
	## Apply squiggle shader with the same parameters as the game circle letters
	GameTheme.apply_squiggle_shader(
		_enemy_sprite,
		GameTheme.SQUIGGLE_STRENGTH_NORMAL,
		GameTheme.SQUIGGLE_FPS,
		GameTheme.SQUIGGLE_SCALE
	)
	add_child(_enemy_sprite)


## Sets up the chord path. Picks two random angles on the circle perimeter
## and extends them outward so the enemy starts and ends offscreen.
func setup(center: Vector2, radius: float) -> void:
	## Pick two random angles at least 60 degrees apart for a meaningful chord
	var angle_a: float = randf() * TAU
	var min_separation: float = PI / 3.0  ## 60 degrees
	var angle_b: float = angle_a + min_separation + randf() * (TAU - 2.0 * min_separation)

	## Compute circle perimeter points
	var point_a: Vector2 = center + Vector2(cos(angle_a), sin(angle_a)) * radius
	var point_b: Vector2 = center + Vector2(cos(angle_b), sin(angle_b)) * radius

	## Extend outward by a margin so the enemy enters/exits from beyond the circle
	var margin: float = 120.0
	var direction: Vector2 = (point_b - point_a).normalized()
	start_point = point_a - direction * margin
	end_point = point_b + direction * margin

	_total_distance = start_point.distance_to(end_point)
	position = start_point
	## Initialise prev_position to start so the first swept-collision segment is valid
	prev_position = start_point
	progress = 0.0


func _process(delta: float) -> void:
	if _total_distance <= 0.0:
		return

	## Record position before moving so swept collision can test the full segment
	prev_position = position

	## Advance along the chord
	progress += (speed * delta) / _total_distance
	position = start_point.lerp(end_point, progress)

	## Track circle entry and exit to update the active enemy cap correctly
	var dist_from_center: float = position.distance_to(GameTheme.CIRCLE_CENTER)
	if not has_entered_circle and dist_from_center < GameTheme.CIRCLE_RADIUS:
		has_entered_circle = true
	elif has_entered_circle and not has_exited_circle and dist_from_center >= GameTheme.CIRCLE_RADIUS:
		has_exited_circle = true

	## Refresh debug overlay every frame
	if GameTheme.DEBUG_COLLISION:
		queue_redraw()

	## Remove when past the endpoint
	if progress >= 1.0:
		exited.emit()
		queue_free()
		return

	## Safety removal: free if somehow outside the visible viewport
	var viewport_rect: Rect2 = get_viewport_rect().grow(GameTheme.ENEMY_BG_RADIUS * 2.0)
	if not viewport_rect.has_point(position):
		queue_free()


## Draws debug overlays when DEBUG_COLLISION is enabled.
## Inner red circle = visual size (ENEMY_BG_RADIUS).
## Outer yellow circle = full danger zone (hit_radius used in enemy_spawner).
func _draw() -> void:
	if not GameTheme.DEBUG_COLLISION:
		return
	## Inner: visual size of the enemy
	draw_circle(Vector2.ZERO, GameTheme.ENEMY_BG_RADIUS, Color(1.0, 0.0, 0.0, 0.25))
	draw_arc(Vector2.ZERO, GameTheme.ENEMY_BG_RADIUS, 0.0, TAU, 32, Color(1.0, 0.0, 0.0, 0.8), 1.5)
	## Outer: the actual danger zone that triggers a game over
	var hit_r: float = GameTheme.ENEMY_BG_RADIUS + GameTheme.GRID_CELL_SIZE.x * GameTheme.ENEMY_HIT_PADDING
	draw_circle(Vector2.ZERO, hit_r, Color(1.0, 1.0, 0.0, 0.1))
	draw_arc(Vector2.ZERO, hit_r, 0.0, TAU, 40, Color(1.0, 1.0, 0.0, 0.7), 1.5)


## Returns the world position of this enemy (for collision checks).
func get_collision_position() -> Vector2:
	return position
