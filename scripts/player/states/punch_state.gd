# Punch State
# Player is performing a punch attack
extends State

@export var combo_window := 0.3 # Time before end to allow combo input

var timer := 0.0
var punch_duration := 0.0
var can_combo := false

func enter() -> void:
	can_combo = false
	actor.play_animation("punch", false, 2.0) # 2x speed
	# Timer = real length / speed
	punch_duration = (actor as PlayerController).get_animation_length("punch") / 2.0
	timer = punch_duration
	(actor as PlayerController).enable_hitbox()

func exit() -> void:
	(actor as PlayerController).disable_hitbox()

func physics_update(delta: float) -> void:
	var player: PlayerController = actor as PlayerController
	timer -= delta
	
	# Enable combo window near the end
	if timer <= combo_window:
		can_combo = true
	
	# Check for combo input
	if can_combo and Input.is_action_just_pressed("attack"):
		state_machine.transition_to("kick")
		return
	
	# End of attack - wait for full animation
	if timer <= 0:
		state_machine.transition_to("idle")
	
	# Slight forward movement during attack
	var direction := player.model.global_transform.basis.z.normalized()
	player.velocity.x = direction.x * 2.0
	player.velocity.z = direction.z * 2.0
