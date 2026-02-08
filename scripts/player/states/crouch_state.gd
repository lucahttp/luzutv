# Crouch State
# Player is crouching
extends State

func enter() -> void:
	actor.play_animation("crouch_idle")
	(actor as PlayerController).set_crouching(true)

func exit() -> void:
	(actor as PlayerController).set_crouching(false)

func physics_update(delta: float) -> void:
	var player: PlayerController = actor as PlayerController
	var direction := player.get_movement_direction()
	
	# Check for state transitions
	if not Input.is_action_pressed("crouch"):
		if direction.length() > 0:
			state_machine.transition_to("walk")
		else:
			state_machine.transition_to("idle")
		return
	
	# Play appropriate animation
	if direction.length() > 0:
		actor.play_animation("crouch_walk")
	else:
		actor.play_animation("crouch_idle")
	
	# Apply movement (slower when crouching)
	player.apply_movement(direction, delta)
