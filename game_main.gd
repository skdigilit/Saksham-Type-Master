extends ColorRect
## Root node for the game. Sets up the background color and
## assembles all child systems programmatically.

var _background_letters: BackgroundLetters = null
var _game_circle: GameCircle = null
var _letter_grid: LetterGrid = null
var _enemies: EnemySpawner = null
var _hud: GameHUD = null


func _ready() -> void:
	## Compute CIRCLE_RADIUS and CIRCLE_CENTER from the actual window size.
	## Must be the very first call so every child node sees the correct values.
	GameTheme.initialize_screen_layout(get_viewport().get_visible_rect().size)

	## Set the background color from the theme
	color = GameTheme.COLOR_BACKGROUND
	print("screen size : " ,size)
	## Create all game systems as child nodes in the correct draw order

	## 1. Background letters (faded grid behind everything)
	_background_letters = BackgroundLetters.new()
	_background_letters.name = "BackgroundLetters"
	add_child(_background_letters)

	## 2. Game circle (wobbly boundary with perimeter dots)
	_game_circle = GameCircle.new()
	_game_circle.name = "GameCircle"
	add_child(_game_circle)

	## 3. Letter grid (diamond layout of interactive letters)
	_letter_grid = LetterGrid.new()
	_letter_grid.name = "LetterGrid"
	add_child(_letter_grid)

	## 4. Enemy spawner (manages chord enemies)
	_enemies = EnemySpawner.new()
	_enemies.name = "Enemies"
	add_child(_enemies)

	## 5. HUD (score, collected count, difficulty)
	_hud = GameHUD.new()
	_hud.name = "HUD"
	add_child(_hud)

	## 6. Collectible manager (spawns/tracks yellow letters)
	var collectible_mgr := CollectibleManager.new()
	collectible_mgr.name = "CollectibleManager"
	add_child(collectible_mgr)

	## 7. Player controller (input handling)
	var player_ctrl := PlayerController.new()
	player_ctrl.name = "PlayerController"
	add_child(player_ctrl)

	## 8. Game manager (orchestrator — must be last so it can find all siblings)
	var game_mgr := GameManager.new()
	game_mgr.name = "GameManager"
	add_child(game_mgr)

	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _on_viewport_size_changed() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	GameTheme.initialize_screen_layout(viewport_size)

	if _background_letters:
		_background_letters.refresh_layout(viewport_size)
	if _game_circle:
		_game_circle.refresh_layout()
	if _letter_grid:
		_letter_grid.refresh_layout()
	if _enemies:
		_enemies.refresh_layout()
	if _hud:
		_hud.refresh_layout(viewport_size)
