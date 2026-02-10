# State Machine Base Class
# Base class for all state machines in the game
extends Node
class_name StateMachine

## The initial state to start in
@export var initial_state: State

## Currently active state
var current_state: State

## Dictionary of all available states
var states: Dictionary = {}

func _ready() -> void:
	# Register all child states
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.actor = owner
	
	# Initialize with the initial state
	if initial_state:
		current_state = initial_state
		current_state.enter()

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _process(delta: float) -> void:
	if current_state:
		current_state.frame_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

## Transition to a new state by name
func transition_to(state_name: String) -> void:
	var new_state: State = states.get(state_name.to_lower())
	if new_state and new_state != current_state:
		if current_state:
			current_state.exit()
		current_state = new_state
		current_state.enter()

## Get the name of the current state
func get_current_state_name() -> String:
	return str(current_state.name) if current_state else ""
