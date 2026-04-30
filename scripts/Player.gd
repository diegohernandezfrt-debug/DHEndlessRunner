extends CharacterBody2D

@export var forward_speed: float = 400.0
@export var lane_speed: float = 10.0

@export var max_lives: int = 3
var current_lives: int
var is_invulnerable := false

@onready var anim = $AnimatedSprite2D
@onready var level_manager = LevelManager
@onready var hit_sound = $HitSound

signal lives_changed(lives)

var lane_positions: Array[float] = [-150.0, 0.0, 150.0]
var current_lane: int = 1
var current_anim_state = "run"

var is_alive: bool = true

func _ready():
	level_manager.level_changed.connect(_on_level_changed)
	WorldManager.world_changed.connect(_on_world_changed) # 👈 FALTA ESTO
	
	current_lives = max_lives
	_on_world_changed(WorldManager.current_world)

func _on_level_changed(level: int) -> void:
	var multiplier = level_manager.get_speed_multiplier()
	forward_speed = 400.0 * multiplier
	
	print("🚀 Velocidad actual:", forward_speed)

func _physics_process(delta):
	# movimiento automático hacia adelante (visual)
	velocity.x = 0
	
	# mover lateralmente
	var target_x = lane_positions[current_lane]
	position.x = lerp(position.x, target_x, lane_speed * delta)
	
	move_and_slide()

func _on_world_changed(new_world: int) -> void:
	match new_world:
		WorldManager.WorldType.LAND:
			lane_speed = 10.0
			current_anim_state = "run"

		WorldManager.WorldType.RIVER:
			lane_speed = 6.0
			current_anim_state = "swim"

		WorldManager.WorldType.SKY:
			lane_speed = 14.0
			current_anim_state = "fly"

	anim.play(current_anim_state)

func die() -> void:
	if not is_alive or is_invulnerable:
		return
	
	is_invulnerable = true
	current_lives -= 1
	
	print("❤️ Vidas:", current_lives)
	blink_effect()
	
	# 💥 animación de golpe
	if anim:
		anim.play("hit")
		hit_sound.play()
	await get_tree().create_timer(1.0).timeout

	if anim and is_alive:
		anim.play(current_anim_state)
	
	# 🎥 sacudida cámara
	var camera = get_node_or_null("../Camera2D")
	if camera:
		camera.shake(5.0)
	
	# ⏳ efecto slow motion
	Engine.time_scale = 0.3
	await get_tree().create_timer(0.1).timeout
	Engine.time_scale = 1.0
	
	# 💀 GAME OVER
	if current_lives <= 0:
		is_alive = false
		print("💀 GAME OVER")
		return
	
	# 🔄 sigue vivo → pierde velocidad
	forward_speed = 200.0
	
	# 🟡 invulnerabilidad temporal
	await get_tree().create_timer(1.0).timeout
	
	is_invulnerable = false
	
	# volver a animación normal
	if anim:
		anim.play(current_anim_state)
	
	get_parent().lives_ui.update_lives(current_lives)
	
	emit_signal("lives_changed", current_lives)

func move_left():
	current_lane = max(0, current_lane - 1)

func move_right():
	current_lane = min(lane_positions.size() - 1, current_lane + 1)

var touch_start := Vector2.ZERO
var min_swipe := 60
var swipe_used := false


func _input(event):

	if event.is_action_pressed("ui_left"):
		move_left()

	if event.is_action_pressed("ui_right"):
		move_right()


	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
			swipe_used = false


	if event is InputEventScreenDrag and not swipe_used:
		var delta = event.position - touch_start

		if abs(delta.x) > min_swipe:

			if delta.x > 0:
				move_right()
			else:
				move_left()

			swipe_used = true

func blink_effect():
	for i in range(5):
		visible = false
		await get_tree().create_timer(0.1).timeout
		visible = true
		await get_tree().create_timer(0.1).timeout

