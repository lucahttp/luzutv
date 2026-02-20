# Enemy Spawner
# Maneja el spawn aleatorio de enemigos en el mapa
extends Node

@export var enemy_scene: PackedScene
@export var max_enemies := 10
@export var spawn_radius := 50.0
@export var spawn_interval := 5.0
@export var min_distance_from_player := 15.0

var spawn_timer: Timer
var current_enemies: Array = []

func _ready() -> void:
	# Cargar la escena del enemigo si no está asignada
	if not enemy_scene:
		enemy_scene = load("res://scenes/npcs/enemy_base.tscn")
	
	if not enemy_scene:
		push_error("EnemySpawner: No se pudo cargar la escena del enemigo")
		return
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer)
	add_child(spawn_timer)

func _on_spawn_timer() -> void:
	if current_enemies.size() >= max_enemies:
		return
	
	# Limpiar enemigos muertos de la lista
	current_enemies = current_enemies.filter(func(e): return is_instance_valid(e))
	
	if current_enemies.size() >= max_enemies:
		return
	
	_spawn_enemy()

func _spawn_enemy() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("EnemySpawner: No se encontró el jugador")
		return
	
	# Verificar que la escena esté cargada
	if not enemy_scene:
		push_error("EnemySpawner: enemy_scene es null")
		return
	
	# Encontrar posición aleatoria
	var spawn_pos = _get_random_spawn_position(player.global_position)
	
	var enemy = enemy_scene.instantiate()
	# Poner al enemigo en posición correcta (y = 0 es el suelo)
	enemy.global_position = Vector3(spawn_pos.x, 0, spawn_pos.z)
	enemy.died.connect(_on_enemy_died)
	
	get_parent().add_child(enemy)
	current_enemies.append(enemy)
	print("EnemySpawner: Enemigo spawneado en ", enemy.global_position)

func _get_random_spawn_position(player_pos: Vector3) -> Vector3:
	var attempts = 0
	var max_attempts = 20
	
	while attempts < max_attempts:
		var angle = randf() * TAU
		var distance = randf_range(spawn_radius * 0.3, spawn_radius)
		var offset = Vector3(cos(angle), 0, sin(angle)) * distance
		var potential_pos = player_pos + offset
		
		# Verificar que no esté muy cerca del jugador
		if potential_pos.distance_to(player_pos) < min_distance_from_player:
			attempts += 1
			continue
		
		# Verificar que esté en el suelo (y = 0)
		potential_pos.y = 0
		return potential_pos
	
	# Si no encuentra buena posición, ponerlo lejos
	return player_pos + Vector3(randf_range(-spawn_radius, spawn_radius), 0, randf_range(-spawn_radius, spawn_radius))

func _on_enemy_died() -> void:
	# La limpieza se hace en el siguiente timer
	pass

func clear_all_enemies() -> void:
	for enemy in current_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	current_enemies.clear()
