# NPC Hit State
# NPC was hit and is staggering
extends State

@export var stagger_duration := 0.3

var timer := 0.0

func enter() -> void:
	# Use animation length if available
	var anim_len = (actor as NPCController).get_animation_length("hit")
	timer = max(anim_len, stagger_duration)
	actor.play_animation("hit")
	(actor as NPCController).disable_hitbox()
	
	# Apply rotation to look at attacker
	var npc: NPCController = actor as NPCController
	if npc.target:
		# Extract target position but keep it on same Y level to avoid tilting up/down
		var look_pos = npc.target.global_position
		look_pos.y = npc.global_position.y
		# Encarar violentamente (1 frame) con una rotación segura
		if npc.global_position.distance_to(look_pos) > 0.1:
			npc.model.look_at(look_pos, Vector3.UP, true)

func physics_update(delta: float) -> void:
	var npc: NPCController = actor as NPCController
	timer -= delta
	
	# Apply friction from the actual built-in physics
	npc.velocity.x = move_toward(npc.velocity.x, 0, 20.0 * delta)
	npc.velocity.z = move_toward(npc.velocity.z, 0, 20.0 * delta)
	
	if timer <= 0:
		if npc.target:
			state_machine.transition_to("chase")
		else:
			state_machine.transition_to("idle")
