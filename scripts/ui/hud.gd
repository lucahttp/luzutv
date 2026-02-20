# HUD Manager
# Manages the heads-up display for player health, speed, etc.
extends CanvasLayer

@onready var health_bar: ProgressBar = $LeftPanel/VBoxContainer/HealthBar
@onready var health_label: Label = $LeftPanel/VBoxContainer/HealthBar/HealthLabel
@onready var score_value: Label = $LeftPanel/VBoxContainer/ScoreContainer/ScoreValue
@onready var combo_value: Label = $LeftPanel/VBoxContainer/ComboContainer/ComboValue
@onready var mode_value: Label = $LeftPanel/VBoxContainer/ModeContainer/ModeValue
@onready var interaction_hint: Label = $InteractionHint

var player: PlayerController
var bicycle: BicycleController
var transition_manager: TransitionManager

func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	bicycle = get_tree().get_first_node_in_group("bicycle")
	transition_manager = get_tree().get_first_node_in_group("transition_manager") as TransitionManager
	
	if not transition_manager:
		for child in get_tree().root.get_children():
			transition_manager = child.find_child("TransitionManager", true, false) as TransitionManager
			if transition_manager:
				break
	
	if player:
		player.health_changed.connect(_on_player_health_changed)
		_on_player_health_changed(player.current_health, player.max_health)
	
	if transition_manager:
		transition_manager.mode_changed.connect(_on_mode_changed)
	
	mode_value.text = "A PIE"
	interaction_hint.visible = false

func _process(_delta: float) -> void:
	_update_combo_display()
	_update_score_display()
	_update_interaction_hint()

func _update_combo_display() -> void:
	if has_node("/root/ScoreManager"):
		var combo: int = $"/root/ScoreManager".combo
		combo_value.text = "x%d" % max(1, combo)

func _update_score_display() -> void:
	if has_node("/root/ScoreManager"):
		var score: int = $"/root/ScoreManager".score
		score_value.text = str(score)

func _update_interaction_hint() -> void:
	if not player or not bicycle:
		interaction_hint.visible = false
		return
	
	if transition_manager and transition_manager.is_on_bike:
		if bicycle.linear_velocity.length() < 5.0:
			interaction_hint.visible = true
			interaction_hint.text = "[E] Bajarse de la bici"
		else:
			interaction_hint.visible = false
	else:
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
		mode_value.text = "BICICLETA"
	else:
		mode_value.text = "A PIE"
