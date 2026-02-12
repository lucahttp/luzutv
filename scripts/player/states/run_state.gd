# Run State
# Player is running
extends State

func enter() -> void:
	actor.play_animation("run", true, (actor as PlayerController).run_anim_speed)
	(actor as PlayerController).set_running(true)

func exit() -> void:
	(actor as PlayerController).set_running(false)

func physics_update(delta: float) -> void:
	var player: PlayerController = actor as PlayerController
	var direction := player.get_movement_direction()
	
	# Check for state transitions
	if direction.length() < 0.1:
		state_machine.transition_to("idle")
		return
	
	if not Input.is_action_pressed("run"):
		state_machine.transition_to("walk")
		return
	
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("jump")
		return
	
	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to("punch")
		return
	
	# Apply movement
	player.apply_movement(direction, delta)
