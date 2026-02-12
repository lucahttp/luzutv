# Player Controller
# Main controller for Luz - handles movement physics and state coordination
extends CharacterBody3D
class_name PlayerController

## Movement speeds
@export_group("Movement")
@export var walk_speed := 5.0
@export var run_speed := 10.0
@export var crouch_speed := 2.5
@export var acceleration := 15.0
@export var friction := 20.0
@export var rotation_speed := 10.0
@export var walk_anim_speed := 1.2
@export var run_anim_speed := 1.8

## Jump parameters
@export_group("Jump")
@export var jump_velocity := 8.0
@export var gravity_multiplier := 1.0

## Combat parameters
@export_group("Combat")
@export var punch_damage := 10
@export var kick_damage := 15
@export var attack_cooldown := 0.3

## Animation name mapping (state name -> Mixamo FBX animation name)
## Update these if your FBX files have different names
@export_group("Animations")
@export var anim_map: Dictionary = {
	"idle": "idle/mixamo_com",
	"walk": "walking/mixamo_com",
	"run": "running/mixamo_com",
	"jump": "jump/mixamo_com",
	"punch": "Cross Punch/mixamo_com",
	"kick": "Roundhouse Kick/mixamo_com",
	"crouch_idle": "idle/mixamo_com", # Fallback until crouch anim is added
	"crouch_walk": "walking/mixamo_com", # Fallback until crouch walk anim is added
	"hit": "idle/mixamo_com", # Fallback until hit reaction anim is added
	"death": "idle/mixamo_com", # Fallback until death anim is added
	"strafe_left": "left strafe walk/mixamo_com",
	"strafe_right": "right strafe walk/mixamo_com",
	"turn_left": "left turn/mixamo_com",
	"turn_right": "right turn/mixamo_com",
}

## Node references
@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $Model/AnimationPlayer
@onready var model: Node3D = $Model

@onready var hitbox: Area3D = $HitboxPivot/Hitbox
@onready var hurtbox: Area3D = $Hurtbox
@onready var interaction_ray: RayCast3D = $InteractionRay

## Internal state
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_running := false
var is_crouching := false
var can_attack := true
var current_health := 100
var max_health := 100
var is_on_bike := false
var nearby_bike: Node3D = null

## Signals
signal health_changed(new_health: int, max_health: int)
signal died
signal mounted_bike(bike: Node3D)
signal dismounted_bike

func _ready() -> void:
	add_to_group("player")
	hitbox.monitoring = false
	
	# Connect hitbox signal
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(delta: float) -> void:
	if is_on_bike:
		return
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta
	else:
		# Small downward force to keep grounded properly and reset bouncy velocity
		if velocity.y < 0:
			velocity.y = -0.1
	
	move_and_slide()
	
	# Keep model centered on the CharacterBody3D (root motion is extracted by AnimationPlayer)
	if model:
		model.position = Vector3.ZERO

## Get the movement direction based on input
func get_movement_direction() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var camera := get_viewport().get_camera_3d()
	
	if camera:
		# Get camera-relative direction
		var forward := -camera.global_transform.basis.z
		var right := camera.global_transform.basis.x
		forward.y = 0
		right.y = 0
		forward = forward.normalized()
		right = right.normalized()
		return (right * input_dir.x + forward * -input_dir.y).normalized()
	else:
		return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

## Apply horizontal movement with arcade physics feel
func apply_movement(direction: Vector3, delta: float) -> void:
	var target_speed := get_current_speed()
	
	if direction.length() > 0:
		velocity.x = move_toward(velocity.x, direction.x * target_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * target_speed, acceleration * delta)
		
		# Smooth rotation towards movement direction
		var target_rotation := atan2(direction.x, direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_rotation, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

## Get current speed based on state
func get_current_speed() -> float:
	if is_crouching:
		return crouch_speed
	elif is_running:
		return run_speed
	else:
		return walk_speed

## Jump action
func jump() -> void:
	if is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

## Set running state
func set_running(value: bool) -> void:
	is_running = value

## Set crouching state
func set_crouching(value: bool) -> void:
	is_crouching = value
	# TODO: Adjust collision shape for crouching

## Take damage from an attack
func take_damage(amount: int, _attacker: Node3D = null) -> void:
	current_health -= amount
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()
	else:
		state_machine.transition_to("hit")

## Die
func die() -> void:
	died.emit()
	state_machine.transition_to("dead")

## Enable hitbox for attacks
func enable_hitbox() -> void:
	hitbox.monitoring = true

## Disable hitbox
func disable_hitbox() -> void:
	hitbox.monitoring = false

## Check for nearby interactables (bikes, etc.)
func check_interaction() -> void:
	if interaction_ray.is_colliding():
		var collider := interaction_ray.get_collider()
		if collider and collider.is_in_group("bicycle"):
			nearby_bike = collider

## Mount a bicycle
func mount_bike(bike: Node3D) -> void:
	is_on_bike = true
	visible = true # Keep visible, position controlled by bike
	set_physics_process(false)
	mounted_bike.emit(bike)

## Dismount from bicycle
func dismount_from_bike(dismount_position: Vector3) -> void:
	is_on_bike = false
	global_position = dismount_position
	set_physics_process(true)
	dismounted_bike.emit()

## Hitbox connected - we hit something
func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("hurtbox") and area.owner != self:
		var target := area.owner
		if target.has_method("take_damage"):
			var damage := punch_damage if state_machine.get_current_state_name() == "Punch" else kick_damage
			target.take_damage(damage, self)

## Hurtbox connected - we got hit
func _on_hurtbox_area_entered(_area: Area3D) -> void:
	# Damage is applied by the attacker
	pass

## Play animation by name (uses anim_map to translate state names to FBX names)
## Set loop=true for locomotion anims (idle, walk, run)
## Set speed to control playback speed (2.0 = double speed)
func play_animation(anim_name: String, loop: bool = false, speed: float = 1.0) -> void:
	if not animation_player:
		return
	
	# Look up the real animation name from the map
	var real_name: String = anim_map.get(anim_name, anim_name)
	var found_name: String = ""
	
	if animation_player.has_animation(real_name):
		found_name = real_name
	elif animation_player.has_animation(anim_name):
		found_name = anim_name
	else:
		push_warning("Animation not found: '%s' (mapped: '%s')" % [anim_name, real_name])
		return
	
	# Set loop mode on the animation resource
	var anim: Animation = animation_player.get_animation(found_name)
	if anim:
		anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	
	# Set playback speed
	animation_player.speed_scale = speed
	
	# Play with crossfade blend to avoid blipping
	if animation_player.current_animation != found_name:
		animation_player.play(found_name, 0.2)

## Get the duration of an animation in seconds
func get_animation_length(anim_name: String) -> float:
	if not animation_player:
		return 0.5
	var real_name: String = anim_map.get(anim_name, anim_name)
	if animation_player.has_animation(real_name):
		return animation_player.get_animation(real_name).length
	elif animation_player.has_animation(anim_name):
		return animation_player.get_animation(anim_name).length
	return 0.5
