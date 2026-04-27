extends Camera2D

var shake_intensity := 0.0
var shake_decay := 5.0

func _process(delta):
	if shake_intensity > 0:
		offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO

func shake(power: float = 8.0):
	shake_intensity = power
