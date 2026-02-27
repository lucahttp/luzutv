# Kick State
# Player is performing a kick attack
extends State

var timer := 0.0

func enter() -> void:
	actor.play_animation("kick", false, 2.0) # 2x speed
	timer = (actor as PlayerController).get_animation_length("kick") / 2.0
	(actor as PlayerController).enable_hitbox()

func exit() -> void:
	(actor as PlayerController).disable_hitbox()

func physics_update(delta: float) -> void:
	var player: PlayerController = actor as PlayerController
	timer -= delta
	
	var direction := player.get_movement_direction()
	# End of attack
	if timer <= 0:
		if direction.length() > 0:
			if InputHandler.is_run_pressed:
				state_machine.transition_to("run")
			else:
				state_machine.transition_to("walk")
		else:
			state_machine.transition_to("idle")
		return
	
	# Apply gravity if in the air
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * player.gravity_multiplier * delta
	
	# Slight forward movement during attack
	if player.is_on_floor():
		var forward_dir := player.model.global_transform.basis.z.normalized()
		player.velocity.x = forward_dir.x * 3.0
		player.velocity.z = forward_dir.z * 3.0
