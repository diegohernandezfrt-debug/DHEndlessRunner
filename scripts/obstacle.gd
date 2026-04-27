extends Area2D

@export var speed: float = 400.0
@export var wave_movement: bool = false
var wave_time: float = 0.0
var wave_amplitude: float = 40.0
var wave_speed: float = 4.0

func _process(delta):
	position.y += speed * delta
	# efecto perspectiva (escala)
	scale = Vector2.ONE * (1 + position.y / 1000.0)
	if position.y > 800:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		body.die()
