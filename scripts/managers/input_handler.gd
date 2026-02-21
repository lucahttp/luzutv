# Input Handler - AUTOLOAD
# Centralized input handling for the game
extends Node

## Input state cache - update this once per frame
var move_direction: Vector2 = Vector2.ZERO
var move_direction_3d: Vector3 = Vector3.ZERO

var is_jump_pressed: bool = false
var is_run_pressed: bool = false
var is_crouch_pressed: bool = false
var is_attack_just_pressed: bool = false
var is_interact_just_pressed: bool = false
var is_jump_just_pressed: bool = false

## Bicycle input
var throttle: float = 0.0
var brake: float = 0.0
var steer_direction: float = 0.0

func _process(_delta: float) -> void:
	# Update input state once per frame
	move_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	is_jump_pressed = Input.is_action_pressed("jump")
	is_run_pressed = Input.is_action_pressed("run")
	is_crouch_pressed = Input.is_action_pressed("crouch")
	is_attack_just_pressed = Input.is_action_just_pressed("attack")
	is_interact_just_pressed = Input.is_action_just_pressed("interact")
	is_jump_just_pressed = Input.is_action_just_pressed("jump")
	
	# Bicycle input
	throttle = Input.get_action_strength("accelerate")
	brake = Input.get_action_strength("brake")
	steer_direction = Input.get_axis("steer_right", "steer_left")

## Get 3D movement direction relative to camera
func get_movement_direction_3d() -> Vector3:
	var camera := get_viewport().get_camera_3d()
	
	if camera:
		var forward := -camera.global_transform.basis.z
		var right := camera.global_transform.basis.x
		forward.y = 0
		right.y = 0
		forward = forward.normalized()
		right = right.normalized()
		return (right * move_direction.x + forward * -move_direction.y).normalized()
	
	return Vector3(move_direction.x, 0, move_direction.y)

## Check if player is moving
func is_moving() -> bool:
	return move_direction.length() > 0.1
