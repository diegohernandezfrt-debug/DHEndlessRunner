extends CanvasLayer

func _ready():
	visible = false

func show_pause():
	visible = true

func hide_pause():
	visible = false

func _on_resume_button_pressed():
	get_tree().paused = false
	hide_pause()
