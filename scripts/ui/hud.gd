# HUD Manager
# Manages the heads-up display for player health, speed, etc.
extends CanvasLayer

## Node references
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var health_label: Label = $MarginContainer/VBoxContainer/HealthBar/Label
@onready var speed_label: Label = $MarginContainer/VBoxContainer/SpeedLabel
@onready var mode_label: Label = $MarginContainer/VBoxContainer/ModeLabel
@onready var interaction_hint: Label = $InteractionHint

## References
var player: PlayerController
var bicycle: BicycleController
var transition_manager: TransitionManager

func _ready() -> void:
	# Find references
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	bicycle = get_tree().get_first_node_in_group("bicycle")
	transition_manager = get_tree().get_first_node_in_group("transition_manager") as TransitionManager
	
	if not transition_manager:
		for child in get_tree().root.get_children():
			transition_manager = child.find_child("TransitionManager", true, false) as TransitionManager
			if transition_manager:
				break
	
	# Connect signals
	if player:
		player.health_changed.connect(_on_player_health_changed)
		_on_player_health_changed(player.current_health, player.max_health)
	
	if transition_manager:
		transition_manager.mode_changed.connect(_on_mode_changed)
	
	# Initial state
	mode_label.text = "A PIE"
	speed_label.visible = false
	interaction_hint.visible = false

func _process(_delta: float) -> void:
	_update_speed_display()
	_update_interaction_hint()

func _update_speed_display() -> void:
	if transition_manager and transition_manager.is_on_bike and bicycle:
		speed_label.visible = true
		var speed := bicycle.get_speed_kmh()
		speed_label.text = "%.1f km/h" % speed
	else:
		speed_label.visible = false

func _update_interaction_hint() -> void:
	if not player or not bicycle:
		interaction_hint.visible = false
		return
	
	if transition_manager and transition_manager.is_on_bike:
		# Show dismount hint if slow enough
		if bicycle.linear_velocity.length() < 5.0:
			interaction_hint.visible = true
			interaction_hint.text = "[E] Bajarse de la bici"
		else:
			interaction_hint.visible = false
	else:
		# Show mount hint if near bike
		var distance := player.global_position.distance_to(bicycle.global_position)
		if distance < 2.5:
			interaction_hint.visible = true
			interaction_hint.text = "[E] Subirse a la bici"
		else:
			interaction_hint.visible = false

func _on_player_health_changed(new_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = new_health
	health_label.text = "%d / %d" % [new_health, max_health]

func _on_mode_changed(is_on_bike: bool) -> void:
	if is_on_bike:
		mode_label.text = "BICICLETA"
	else:
		mode_label.text = "A PIE"
