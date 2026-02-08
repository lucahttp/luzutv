# Bicycle Controller
# Arcade-style bicycle physics using VehicleBody3D
extends VehicleBody3D
class_name BicycleController

## Engine and movement
@export_group("Engine")
@export var max_engine_force := 200.0
@export var max_brake_force := 50.0
@export var acceleration_curve := 1.5  # How quickly it reaches max speed
@export var coast_deceleration := 5.0  # Slowdown when not pedaling

## Steering
@export_group("Steering")
@export var max_steer_angle := 0.4
@export var steer_speed := 4.0
@export var speed_steer_reduction := 0.5  # Reduce steering at high speed

## Visual effects
@export_group("Visuals")
@export var max_lean_angle := 20.0  # Degrees
@export var lean_speed := 8.0

## Node references
@onready var front_wheel: VehicleWheel3D = $FrontWheel
@onready var rear_wheel: VehicleWheel3D = $RearWheel
@onready var rider_position: Marker3D = $RiderPosition
@onready var dismount_position: Marker3D = $DismountPosition
@onready var mesh: Node3D = $BikeModel
@onready var interaction_area: Area3D = $InteractionArea

## State
var current_steer := 0.0
var current_lean := 0.0
var is_occupied := false
var rider: PlayerController = null

## Signals
signal rider_mounted(rider: PlayerController)
signal rider_dismounted(rider: PlayerController)

func _ready() -> void:
	add_to_group("bicycle")
	
	# Configure wheels
	_setup_wheels()

func _setup_wheels() -> void:
	# Front wheel - steering only
	front_wheel.use_as_traction = false
	front_wheel.use_as_steering = true
	front_wheel.wheel_radius = 0.35
	front_wheel.suspension_stiffness = 60.0
	front_wheel.suspension_travel = 0.15
	front_wheel.damping_compression = 0.8
	front_wheel.damping_relaxation = 2.0
	front_wheel.wheel_friction_slip = 2.0
	
	# Rear wheel - traction
	rear_wheel.use_as_traction = true
	rear_wheel.use_as_steering = false
	rear_wheel.wheel_radius = 0.35
	rear_wheel.suspension_stiffness = 60.0
	rear_wheel.suspension_travel = 0.15
	rear_wheel.damping_compression = 0.8
	rear_wheel.damping_relaxation = 2.0
	rear_wheel.wheel_friction_slip = 2.5

func _physics_process(delta: float) -> void:
	if not is_occupied:
		_apply_idle_brake()
		return
	
	_handle_acceleration()
	_handle_steering(delta)
	_apply_visual_lean(delta)
	_update_rider_position()

func _apply_idle_brake() -> void:
	# Apply slight brake when no rider
	brake = max_brake_force * 0.3
	engine_force = 0
	steering = move_toward(steering, 0, 0.1)

func _handle_acceleration() -> void:
	var throttle: float = Input.get_action_strength("accelerate")
	var brake_input: float = Input.get_action_strength("brake")
	
	# Apply engine force with curve for arcade feel
	if throttle > 0:
		var speed_factor: float = clampf(1.0 - (linear_velocity.length() / 20.0), 0.2, 1.0)
		engine_force = throttle * max_engine_force * speed_factor * acceleration_curve
		brake = 0.0
	elif brake_input > 0:
		engine_force = 0.0
		brake = brake_input * max_brake_force
	else:
		# Coasting - gradual slowdown
		engine_force = 0.0
		brake = coast_deceleration

func _handle_steering(delta: float) -> void:
	var steer_input: float = Input.get_axis("steer_right", "steer_left")
	
	# Reduce steering at high speeds for stability
	var current_speed: float = linear_velocity.length()
	var speed_factor: float = 1.0 - clampf(current_speed / 15.0, 0.0, speed_steer_reduction)
	var effective_max_steer: float = max_steer_angle * speed_factor
	
	# Smooth steering interpolation
	var target_steer: float = steer_input * effective_max_steer
	current_steer = move_toward(current_steer, target_steer, steer_speed * delta)
	steering = current_steer

func _apply_visual_lean(delta: float) -> void:
	# Calculate lean based on steering and speed
	var current_speed: float = linear_velocity.length()
	var speed_factor: float = clampf(current_speed / 10.0, 0.0, 1.0)
	var target_lean: float = -current_steer * max_lean_angle * speed_factor
	
	# Smooth lean interpolation
	current_lean = lerp(current_lean, target_lean, lean_speed * delta)
	
	# Apply to mesh (visual only, doesn't affect physics)
	if mesh:
		mesh.rotation_degrees.z = current_lean

func _update_rider_position() -> void:
	if rider and rider_position:
		rider.global_transform = rider_position.global_transform

## Mount the bicycle
func mount(player: PlayerController) -> void:
	if is_occupied:
		return
	
	is_occupied = true
	rider = player
	
	# Reparent player to bike
	var original_parent := rider.get_parent()
	if original_parent:
		original_parent.remove_child(rider)
	add_child(rider)
	
	# Position and configure player
	rider.global_transform = rider_position.global_transform
	rider.mount_bike(self)
	rider.visible = true
	
	rider_mounted.emit(rider)

## Dismount from the bicycle
func dismount() -> PlayerController:
	if not is_occupied or not rider:
		return null
	
	is_occupied = false
	var dismounting_rider := rider
	rider = null
	
	# Reparent player back to world
	remove_child(dismounting_rider)
	get_tree().root.add_child(dismounting_rider)
	
	# Position at dismount point
	dismounting_rider.global_position = dismount_position.global_position
	dismounting_rider.dismount_from_bike(dismount_position.global_position)
	
	rider_dismounted.emit(dismounting_rider)
	return dismounting_rider

## Get current speed in km/h (for UI)
func get_speed_kmh() -> float:
	return linear_velocity.length() * 3.6

## Check if player is nearby
func is_player_nearby() -> bool:
	if not interaction_area:
		return false
	
	for body in interaction_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false
