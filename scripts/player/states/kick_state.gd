# Kick State
# Player is performing a kick attack
extends State

@export var kick_duration := 0.5

var timer := 0.0

func enter() -> void:
	timer = kick_duration
	actor.play_animation("kick")
	(actor as PlayerController).enable_hitbox()

func exit() -> void:
	(actor as PlayerController).disable_hitbox()

func physics_update(delta: float) -> void:
	var player: PlayerController = actor as PlayerController
	timer -= delta
	
	# End of attack
	if timer <= 0:
		state_machine.transition_to("idle")
	
	# Slight forward movement during attack
	var direction := player.model.global_transform.basis.z.normalized()
	player.velocity.x = direction.x * 3.0
	player.velocity.z = direction.z * 3.0
