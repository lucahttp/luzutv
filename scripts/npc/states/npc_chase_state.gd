# NPC Chase State
# NPC is chasing the player
extends State

func enter() -> void:
	actor.play_animation("run")

func physics_update(delta: float) -> void:
	var npc: NPCController = actor as NPCController
	
	# Verificar si perdió objetivo
	if not npc.target or not is_instance_valid(npc.target):
		npc.target = null
		state_machine.transition_to("idle")
		return
	
	# Verificar distancia
	var distance := npc.global_position.distance_to(npc.target.global_position)
	if distance > npc.lose_target_range:
		npc.target = null
		npc.player_detected = false
		state_machine.transition_to("idle")
		return
	
	# Atacar si está cerca
	if distance <= npc.attack_range:
		state_machine.transition_to("attack")
		return
	
	# Perseguir
	npc.move_to_position(npc.target.global_position, npc.run_speed, delta)
