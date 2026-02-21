# Idle State
# Player is standing still
extends State

func enter() -> void:
	actor.play_animation("idle", true)

func physics_update(delta: float) -> void:
	var player: PlayerController = actor as PlayerController
	var direction := player.get_movement_direction()
	
	# Check for state transitions (deadzone to prevent flickering)
	if direction.length() > 0.1:
		if InputHandler.is_run_pressed:
			state_machine.transition_to("run")
		else:
			state_machine.transition_to("walk")
	
	if InputHandler.is_jump_just_pressed:
		state_machine.transition_to("jump")
	
	if InputHandler.is_crouch_pressed:
		state_machine.transition_to("crouch")
	
	if InputHandler.is_attack_just_pressed:
		state_machine.transition_to("punch")
	
	# Apply friction when idle
	player.apply_movement(Vector3.ZERO, delta)
