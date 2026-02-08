# NPC Attack State
# NPC is attacking the player
extends State

@export var attack_duration := 0.5
@export var attack_windup := 0.2

var timer := 0.0
var has_attacked := false

func enter() -> void:
	timer = attack_duration
	has_attacked = false
	actor.play_animation("attack")

func exit() -> void:
	(actor as NPCController).disable_hitbox()

func physics_update(delta: float) -> void:
	var npc: NPCController = actor as NPCController
	timer -= delta
	
	# Enable hitbox after windup
	if not has_attacked and timer <= (attack_duration - attack_windup):
		has_attacked = true
		npc.enable_hitbox()
	
	# End attack
	if timer <= 0:
		npc.disable_hitbox()
		
		# Check if target still in range
		if npc.target and npc.is_target_in_range(npc.attack_range):
			# Attack again after cooldown
			state_machine.transition_to("attack")
		else:
			state_machine.transition_to("chase")
	
	# Stop moving during attack
	npc.velocity.x = 0
	npc.velocity.z = 0
	
	# Face the target
	if npc.target:
		var direction := (npc.target.global_position - npc.global_position).normalized()
		var target_rotation := atan2(direction.x, direction.z)
		npc.model.rotation.y = lerp_angle(npc.model.rotation.y, target_rotation, 10.0 * delta)
