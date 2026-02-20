# NPC Hit State
# NPC was hit and is staggering
extends State

@export var stagger_duration := 0.3
@export var knockback_force := 5.0

var timer := 0.0

func enter() -> void:
	# Use animation length if available
	var anim_len = (actor as NPCController).get_animation_length("hit")
	timer = max(anim_len, stagger_duration)
	actor.play_animation("hit")
	(actor as NPCController).disable_hitbox()
	
	# Apply knockback
	# Apply knockback
	var npc: NPCController = actor as NPCController
	if npc.target:
		var knockback_dir := (npc.global_position - npc.target.global_position).normalized()
		npc.velocity.x = knockback_dir.x * knockback_force
		npc.velocity.z = knockback_dir.z * knockback_force
		
		# Add score for hit
		if has_node("/root/ScoreManager"):
			var points = $"/root/ScoreManager".points_hit_strong if knockback_force > 10 else $"/root/ScoreManager".points_hit_weak
			$"/root/ScoreManager".add_hit_points(points)

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
