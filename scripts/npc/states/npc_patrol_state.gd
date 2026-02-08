# NPC Patrol State
# NPC walks between patrol points
extends State

@export var patrol_points: Array[Marker3D] = []
@export var wait_time := 2.0

var current_point_index := 0
var is_waiting := false
var wait_timer := 0.0

func enter() -> void:
	actor.play_animation("walk")
	is_waiting = false

func physics_update(delta: float) -> void:
	var npc: NPCController = actor as NPCController
	
	# Check for player
	var player := npc.find_player()
	if player:
		npc.target = player
		state_machine.transition_to("chase")
		return
	
	# Handle waiting at patrol points
	if is_waiting:
		wait_timer -= delta
		if wait_timer <= 0:
			is_waiting = false
			_next_patrol_point()
			actor.play_animation("walk")
		return
	
	# Move to current patrol point
	if patrol_points.size() > 0:
		var target_pos := patrol_points[current_point_index].global_position
		npc.move_to_position(target_pos, npc.walk_speed, delta)
		
		# Check if reached
		if npc.global_position.distance_to(target_pos) < 1.0:
			is_waiting = true
			wait_timer = wait_time
			actor.play_animation("idle")

func _next_patrol_point() -> void:
	current_point_index = (current_point_index + 1) % patrol_points.size()
