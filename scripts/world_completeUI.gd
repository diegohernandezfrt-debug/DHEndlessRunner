extends CanvasLayer

@onready var next_button = $Panel/VBoxContainer/NextWorldButton
@onready var infinite_button = $Panel/VBoxContainer/InfiniteButton
@onready var duck = $DuckUI

func _ready():
	visible = false
	
	next_button.pressed.connect(_on_next_world_button_pressed)
	infinite_button.pressed.connect(_on_infinite_button_pressed)
	
	print("✅ Botones conectados correctamente")

func show_ui():
	visible = true
	get_tree().paused = true

	visible = true
	duck.play("win")

func _on_next_world_button_pressed():
	print("Click detectado")
	print("➡️ Siguiente mundo")
	
	get_tree().paused = false
	
	var next = (WorldManager.current_world + 1) % 3

	# desbloquear mundo
	SaveManager.save_data["unlocked_worlds"][next] = true
	SaveManager.save_game()
	
	print("Actual:", WorldManager.current_world)
	print("Siguiente:", next)
	
	WorldManager.change_world(next)
	
	LevelManager.reset()
	
	# 🔥 esperar antes de recargar
	await get_tree().create_timer(0.1).timeout
	
	get_tree().reload_current_scene()

func _on_infinite_button_pressed():
	get_tree().paused = false
	visible = false
	
	print("♾️ Modo infinito activado")


