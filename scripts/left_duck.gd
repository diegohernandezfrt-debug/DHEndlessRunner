extends TextureRect


var time := 0.0
var start_y := 0.0
var start_rot := 0.0

func _ready():
	start_y = position.y
	start_rot = rotation

func _process(delta):
	time += delta

	position.y = start_y + sin(time * 2.0) * 8.0
	rotation = start_rot + sin(time * 1.5) * deg_to_rad(3)
