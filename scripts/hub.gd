extends CanvasLayer

@onready var coins_label = $Control/CoinsLabel
@onready var distance_label = $Control/DistanceLabel

@onready var level_manager = LevelManager
@onready var player = get_parent().get_node("Player")

func _process(delta):
	coins_label.text = "🪙 " + str(level_manager.coins)
	
	if player:
		var distance = level_manager.get_distance()
		distance_label.text = "📏 " + str(distance) + " m"
		
func _ready():
	level_manager.coins_changed.connect(_on_coins_changed)

func _on_coins_changed(amount):
	coins_label.text = "🪙 " + str(amount)
