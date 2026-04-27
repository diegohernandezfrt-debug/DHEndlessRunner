extends CanvasLayer

@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var reintentar_button: Button = $Panel/VBoxContainer/Reintentar
@onready var duck = $DuckUI

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS # Nueva forma de pausar sin congelar todo el juego
	# Conexión automática del botón (nunca más fallará)
	reintentar_button.pressed.connect(_on_reintentar_pressed)
	print("✅ GameOverUI lista y botón conectado automáticamente")

func show_game_over(final_distance: int) -> void:
	print("🎯 show_game_over() llamada con distancia:", final_distance)
	score_label.text = "Distancia recorrida: " + str(final_distance) + " m"
	title_label.text = "¡El pato chocó! 💥"
	visible = true
	get_tree().paused = true
	print("✅ GameOverUI visible y juego pausado")
	# Animacion
	visible = true
	
	duck.play("hit")

func _on_reintentar_pressed() -> void:
	print("🔄 Reintentar presionado - reiniciando juego")
	get_tree().paused = false
	#player.process_mode = Node.PROCESS_MODE_DISABLED
	LevelManager.reset()   # 🔥 IMPORTANTE
	get_tree().reload_current_scene()

