extends Node

enum WorldType { LAND, RIVER, SKY }

signal world_changed(new_world: int)

var current_world: WorldType = WorldType.LAND

func _ready() -> void:
	print("🌍 WorldManager iniciado - Mundo inicial: LAND")

func change_world(new_world: WorldType) -> void:
	if current_world == new_world:
		return
	
	current_world = new_world
	
	print("🌍 Cambio REAL a:", WorldType.keys()[new_world])
	
	world_changed.emit(new_world)
