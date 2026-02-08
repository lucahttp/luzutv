# NPC Dead State
# NPC has died
extends State

@export var despawn_delay := 5.0

var timer := 0.0

func enter() -> void:
	timer = despawn_delay
	actor.play_animation("death")
	
	# Disable physics
	var npc: NPCController = actor as NPCController
	npc.set_physics_process(false)

func frame_update(delta: float) -> void:
	timer -= delta
	
	if timer <= 0:
		actor.queue_free()
