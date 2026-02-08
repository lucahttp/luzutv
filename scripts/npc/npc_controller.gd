# Base NPC Controller
# Base class for all NPCs in the game (enemies, pedestrians, etc.)
extends CharacterBody3D
class_name NPCController

## Movement
@export_group("Movement")
@export var walk_speed := 2.0
@export var run_speed := 5.0
@export var acceleration := 10.0
@export var rotation_speed := 5.0

## Combat
@export_group("Combat")
@export var max_health := 50
@export var attack_damage := 5
@export var attack_range := 1.5
@export var attack_cooldown := 1.0
@export var detection_range := 10.0
@export var lose_target_range := 15.0

## State
var current_health: int
var target: Node3D = null
var can_attack := true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

## Node references
@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $Model/AnimationPlayer
@onready var model: Node3D = $Model
@onready var hitbox: Area3D = $HitboxPivot/Hitbox
@onready var hurtbox: Area3D = $Hurtbox
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

## Signals
signal health_changed(new_health: int, max_health: int)
signal died

func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	hitbox.monitoring = false
	
	# Connect signals
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	
	# Configure navigation
	if nav_agent:
		nav_agent.path_desired_distance = 0.5
		nav_agent.target_desired_distance = attack_range * 0.8

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()

## Move towards a target position using navigation
func move_to_position(target_pos: Vector3, speed: float, delta: float) -> void:
	if not nav_agent:
		return
	
	nav_agent.target_position = target_pos
	
	if nav_agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
		return
	
	var next_pos := nav_agent.get_next_path_position()
	var direction := (next_pos - global_position).normalized()
	direction.y = 0
	
	velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
	
	# Rotate towards movement
	if direction.length() > 0.1:
		var target_rotation := atan2(direction.x, direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_rotation, rotation_speed * delta)

## Check if target is in range
func is_target_in_range(range_distance: float) -> bool:
	if not target:
		return false
	return global_position.distance_to(target.global_position) <= range_distance

## Look for the player
func find_player() -> Node3D:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var distance := global_position.distance_to(player.global_position)
		if distance <= detection_range:
			return player
	return null

## Take damage
func take_damage(amount: int, attacker: Node3D = null) -> void:
	current_health -= amount
	health_changed.emit(current_health, max_health)
	
	# Set attacker as target if we don't have one
	if not target and attacker:
		target = attacker
	
	if current_health <= 0:
		die()
	else:
		state_machine.transition_to("hit")

## Die
func die() -> void:
	died.emit()
	state_machine.transition_to("dead")
	# Disable collision
	set_collision_layer_value(3, false)

## Enable attack hitbox
func enable_hitbox() -> void:
	hitbox.monitoring = true

## Disable attack hitbox
func disable_hitbox() -> void:
	hitbox.monitoring = false

## Hitbox hit something
func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("hurtbox") and area.owner != self:
		var target_node := area.owner
		if target_node.has_method("take_damage"):
			target_node.take_damage(attack_damage, self)

## Play animation
func play_animation(anim_name: String) -> void:
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
