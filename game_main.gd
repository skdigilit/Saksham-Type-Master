extends ColorRect
## Root node for the game. Sets up the background color and
## assembles all child systems programmatically.


func _ready() -> void:
	## Compute CIRCLE_RADIUS and CIRCLE_CENTER from the actual window size.
	## Must be the very first call so every child node sees the correct values.
	GameTheme.initialize_screen_layout(get_viewport().get_visible_rect().size)

	## Set the background color from the theme
	color = GameTheme.COLOR_BACKGROUND
	print("screen size : " ,size)
	## Create all game systems as child nodes in the correct draw order

	## 1. Background letters (faded grid behind everything)
	var bg_letters := BackgroundLetters.new()
	bg_letters.name = "BackgroundLetters"
	add_child(bg_letters)

	## 2. Game circle (wobbly boundary with perimeter dots)
	var game_circle := GameCircle.new()
	game_circle.name = "GameCircle"
	add_child(game_circle)

	## 3. Letter grid (diamond layout of interactive letters)
	var letter_grid := LetterGrid.new()
	letter_grid.name = "LetterGrid"
	add_child(letter_grid)

	## 4. Enemy spawner (manages chord enemies)
	var enemies := EnemySpawner.new()
	enemies.name = "Enemies"
	add_child(enemies)

	## 5. HUD (score, collected count, difficulty)
	var hud := GameHUD.new()
	hud.name = "HUD"
	add_child(hud)

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
