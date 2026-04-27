extends Control

func _ready():
	print("🎮 Menú principal listo")

func _on_play_button_pressed():
	scale = Vector2(1.05,1.05)
	scale = Vector2.ONE
	scale = Vector2(0.97,0.97)
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_worlds_button_pressed():
	get_tree().change_scene_to_file("res://scenes/WorldSelect.tscn")
	scale = Vector2(1.05,1.05)
	scale = Vector2.ONE
	scale = Vector2(0.97,0.97)

func _on_exit_button_pressed():
	get_tree().quit()
	scale = Vector2(1.05,1.05)
	scale = Vector2.ONE
	scale = Vector2(0.97,0.97)
