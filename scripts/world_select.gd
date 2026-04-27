extends Control

@onready var land_btn = $VBoxContainer/LandButton
@onready var river_btn = $VBoxContainer/RiverButton
@onready var sky_btn = $VBoxContainer/SkyButton

func _ready():
	SaveManager.load_game()

	var unlocked = SaveManager.save_data["unlocked_worlds"]

	# LAND siempre activo
	land_btn.disabled = false
	# RIVER
	river_btn.disabled = not unlocked[1]
	# SKY
	sky_btn.disabled = not unlocked[2]
	update_visuals()

	print("Unlocked worlds:", SaveManager.save_data["unlocked_worlds"])

func update_visuals():
	update_button(land_btn, true)
	update_button(river_btn, not river_btn.disabled)
	update_button(sky_btn, not sky_btn.disabled)

func update_button(btn, unlocked: bool):
	if unlocked:
		btn.modulate = Color(1,1,1)
	else:
		btn.modulate = Color(0.4,0.4,0.4)


func _on_land_button_pressed():
	start_world(WorldManager.WorldType.LAND)

func _on_river_button_pressed():
	if not SaveManager.save_data["unlocked_worlds"][1]:
		return
	
	start_world(WorldManager.WorldType.RIVER)

func _on_sky_button_pressed():
	if not SaveManager.save_data["unlocked_worlds"][2]:
		return
	
	start_world(WorldManager.WorldType.SKY)

func start_world(world):
	LevelManager.reset()
	WorldManager.change_world(world)
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
