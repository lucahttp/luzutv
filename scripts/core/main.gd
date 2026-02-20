# Main Scene
extends Node3D

func _ready() -> void:
	if has_node("/root/GameManager"):
		$"/root/GameManager".start_game()
