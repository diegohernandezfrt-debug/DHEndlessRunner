extends Node2D

@export var bread_full: Texture2D
@export var bread_bite1: Texture2D
@export var bread_bite2: Texture2D

@onready var bread_sprite = $Bread

func update_lives(lives: int):
	if lives <= 0:
		bread_sprite.visible = false
		return
	
	bread_sprite.visible = true
	
	match lives:
		3:
			bread_sprite.texture = bread_full
		2:
			bread_sprite.texture = bread_bite1
		1:
			bread_sprite.texture = bread_bite2
	
	# efecto visual
	bread_sprite.scale = Vector2(1.3, 1.3)
	await get_tree().create_timer(0.1).timeout
	bread_sprite.scale = Vector2(1, 1)
