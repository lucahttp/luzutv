# Walk State
# Player is walking
extends State

func enter() -> void:
	actor.play_animation("walk", true, (actor as PlayerController).walk_anim_speed)
	(actor as PlayerController).set_running(false)

func physics_update(delta: float) -> void:
	var player: PlayerController = actor as PlayerController
	var direction := player.get_movement_direction()
	
	# Check for state transitions (deadzone to prevent flickering)
	if direction.length() < 0.1:
		state_machine.transition_to("idle")
		return
	
	if InputHandler.is_run_pressed:
		state_machine.transition_to("run")
		return
	
	if InputHandler.is_jump_just_pressed:
		state_machine.transition_to("jump")
		return
	
	if InputHandler.is_crouch_pressed:
		state_machine.transition_to("crouch")
		return
	
	if InputHandler.is_attack_just_pressed:
		state_machine.transition_to("punch")
		return
	
	# Apply movement
	player.apply_movement(direction, delta)
