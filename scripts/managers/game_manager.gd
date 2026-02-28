# Game Manager - AUTOLOAD
# Estado global del juego
extends Node

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }
var current_state := GameState.MENU

var is_paused := false

func _ready() -> void:
	start_game()

func start_game() -> void:
	current_state = GameState.PLAYING
	is_paused = false
	
	if has_node("/root/ScoreManager"):
		$"/root/ScoreManager".reset_game()
	
	if has_node("/root/AudioManager"):
		$"/root/AudioManager".play_music()

func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		is_paused = true
		get_tree().paused = true

func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		is_paused = false
		get_tree().paused = false

func game_over() -> void:
	current_state = GameState.GAME_OVER
	if has_node("/root/AudioManager"):
		$"/root/AudioManager".stop_music()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if current_state == GameState.PLAYING:
			pause_game()
		elif current_state == GameState.PAUSED:
			resume_game()
