# Score Manager - AUTOLOAD
# Gestiona puntuación y combos
extends Node

signal score_updated(new_score: int, points_added: int)
signal combo_updated(combo: int, multiplier: float)
signal enemy_killed(points: int, enemy_type: String)

var score := 0
var combo := 0
var high_score := 0
var _combo_timer: Timer

# Puntos por tipo de enemigo
var points_basic := 100
var points_strong := 250
var points_boss := 500
var points_hit_weak := 10
var points_hit_strong := 50

func _ready() -> void:
	_combo_timer = Timer.new()
	_combo_timer.wait_time = 2.5
	_combo_timer.one_shot = true
	add_child(_combo_timer)
	_combo_timer.timeout.connect(_on_combo_timeout)

func add_enemy_killed(enemy_type: String = "basic") -> void:
	combo += 1
	_combo_timer.start()
	
	var base_points = points_basic
	match enemy_type:
		"strong": base_points = points_strong
		"boss": base_points = points_boss
	
	# Multiplicador por combo
	var multiplier = 1.0 + (combo * 0.1)
	var final_points = int(base_points * multiplier)
	
	score += final_points
	enemy_killed.emit(final_points, enemy_type)
	score_updated.emit(score, final_points)
	combo_updated.emit(combo, multiplier)
	
	if score > high_score:
		high_score = score

func add_hit_points(amount: int) -> void:
	combo += 1
	_combo_timer.start()
	
	# Multiplicador por combo reducido para golpes simples
	var multiplier = 1.0 + (combo * 0.05)
	var final_points = int(amount * multiplier)
	
	score += final_points
	score_updated.emit(score, final_points)
	combo_updated.emit(combo, multiplier)
	
	if score > high_score:
		high_score = score

func reset_game() -> void:
	score = 0
	combo = 0
	score_updated.emit(score, 0)

func _on_combo_timeout() -> void:
	combo = 0
	combo_updated.emit(combo, 1.0)
