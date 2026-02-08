# Jump State
# Player is jumping or in the air
extends State

var has_jumped := false

func enter() -> void:
	has_jumped = false
	actor.play_animation("jump")

func physics_update(delta: float) -> void:
	var player: PlayerController = actor as PlayerController
	
	# Perform the actual jump on first frame
	if not has_jumped and player.is_on_floor():
		player.jump()
		has_jumped = true
	
	# Allow some air control
	var direction := player.get_movement_direction()
	player.apply_movement(direction * 0.5, delta)  # Reduced air control
	
	# Transition back when landing
	if player.is_on_floor() and has_jumped:
		if direction.length() > 0:
			if Input.is_action_pressed("run"):
				state_machine.transition_to("run")
			else:
				state_machine.transition_to("walk")
		else:
			state_machine.transition_to("idle")
