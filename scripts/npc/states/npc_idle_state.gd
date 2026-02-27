# NPC Idle State
# NPC is standing around, occasionally looking for the player
extends State

func enter() -> void:
	actor.play_animation("idle")

func physics_update(_delta: float) -> void:
	var npc: NPCController = actor as NPCController
	
	# Buscar jugador
	var player = npc.find_player()
	if player:
		npc.target = player
		state_machine.transition_to("chase")
		return
