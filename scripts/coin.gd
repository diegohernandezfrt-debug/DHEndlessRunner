extends Area2D

@export var speed: float = 300.0

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("coin")

func _physics_process(delta):
	position.y += speed * delta
	
	if position.y > 800:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		LevelManager.add_coin()

		SaveManager.save_data["coins"] += 1
		SaveManager.save_game()
		queue_free()
