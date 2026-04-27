extends Node

signal level_changed(level: int)

var current_level: int = 1
var max_level: int = 10

# Configuración base
var base_speed: float = 400.0
var base_spawn_time: float = 1.5
var distance: float = 0.0
var speed: float = 300.0
var is_running := true

func _ready() -> void:
	print("📊 LevelManager iniciado")

func increase_level() -> void:
	if current_level < max_level:
		current_level += 1
		speed += 80   # velocidad aumentada5
		print("⬆️ Nivel:", current_level)
		level_changed.emit(current_level)

func get_speed_multiplier() -> float:
	return 1.0 + (current_level - 1) * 0.2

func get_spawn_multiplier() -> float:
	return 1.0 - (current_level - 1) * 0.05

var coins: int = 0

signal coins_changed(new_amount)

func add_coin():
	coins += 1
	print("🪙 Monedas:", coins)
	coins_changed.emit(coins)

func _process(delta):
	distance += speed * delta
	if not is_running:
		return
		
	distance += speed * delta

func get_distance() -> int:
	return int(distance / 10)

func reset():
	distance = 0.0
	coins = 0
	current_level = 1
	speed = 300.0
	
	print("🔄 LevelManager reiniciado")
