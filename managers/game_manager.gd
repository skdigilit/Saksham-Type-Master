class_name GameManager
extends Node
## Central orchestrator that connects all game systems.
## Manages game state, scoring, difficulty, and signal wiring.

enum Difficulty { EASY, MEDIUM, HARD, HELL }
enum GameState { PLAYING, GAME_OVER, WIN }

## Current game state
var current_state: GameState = GameState.PLAYING

## Current difficulty level
var current_difficulty: Difficulty = Difficulty.EASY

## Player's score (increments on collection)
var score: int = 0

## Player life state.
const MAX_LIVES: int = 3
const HIT_INVULNERABILITY_DURATION: float = 1.0
var current_lives: int = MAX_LIVES
var _hit_invulnerability_timer: float = 0.0

## Node references (resolved in _ready)
var grid: LetterGrid = null
var player: PlayerController = null
var collectible_manager: CollectibleManager = null
var enemy_spawner: EnemySpawner = null
var game_circle: GameCircle = null
var hud: GameHUD = null
var sound_manager: SoundManager = null

## Difficulty names for the HUD
const DIFFICULTY_NAMES: Array[String] = ["EASY", "MEDIUM", "HARD", "HELL"]

## Score awarded per collectible
const SCORE_PER_COLLECT: int = 5

## Score bonus for time survived (per second)
const SCORE_PER_SECOND: float = 1.0

## Time accumulator for per-second scoring
var _score_timer: float = 0.0


func _ready() -> void:
	## Resolve sibling node references
	grid = get_node_or_null("../LetterGrid") as LetterGrid
	player = get_node_or_null("../PlayerController") as PlayerController
	collectible_manager = get_node_or_null("../CollectibleManager") as CollectibleManager
	enemy_spawner = get_node_or_null("../Enemies") as EnemySpawner
	game_circle = get_node_or_null("../GameCircle") as GameCircle
	hud = get_node_or_null("../HUD") as GameHUD

	## Create and attach the sound manager
	sound_manager = SoundManager.new()
	add_child(sound_manager)

	## Wait one frame for all children to be ready, then start
	await get_tree().process_frame
	_start_game()


## Initializes all systems and begins gameplay.
func _start_game() -> void:
	current_state = GameState.PLAYING
	score = 0
	_score_timer = 0.0
	current_lives = MAX_LIVES
	_hit_invulnerability_timer = 0.0

	## Initialize player controller
	if player and grid:
		player.initialize(grid)
		player.is_input_enabled = true

	## Initialize collectible manager
	if collectible_manager and grid and game_circle and player:
		collectible_manager.initialize(grid, game_circle, player)
		collectible_manager.can_spawn_life_collectible = _can_gain_life
		collectible_manager.collectible_collected.connect(_on_collectible_collected)
		collectible_manager.all_collected.connect(_on_all_collected)
		collectible_manager.spawn_collectible()

	## Initialize enemy spawner
	if enemy_spawner:
		enemy_spawner.player = player
		enemy_spawner.set_difficulty(current_difficulty)
		enemy_spawner.start_spawning()

	## Initialize HUD
	if hud:
		hud.update_score(score)
		hud.update_collected(0)
		hud.update_lives(current_lives)
		hud.restart_requested.connect(_on_restart_requested)

	## Wire sounds
	if sound_manager and player and collectible_manager:
		sound_manager.connect_signals(player, collectible_manager)


func _process(delta: float) -> void:
	if current_state != GameState.PLAYING:
		return

	if _hit_invulnerability_timer > 0.0:
		_hit_invulnerability_timer = maxf(0.0, _hit_invulnerability_timer - delta)

	## Check enemy-player collision
	if enemy_spawner and player and _hit_invulnerability_timer <= 0.0:
		var player_pos: Vector2 = player.get_current_pixel_position()
		if enemy_spawner.check_player_collision(player_pos):
			_on_player_hit()
			return

	## Mark letters red while an enemy is visually passing over them
	if enemy_spawner and grid:
		_update_cell_scorch()

	## Accumulate time-based score
	_score_timer += delta
	if _score_timer >= 1.0:
		_score_timer -= 1.0
		score += int(SCORE_PER_SECOND)
		if hud:
			hud.update_score(score)


