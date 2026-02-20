# Orbit Camera
# Third-person camera that follows the player or bicycle
extends Node3D
class_name OrbitCamera

## Follow settings
@export var follow_target: Node3D
@export var follow_distance := 8.0
@export var follow_height := 4.0
@export var follow_speed := 5.0

## Rotation settings
@export var mouse_sensitivity := 0.002
@export var min_pitch := -30.0
@export var max_pitch := 60.0
@export var auto_rotate_speed := 2.0

## Collision
@export var collision_margin := 0.3
@export_flags_3d_physics var collision_mask := 1

## Screen Shake
@export var shake_intensity := 0.0
@export var shake_decay := 5.0
var _current_shake := 0.0

## Internal state
var current_pitch := 0.0
var current_yaw := 0.0
var target_distance := 8.0
var is_auto_rotating := false

@onready var camera: Camera3D = $Camera3D
@onready var collision_ray: RayCast3D = $CollisionRay

func _ready() -> void:
	add_to_group("camera_rig")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	target_distance = follow_distance
	
	if not follow_target:
		await get_tree().process_frame
		follow_target = get_tree().get_first_node_in_group("player")
	
	if collision_ray:
		collision_ray.target_position = Vector3(0, 0, follow_distance)
		collision_ray.collision_mask = collision_mask

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		current_yaw -= event.relative.x * mouse_sensitivity
		current_pitch -= event.relative.y * mouse_sensitivity
		current_pitch = clamp(current_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Screen shake decay
	if _current_shake > 0:
		_current_shake = lerp(_current_shake, 0.0, shake_decay * delta)
		if _current_shake < 0.01:
			_current_shake = 0.0
	
	if not follow_target:
		return
	
	# Auto-rotate behind vehicle when moving
	if is_auto_rotating and follow_target is VehicleBody3D:
		_auto_rotate_behind_vehicle(delta)
	
	# Calculate desired position
	var target_pos := follow_target.global_position + Vector3.UP * follow_height
	
	# Apply rotation con shake
	var shake_offset := Vector3.ZERO
	if _current_shake > 0:
		shake_offset = Vector3(
			randf_range(-_current_shake, _current_shake),
			randf_range(-_current_shake, _current_shake),
			randf_range(-_current_shake * 0.5, _current_shake * 0.5)
		)
	
	var rotation_basis := Basis.from_euler(Vector3(current_pitch, current_yaw, 0))
	var offset := rotation_basis * Vector3(0, 0, target_distance)
	var desired_pos := target_pos + offset + shake_offset
	
	# Handle camera collision
	desired_pos = _handle_collision(target_pos, desired_pos)
	
	# Smooth follow
	global_position = global_position.lerp(desired_pos, follow_speed * delta)
	
	# Look at target
	look_at(target_pos, Vector3.UP)

func _auto_rotate_behind_vehicle(delta: float) -> void:
	var vehicle := follow_target as VehicleBody3D
	if vehicle.linear_velocity.length() > 2.0:
		var vehicle_forward := -vehicle.global_transform.basis.z
		var target_yaw := atan2(vehicle_forward.x, vehicle_forward.z)
		current_yaw = lerp_angle(current_yaw, target_yaw, auto_rotate_speed * delta)

func _handle_collision(from: Vector3, to: Vector3) -> Vector3:
	if not collision_ray:
		return to
	
	var direction := (to - from).normalized()
	var distance := from.distance_to(to)
	collision_ray.global_position = from
	collision_ray.target_position = direction * distance
	collision_ray.force_raycast_update()
	
	if collision_ray.is_colliding():
		var collision_point := collision_ray.get_collision_point()
		var safe_distance := from.distance_to(collision_point) - collision_margin
		return from + direction * max(safe_distance, 1.0)
	
	return to

## Agregar screen shake - llamar desde player controller
func add_shake(amount: float) -> void:
	_current_shake = clamp(amount, 0.0, 1.0)
	shake_intensity = _current_shake

## Set a new follow target
func set_follow_target(target: Node3D, instant := false) -> void:
	follow_target = target
	is_auto_rotating = target is VehicleBody3D
	
	if instant and target:
		var target_pos := target.global_position + Vector3.UP * follow_height
		var rotation_basis := Basis.from_euler(Vector3(current_pitch, current_yaw, 0))
		var offset := rotation_basis * Vector3(0, 0, target_distance)
		global_position = target_pos + offset

func blend_to_target(target: Node3D, _t: float) -> void:
	follow_target = target
	is_auto_rotating = target is VehicleBody3D
