# Loading Manager
# Maneja la carga con pantalla de carga simple
extends Node

var loading_screen_scene: PackedScene
var main_scene_path := "res://scenes/main.tscn"
var _loading_screen = null

func _ready() -> void:
	loading_screen_scene = preload("res://scenes/ui/loading_screen.tscn")

func load_main_scene() -> void:
	# Crear pantalla de carga
	_loading_screen = loading_screen_scene.instantiate()
	get_tree().root.add_child(_loading_screen)
	_loading_screen.visible = true
	
	# Forzar actualización visual
	get_tree().process_frame
	
	# Usar call_deferred para permitir que la UI se dibuje
	call_deferred("_continue_loading")

func _continue_loading() -> void:
	# Cargar la escena principal
	var main_scene = load(main_scene_path)
	var main_instance = main_scene.instantiate()
	
	# Agregar al árbol
	get_tree().root.add_child(main_instance)
	
	# Esperar un poco para que se genere la ciudad (simulado)
	await get_tree().create_timer(2.0).timeout
	
	# Ocultar pantalla de carga
	if _loading_screen:
		_loading_screen.visible = false
		_loading_screen.queue_free()
		_loading_screen = null
	
	# Liberar el menú principal si existe
	var main_menu = get_tree().get_first_node_in_group("main_menu")
	if main_menu:
		main_menu.queue_free()
