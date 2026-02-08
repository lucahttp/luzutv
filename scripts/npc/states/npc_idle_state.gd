# NPC Idle State
# NPC is standing around, occasionally looking for the player
extends State

@export var look_interval := 2.0

var timer := 0.0

func enter() -> void:
	actor.play_animation("idle")
	timer = look_interval

func physics_update(delta: float) -> void:
	var npc: NPCController = actor as NPCController
	timer -= delta
	
	# Periodically check for player
	if timer <= 0:
		timer = look_interval
		var player := npc.find_player()
		if player:
			npc.target = player
			state_machine.transition_to("chase")
