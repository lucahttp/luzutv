# Walk State
# Player is walking
extends State

func enter() -> void:
	actor.play_animation("walk")
	(actor as PlayerController).set_running(false)

func physics_update(delta: float) -> void:
	var player: PlayerController = actor as PlayerController
	var direction := player.get_movement_direction()
	
	# Check for state transitions
	if direction.length() == 0:
		state_machine.transition_to("idle")
		return
	
	if Input.is_action_pressed("run"):
		state_machine.transition_to("run")
		return
	
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("jump")
		return
	
	if Input.is_action_pressed("crouch"):
		state_machine.transition_to("crouch")
		return
	
	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to("punch")
		return
	
	# Apply movement
	player.apply_movement(direction, delta)
