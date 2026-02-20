# Main Menu
extends CanvasLayer

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if options_button:
		options_button.pressed.connect(_on_options_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	_play_intro_animation()

func _play_intro_animation() -> void:
	var vbox = $VBoxContainer
	if not vbox:
		return
		
	var tween := create_tween().set_parallel(true)
	
	for child in vbox.get_children():
		child.modulate.a = 0
	
	var delay = 0.0
	for child in vbox.get_children():
		tween.tween_interval(delay)
		tween.tween_property(child, "modulate:a", 1.0, 0.3)
		delay += 0.15

func _on_play_pressed() -> void:
	if has_node("/root/AudioManager"):
		$"/root/AudioManager".play_punch()
	
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_options_pressed() -> void:
	print("Opciones")

func _on_quit_pressed() -> void:
	get_tree().quit()
