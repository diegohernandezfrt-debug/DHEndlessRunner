extends Node2D

@export var land_obstacles: Array[PackedScene]
@export var river_obstacles: Array[PackedScene]
@export var sky_obstacles: Array[PackedScene]

@export var spawn_distance: float = 1200.0
@export var spawn_interval: float = 1.5

@export var coin_scene: PackedScene

@export var lanes := [-150.0, 0.0, 150.0]

@onready var player = get_parent().get_node_or_null("Player")
@onready var level_manager = LevelManager

var timer: Timer
var last_pattern := -1
var last_pattern_was_hard := false
 
func _ready() -> void:
	level_manager.level_changed.connect(_on_level_changed)
	
	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.timeout.connect(spawn_pattern)
	add_child(timer)
	timer.start()

	print("✅ Spawner Subway activo")

func spawn_pattern():
	if player and not player.is_alive:
		return
	
	var level = level_manager.current_level
	
	var pattern_pool = []
	
	match WorldManager.current_world:
		WorldManager.WorldType.LAND:
			pattern_pool = [
				pattern_single,
				pattern_double_block,
				pattern_gap,
				pattern_zigzag
			]
			
			if level >= 5:
				pattern_pool.append(pattern_wall)
		
		WorldManager.WorldType.RIVER:
			pattern_pool = [
				pattern_single,
				pattern_gap,
				pattern_zigzag
			]
			
			if level >= 4:
				pattern_pool.append(pattern_stairs)
		
		WorldManager.WorldType.SKY:
			pattern_pool = [
				pattern_double_block,
				pattern_gap,
				pattern_zigzag
			]
			
			if level >= 3:
				pattern_pool.append(pattern_wall)
			
			if level >= 6:
				pattern_pool.append(pattern_trap)

	# 🔥 Elegimos patrón
	var pattern = pattern_pool.pick_random()
	
	# 🔥 Ejecutamos y obtenemos carriles usados
	var used_lanes = pattern.call()
	
	# 💰 monedas solo en carriles libres
	if randf() < 0.3:
		spawn_coins_line(used_lanes)

func spawn_land_patterns(level: int):
	var pattern_pool = [
		pattern_single,
		pattern_double_block,
		pattern_gap,
		pattern_zigzag
	]
	
	if level >= 5:
		pattern_pool.append(pattern_wall)
	
	pattern_pool.pick_random().call()

func pattern_single() -> Array:
	var lane = randi() % lanes.size()
	spawn_in_lane(lane)
	return [lane]

func pattern_double_block() -> Array:
	var blocked = randi() % lanes.size()
	var used_lanes = []
	
	for i in range(lanes.size()):
		if i != blocked:
			spawn_in_lane(i)
			used_lanes.append(i)
	
	return used_lanes

func pattern_gap() -> Array:
	spawn_in_lane(0)
	spawn_in_lane(2)
	return [0, 2]

var zigzag_index := 0

func pattern_zigzag() -> Array:
	spawn_in_lane(zigzag_index)
	var used = [zigzag_index]
	zigzag_index = (zigzag_index + 1) % lanes.size()
	return used

func spawn_river_patterns(level: int):
	var pattern_pool = [
		pattern_single,
		pattern_gap,
		pattern_zigzag
	]
	
	if level >= 4:
		pattern_pool.append(pattern_stairs)
	
	pattern_pool.pick_random().call()

func spawn_sky_patterns(level: int):
	var pattern_pool = [
		pattern_double_block,
		pattern_gap,
		pattern_zigzag
	]
	
	if level >= 3:
		pattern_pool.append(pattern_wall)
	
	if level >= 6:
		pattern_pool.append(pattern_trap)
	
	pattern_pool.pick_random().call()

func pattern_wall() -> Array:
	var gap = randi() % lanes.size()
	var used = []
	
	for i in range(lanes.size()):
		if i != gap:
			spawn_in_lane(i)
			used.append(i)
	
	return used

func pattern_double_row():
	var safe_lane = randi() % lanes.size()
	
	for i in range(lanes.size()):
		if i != safe_lane:
			spawn_in_lane(i, 0)
			spawn_in_lane(i, 150)

func pattern_stairs() -> Array:
	var safe_lane = randi() % lanes.size()
	var used = []
	
	for i in range(lanes.size()):
		if i != safe_lane:
			spawn_in_lane(i, i * 120)
			used.append(i)
	
	return used

func pattern_trap() -> Array:
	var safe_lane = randi() % lanes.size()
	var used = []
	
	for i in range(lanes.size()):
		if i != safe_lane:
			spawn_in_lane(i, i * 120)
			used.append(i)
	
	return used

func spawn_in_lane(lane_index: int, offset_x: float = 0.0):
	if not player:
		return
	
	if lane_index < 0 or lane_index >= lanes.size():
		return
	
	var obstacle_scene = get_random_obstacle()
	if not obstacle_scene:
		return
	
	var obstacle = obstacle_scene.instantiate()
	
	var lane_x = lanes[lane_index]
	var spawn_y = player.global_position.y - 800
	
	var spawn_x = player.global_position.x + spawn_distance + offset_x
	
	obstacle.position = Vector2(lane_x, spawn_y)
	get_parent().add_child(obstacle)

func _on_level_changed(level: int) -> void:
	var multiplier = level_manager.get_spawn_multiplier()
	timer.wait_time = spawn_interval * multiplier
	
	print("⏱️ Spawn rate:", timer.wait_time)
	
func get_random_obstacle() -> PackedScene:
	var list: Array
	
	match WorldManager.current_world:
		WorldManager.WorldType.LAND:
			list = land_obstacles
		WorldManager.WorldType.RIVER:
			list = river_obstacles
		WorldManager.WorldType.SKY:
			list = sky_obstacles
	
	if list.is_empty():
		print("❌ Lista vacía en este mundo")
		return null
	
	return list.pick_random()

func spawn_coins_line(used_lanes: Array):
	if not coin_scene:
		return
	
	var spawn_y = player.global_position.y - 1200
	
	var free_lanes = []
	
	for i in range(lanes.size()):
		if i not in used_lanes:
			free_lanes.append(i)
	
	if free_lanes.is_empty():
		return
	
	var lane = free_lanes.pick_random()
	
	for i in range(5):
		var coin = coin_scene.instantiate()
		
		var x = lanes[lane]
		var y = spawn_y - (i * 100)
		
		coin.position = Vector2(x, y)
		get_parent().add_child(coin)
