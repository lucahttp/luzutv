# Audio Manager - AUTOLOAD
# Maneja todos los sonidos del juego
extends Node

# Rutas de sonidos (configurables desde el editor)
@export var footstep_sounds: Array[AudioStream] = [preload("res://assets/audio/footstep1.wav")]
@export var punch_sounds: Array[AudioStream] = [preload("res://assets/audio/punch1.wav")]
@export var hit_sounds: Array[AudioStream] = [preload("res://assets/audio/bodyhit1.wav")]
@export var kick_sounds: Array[AudioStream] = [preload("res://assets/audio/kick1.wav")]
@export var death_sounds: Array[AudioStream] = [preload("res://assets/audio/death1.wav")]
@export var music_stream: AudioStream = preload("res://assets/audio/cityambiance1.wav")

# Configuración
var footstep_interval_walk := 0.4
var footstep_interval_run := 0.25
var _footstep_timer := 0.0

# Players
var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _sfx_bus_idx: int = 0
var _music_bus_idx: int = 1

func _ready() -> void:
	_sfx_bus_idx = AudioServer.get_bus_index("SFX")
	_music_bus_idx = AudioServer.get_bus_index("Music")
	
	# Music player
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	if _music_bus_idx >= 0:
		_music_player.bus = AudioServer.get_bus_name(_music_bus_idx)
	add_child(_music_player)
	
	# SFX pool de 4 players
	for i in range(4):
		var p := AudioStreamPlayer.new()
		p.name = "SFX_%d" % i
		if _sfx_bus_idx >= 0:
			p.bus = AudioServer.get_bus_name(_sfx_bus_idx)
		add_child(p)
		_sfx_players.append(p)

func _process(delta: float) -> void:
	_footstep_timer -= delta

# Llamar desde player controller
func process_footsteps(_delta: float, is_running: bool) -> void:
	if _footstep_timer <= 0:
		play_footstep(is_running)

func play_footstep(is_running: bool = false) -> void:
	if footstep_sounds.is_empty():
		return
	_footstep_timer = footstep_interval_run if is_running else footstep_interval_walk
	_play_random_sfx(footstep_sounds, -8.0)

func play_punch() -> void:
	if punch_sounds.is_empty():
		return
	_play_random_sfx(punch_sounds, -3.0)

func play_kick() -> void:
	if kick_sounds.is_empty():
		return
	_play_random_sfx(kick_sounds, -2.0)

func play_hit() -> void:
	if hit_sounds.is_empty():
		return
	_play_random_sfx(hit_sounds, -2.0)

func play_death() -> void:
	if death_sounds.is_empty():
		return
	_play_random_sfx(death_sounds, 0.0)

func play_music(fade_time: float = 1.0) -> void:
	if not music_stream:
		return
	_music_player.stream = music_stream
	_music_player.volume_db = -80.0
	_music_player.play()
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", -10.0, fade_time)

func stop_music(fade_time: float = 1.0) -> void:
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", -80.0, fade_time)
	tween.tween_callback(_music_player.stop).set_delay(fade_time)

func _play_random_sfx(sounds: Array[AudioStream], volume_db: float = 0.0) -> void:
	if sounds.is_empty():
		return
	var player := _get_free_player()
	if not player:
		return
	var stream = sounds.pick_random()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = randf_range(0.9, 1.1)
	player.play()

func _get_free_player() -> AudioStreamPlayer:
	for p in _sfx_players:
		if not p.playing:
			return p
	return null
