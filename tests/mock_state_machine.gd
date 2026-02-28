extends "res://scripts/core/state_machine.gd"

var last_transition: String = ""

func transition_to(state_name: String) -> void:
	last_transition = state_name
