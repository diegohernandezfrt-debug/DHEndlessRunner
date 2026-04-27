extends TextureButton

var target_scale = Vector2.ONE

func _process(delta):
	scale = scale.lerp(target_scale, delta * 10)

func _on_area_2d_mouse_entered():
	target_scale = Vector2(1.08,1.08)

func _on_area_2d_mouse_exited():
	target_scale = Vector2.ONE
