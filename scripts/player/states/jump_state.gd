# Jump State
# Player is jumping or in the air
extends State

var has_jumped := false
var jump_count := 0
var max_jumps := 2
var air_time := 0.0

func enter() -> void:
	has_jumped = false
	jump_count = 0
	air_time = 0.0
	# Animation is handled in physics_update for first frame sync

func physics_update(delta: float) -> void:
	var player: PlayerController = actor as PlayerController
	air_time += delta
	
	# Perform the actual jump on first frame
	if not has_jumped and player.is_on_floor():
		player.jump()
		player.play_animation("jump", false, 1.5)
		has_jumped = true
		jump_count = 1
	
	# Handle double jump
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		player.velocity.y = player.jump_velocity
		player.play_animation("jump", false, 1.8) # Even faster for double jump
		jump_count += 1
	
	# Allow some air control
	var direction := player.get_movement_direction()
	player.apply_movement(direction * 0.5, delta) # Reduced air control
	
	# Transition back when landing
	# We check air_time to avoid instant landing on the same frame as jump
	if player.is_on_floor() and has_jumped and air_time > 0.1:
		if direction.length() > 0:
			if Input.is_action_pressed("run"):
				state_machine.transition_to("run")
			else:
				state_machine.transition_to("walk")
		else:
			state_machine.transition_to("idle")
