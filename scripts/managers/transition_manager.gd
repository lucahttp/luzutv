# Transition Manager
# Handles smooth transitions between on-foot and bicycle modes
extends Node
class_name TransitionManager

## References
@export var player: PlayerController
@export var bicycle: BicycleController
@export var camera_rig: Node3D

## Transition settings
@export var interaction_distance := 2.5
@export var camera_transition_duration := 0.5

## State
var is_on_bike := false

## Signals
signal mode_changed(is_on_bike: bool)

func _ready() -> void:
	# Auto-find references if not set
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if not bicycle:
		bicycle = get_tree().get_first_node_in_group("bicycle")
	if not camera_rig:
		camera_rig = get_tree().get_first_node_in_group("camera_rig")
	
	# Connect signals
	if bicycle:
		bicycle.rider_mounted.connect(_on_rider_mounted)
		bicycle.rider_dismounted.connect(_on_rider_dismounted)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if is_on_bike:
			_try_dismount()
		else:
			_try_mount()

func _try_mount() -> void:
	if not player or not bicycle or is_on_bike:
		return
	
	# Check distance
	var distance := player.global_position.distance_to(bicycle.global_position)
	if distance <= interaction_distance:
		_mount()

func _try_dismount() -> void:
	if not bicycle or not is_on_bike:
		return
	
	# Check if safe to dismount (low speed)
	if bicycle.linear_velocity.length() < 5.0:
		_dismount()

func _mount() -> void:
	bicycle.mount(player)

func _dismount() -> void:
	bicycle.dismount()

func _on_rider_mounted(_rider: PlayerController) -> void:
	is_on_bike = true
	_transition_camera_to(bicycle)
	mode_changed.emit(true)

func _on_rider_dismounted(_rider: PlayerController) -> void:
	is_on_bike = false
	_transition_camera_to(player)
	mode_changed.emit(false)

func _transition_camera_to(target: Node3D) -> void:
	if not camera_rig or not camera_rig.has_method("set_follow_target"):
		# Fallback: direct camera manipulation
		var camera := get_viewport().get_camera_3d()
		if camera and camera.get_parent().has_method("set_follow_target"):
			camera.get_parent().set_follow_target(target)
		return
	
	# Use camera rig's transition method
	var tween := create_tween()
	tween.tween_method(
		func(t: float): camera_rig.call("blend_to_target", target, t),
		0.0, 1.0, camera_transition_duration
	).set_ease(Tween.EASE_IN_OUT)