## Called when the player collects a collectible.
func _on_collectible_collected(total: int, collectible_type: CollectibleManager.CollectibleType, world_position: Vector2) -> void:
	if collectible_type == CollectibleManager.CollectibleType.LIFE:
		if current_lives < MAX_LIVES:
			var gained_life_index: int = current_lives
			current_lives += 1
			if hud:
				hud.animate_life_gain(world_position, gained_life_index)
				hud.update_lives(current_lives)
	else:
		score += SCORE_PER_COLLECT
		if hud:
			hud.update_score(score)
			hud.update_collected(total)

	## Shuffle all letters so each collection feels fresh
	if grid:
		grid.randomize_grid()


## Called when all collectibles for the round are gathered.
func _on_all_collected() -> void:
	current_state = GameState.WIN
	if player:
		player.is_input_enabled = false
	if enemy_spawner:
		enemy_spawner.stop_spawning()
	## TODO: Show win screen / advance to next difficulty


## Called when the player is hit by an enemy.
func _on_player_hit() -> void:
	current_lives -= 1
	_hit_invulnerability_timer = HIT_INVULNERABILITY_DURATION
	if hud:
		hud.update_lives(current_lives)

	if current_lives <= 0:
		_on_game_over()


## Called when the player is out of lives.
func _on_game_over() -> void:
	current_state = GameState.GAME_OVER
	if player:
		player.is_input_enabled = false
	if enemy_spawner:
		enemy_spawner.stop_spawning()
	## Turn the active letter red
	if grid and player:
		var dead_cell: LetterCell = grid.get_cell(player.current_row, player.current_col)
		if dead_cell:
			dead_cell.set_state(LetterCell.CellState.DEAD)
	if hud:
		hud.show_game_over()
	if sound_manager:
		sound_manager.play_game_over()
	## Fade all grid letters and the circle to signal game over
	if grid:
		grid.fade_out(0.2)
	if game_circle:
		var tween: Tween = create_tween()
		tween.tween_property(game_circle, "modulate:a", 0.25, 1.2)


func _can_gain_life() -> bool:
	return current_lives < MAX_LIVES


## Reloads the current scene to start a fresh game.
func _on_restart_requested() -> void:
	get_tree().reload_current_scene()


## Each frame, checks every active letter cell against every live enemy.
## Cells whose centre is inside an enemy's visual circle are marked red (scorched).
## Cells that are no longer covered are restored to their normal colour.
## HIGHLIGHTED and DEAD cells are never scorched — they keep their own colour.
func _update_cell_scorch() -> void:
	## Collect current enemy positions once so we don't repeat the loop per cell
	var enemy_positions: Array[Vector2] = []
	for child in enemy_spawner.get_children():
		if child is ChordEnemy:
			enemy_positions.append(child.position)

	var scorch_radius: float = GameTheme.ENEMY_BG_RADIUS

	for pos in GridHelpers.all_positions():
		var cell: LetterCell = grid.get_cell(pos.x, pos.y)
		if cell == null:
			continue
		## Never scorch the player's cell or a dead cell
		if cell.cell_state == LetterCell.CellState.HIGHLIGHTED or cell.cell_state == LetterCell.CellState.DEAD:
			continue

		## Cell centre in world coordinates
		var cell_center: Vector2 = cell.global_position + GameTheme.GRID_CELL_SIZE * 0.5

		## Check if any enemy overlaps this cell
		var should_scorch: bool = false
		for ep in enemy_positions:
			if ep.distance_to(cell_center) < scorch_radius:
				should_scorch = true
				break

		cell.set_scorched(should_scorch)
