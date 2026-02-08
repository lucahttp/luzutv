# NPC Hit State
# NPC was hit and is staggering
extends State

@export var stagger_duration := 0.3
@export var knockback_force := 5.0

var timer := 0.0

func enter() -> void:
	timer = stagger_duration
	actor.play_animation("hit")
	(actor as NPCController).disable_hitbox()
	
	# Apply knockback
	var npc: NPCController = actor as NPCController
	if npc.target:
		var knockback_dir := (npc.global_position - npc.target.global_position).normalized()
		npc.velocity.x = knockback_dir.x * knockback_force
		npc.velocity.z = knockback_dir.z * knockback_force

func physics_update(delta: float) -> void:
	var npc: NPCController = actor as NPCController
	timer -= delta
	
	# Apply friction
	npc.velocity.x = move_toward(npc.velocity.x, 0, 20.0 * delta)
	npc.velocity.z = move_toward(npc.velocity.z, 0, 20.0 * delta)
	
	if timer <= 0:
		if npc.target:
			state_machine.transition_to("chase")
		else:
			state_machine.transition_to("idle")
