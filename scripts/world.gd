extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var game_over_ui: CanvasLayer = $game_over_ui
@onready var level_manager = LevelManager
@onready var parallax = $ParallaxBackground
@onready var bg1 = $ParallaxBackground/ParallaxLayer/Sprite2D
@onready var bg2 = $ParallaxBackground/ParallaxLayer2/Sprite2D
@onready var bg3 = $ParallaxBackground/ParallaxLayer3/Sprite2D
@onready var world_complete_ui = $WorldCompleteUi
@onready var lives_ui = $CanvasLayer/LivesUI
@onready var fade_rect = $CanvasLayer/Fade
@onready var audio_manager = $AudioManager
@onready var pause_menu_scene = preload("res://scenes/PauseMenu.tscn")
var pause_menu
@onready var pause_button = $PauseButton

@export var land_texture: Texture2D
@export var river_texture: Texture2D
@export var sky_texture: Texture2D

var is_game_over: bool = false
var is_world_complete := false

var last_level_trigger: int = 0
var world_completed := false

func _ready():
	WorldManager.world_changed.connect(_on_world_changed)
	player.lives_changed.connect(_on_lives_changed)

	_on_world_changed(WorldManager.current_world)

	if lives_ui:
		lives_ui.update_lives(player.current_lives)
	else:
		print("❌ LivesUI no encontrado")

	pause_menu = pause_menu_scene.instantiate()
	add_child(pause_menu)

	pause_button.pressed.connect(_on_pause_button_pressed)

func _on_world_changed(new_world: int):
	var texture: Texture2D = land_texture
	
	match new_world:
		WorldManager.WorldType.LAND:
			texture = land_texture
			audio_manager.play_music(audio_manager.land_music)
			
		WorldManager.WorldType.RIVER:
			texture = river_texture
			audio_manager.play_music(audio_manager.river_music)
			
		WorldManager.WorldType.SKY:
			texture = sky_texture
			audio_manager.play_music(audio_manager.sky_music)

	bg1.texture = texture
	bg2.texture = texture
	bg3.texture = texture

func _physics_process(delta: float) -> void:
	if is_game_over or is_world_complete:
		return

	var distance = level_manager.get_distance()

	# GAME OVER
	if not player.is_alive and not game_over_ui.visible:
		is_game_over = true
		game_over_ui.show_game_over(distance)

	if distance > SaveManager.save_data["high_score"]:
		SaveManager.save_data["high_score"] = distance
		SaveManager.save_game()

	# SUBIR NIVEL
	if distance > last_level_trigger + 500:
		last_level_trigger = distance
		level_manager.increase_level()

	# COMPLETAR MUNDO
	if level_manager.current_level == 10 and not world_completed:
		world_completed = true
		is_world_complete = true
		show_world_complete()

func _process(delta):
	if parallax and player:
		parallax.scroll_offset.y += player.forward_speed * delta

	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

	if parallax and player:
		parallax.scroll_offset.y += player.forward_speed * delta

func show_world_complete():
	if not world_complete_ui:
		print("❌ WorldCompleteUI no encontrado")
		return
		
	is_world_complete = true
	world_complete_ui.show_ui()

	# 🔓 DESBLOQUEAR SIGUIENTE MUNDO
	var current = WorldManager.current_world
	var next = current + 1
	
	if next < SaveManager.save_data["unlocked_worlds"].size():
		SaveManager.save_data["unlocked_worlds"][next] = true
		print("🔓 Mundo desbloqueado:", next)
		SaveManager.save_game()

func _on_lives_changed(lives):
	if lives_ui:
		lives_ui.update_lives(lives)

func transition_to_world(new_world: int) -> void:
	# Fade OUT (oscurecer)
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	# 🔁 cambiar mundo
	WorldManager.change_world(new_world)
	
	# Fade IN (mostrar)
	var tween2 = create_tween()
	tween2.tween_property(fade_rect, "modulate:a", 0.0, 0.5)

func toggle_pause():
	if is_game_over or is_world_complete:
		return

	var new_state = !get_tree().paused

	get_tree().paused = new_state

	if new_state:
		pause_menu.show_pause()
	else:
		pause_menu.hide_pause()

func _on_pause_button_pressed():
	toggle_pause()
