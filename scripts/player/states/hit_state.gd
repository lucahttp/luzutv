# Hit State
# Player was hit by an enemy
extends State

@export var stagger_duration := 0.3

var timer := 0.0

func enter() -> void:
	timer = stagger_duration
	actor.play_animation("hit")
	(actor as PlayerController).disable_hitbox()

func physics_update(delta: float) -> void:
	timer -= delta
	
	if timer <= 0:
		state_machine.transition_to("idle")
	
	# Apply friction to slow down
	var player: PlayerController = actor as PlayerController
	player.velocity.x = move_toward(player.velocity.x, 0, 30.0 * delta)
	player.velocity.z = move_toward(player.velocity.z, 0, 30.0 * delta)
