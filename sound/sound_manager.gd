class_name SoundManager
extends Node
## Plays all game sound effects.
## Add as a child of GameManager and call connect_signals() to wire everything up.

## AudioStreamPlayer nodes — one per sound so they can overlap if needed
var _move_player: AudioStreamPlayer = null
var _collect_player: AudioStreamPlayer = null
var _game_over_player: AudioStreamPlayer = null

## Sound file paths
const SOUND_MOVE: String = "res://sounds/Button Snap.wav"
const SOUND_COLLECT: String = "res://sounds/Woody Block.wav"
const SOUND_GAME_OVER: String = "res://sounds/Thats It.wav"


func _ready() -> void:
	_move_player = _create_player(SOUND_MOVE)
	_collect_player = _create_player(SOUND_COLLECT)
	_game_over_player = _create_player(SOUND_GAME_OVER)


## Creates and registers an AudioStreamPlayer for the given file path.
func _create_player(path: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = load(path)
	add_child(player)
	return player


## Connects to the signals that trigger each sound.
## Call this from GameManager after all systems are ready.
func connect_signals(player_controller: PlayerController, collectible_manager: CollectibleManager) -> void:
	player_controller.moved_to.connect(_on_player_moved)
	collectible_manager.collectible_collected.connect(_on_collectible_collected)


## Plays the move snap sound when the player steps to a new letter.
func _on_player_moved(_row: int, _col: int, _letter: String) -> void:
	if GameTheme.SOUND_ENABLED:
		_move_player.play()


## Plays the woody block sound when a gold letter is collected.
func _on_collectible_collected(_total: int) -> void:
	if GameTheme.SOUND_ENABLED:
		_collect_player.play()


## Plays the game over jingle. Called directly by GameManager.
func play_game_over() -> void:
	if GameTheme.SOUND_ENABLED:
		_game_over_player.play()
