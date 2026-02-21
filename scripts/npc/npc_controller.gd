# Base NPC Controller - VERSIÓN MEJORADA
# Base class for all NPCs in the game (enemies, pedestrians, etc.)
extends CharacterBody3D
class_name NPCController

## Movement
@export_group("Movement")
@export var walk_speed := 2.0
@export var run_speed := 5.0
@export var acceleration := 10.0
@export var rotation_speed := 5.0
@export var material_override: Material

## Combat
@export_group("Combat")
@export var max_health := 50
@export var attack_damage := 5
@export var attack_range := 1.5
@export var attack_cooldown := 1.0
@export var detection_range := 10.0
@export var lose_target_range := 15.0
@export var knockback_resistance := 0.0
@export var knockback_decay := 15.0

## AI - Visión
@export_group("AI - Vision")
@export var vision_angle := 90.0 # Ángulo de visión en grados
@export var hearing_range := 8.0 # Rango de audición
@export var reaction_time := 0.3 # Tiempo de reacción

## State
var current_health: int
var target: Node3D = null
var can_attack := true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var knockback_velocity := Vector3.ZERO
var player_detected := false
var last_known_position: Vector3 = Vector3.ZERO

## Node references
@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $Model/AnimationPlayer
@onready var model: Node3D = $Model
@onready var hitbox: Area3D = $HitboxPivot/Hitbox
@onready var hurtbox: Area3D = $Hurtbox
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var vision_ray: RayCast3D = $VisionRay if has_node("VisionRay") else null

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
	
	# Configurar vision ray si existe
	if vision_ray:
		vision_ray.collide_with_bodies = false
		vision_ray.collide_with_areas = true

	# Apply material override if set (fix for missing textures)
	# Escala 2x para enemigos visible pero no exagerados
	scale = Vector3(2, 2, 2)
	
	if material_override:
		_apply_material_override(model)

func _apply_material_override(node: Node) -> void:
	if node is MeshInstance3D:
		node.material_override = material_override
	
	for child in node.get_children():
		_apply_material_override(child)

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Combine movement velocity with knockback
	var final_velocity = velocity + knockback_velocity
	velocity = final_velocity
	move_and_slide()
	
	# Decay knockback
	knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_decay * delta)
	
	# Actualizar detección de jugador
	_update_awareness()

## Detección de visión mejorada
func _update_awareness() -> void:
	if target and is_instance_valid(target):
		# Si ya tenía detection, mantenerlo un tiempo
		if player_detected:
			last_known_position = target.global_position
			# Verificar si todavía puede ver/oir
			if not can_see_player() and not can_hear_player():
				# Pérdida gradual - buscar por un tiempo
				if global_position.distance_to(last_known_position) > lose_target_range:
					player_detected = false
					target = null
		else:
			# Nuevo avistamiento
			if can_see_player() or can_hear_player():
				player_detected = true
				target = get_tree().get_first_node_in_group("player")
				last_known_position = target.global_position

func can_see_player() -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return false
	
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	
	if distance > detection_range:
		return false
	
	# Verificar ángulo de visión
	var forward = - model.global_transform.basis.z if model else global_transform.basis.z
	forward.y = 0
	to_player.y = 0
	
	var angle = rad_to_deg(forward.angle_to(to_player))
	if angle > vision_angle / 2:
		return false
	
	# Raycast para línea de vista
	if vision_ray:
		vision_ray.target_position = vision_ray.to_local(player.global_position + Vector3(0, 1, 0)) # Aim at chest/head
		vision_ray.force_raycast_update()
		var collider = vision_ray.get_collider()
		return collider and (collider == player or collider == player.get_node_or_null("Hurtbox") or (collider is Area3D and collider.owner == player))
	
	return true # Fallback si no hay ray

func can_hear_player() -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return false
	
	var player_vel = player.velocity.length()
	var distance = global_position.distance_to(player.global_position)
	
	# El jugador hace más ruido corriendo
	var hearing_threshold = hearing_range * (2.0 if player_vel > 7 else 1.0)
	
	return distance < hearing_threshold

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
		model.rotation.y = lerp_angle(model.rotation.y, target_rotation, rotation_speed * 0.1)

## Check if target is in range
func is_target_in_range(range_distance: float) -> bool:
	if not target:
		return false
	return global_position.distance_to(target.global_position) <= range_distance

## Look for the player - VERSIÓN MEJORADA
func find_player() -> Node3D:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		if can_see_player() or can_hear_player():
			player_detected = true
			last_known_position = player.global_position
			return player
	return null

## Take damage
func take_damage(amount: int, attacker: Node3D = null) -> void:
	current_health -= amount
	health_changed.emit(current_health, max_health)
	
	# Sonido de impacto
	if has_node("/root/AudioManager"):
		$"/root/AudioManager".play_hit()
	
	# Set attacker as target
	if attacker:
		target = attacker
		player_detected = true
		last_known_position = attacker.global_position
	
	if current_health <= 0:
		die()
	else:
		# Apply knockback
		if attacker:
			var knock_dir := (global_position - attacker.global_position).normalized()
			knock_dir.y = 0.4
			
			var force := 8.0 * (1.0 - knockback_resistance)
			knockback_velocity = knock_dir * force
		
		state_machine.transition_to("hit")

## Die
func die() -> void:
	# Score
	if has_node("/root/ScoreManager"):
		$"/root/ScoreManager".add_enemy_killed("basic")
	
	# Sonido
	if has_node("/root/AudioManager"):
		$"/root/AudioManager".play_death()
	
	died.emit()
	state_machine.transition_to("dead")
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

## Animation Mapping
@export var anim_map: Dictionary = {
	"idle": "Idle_fighting_remap",
	"patrol": "Strut Walking_remap",
	"chase": "Running_remap",
	"attack": "Punching_remap",
	"hit": "Hand Raising_remap",
	"dead": "Dying_remap",
}

## Play animation by name
func play_animation(anim_name: String, loop: bool = false, speed: float = 1.0) -> void:
	if not animation_player:
		return
	
	var real_name: String = anim_map.get(anim_name, anim_name)
	var found_name: String = ""
	
	if animation_player.has_animation(real_name):
		found_name = real_name
	elif animation_player.has_animation(anim_name):
		found_name = anim_name
	else:
		push_warning("NPC Animation not found: '%s' (mapped: '%s')" % [anim_name, real_name])
		return
	
	var anim: Animation = animation_player.get_animation(found_name)
	if anim:
		anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	
	animation_player.speed_scale = speed
	if animation_player.current_animation != found_name:
		animation_player.play(found_name, 0.2)

## Get animation duration
func get_animation_length(anim_name: String) -> float:
	if not animation_player:
		return 0.5
	var real_name: String = anim_map.get(anim_name, anim_name)
	if animation_player.has_animation(real_name):
		return animation_player.get_animation(real_name).length
	elif animation_player.has_animation(anim_name):
		return animation_player.get_animation(anim_name).length
	return 0.5
