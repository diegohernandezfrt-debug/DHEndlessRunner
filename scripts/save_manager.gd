extends Node

var save_path = "user://save.json"

var save_data = {
	"coins": 0,
	"high_score": 0,
	"unlocked_worlds": [true, false, false]
}

func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("💾 Juego guardado")

func load_game():
	if not FileAccess.file_exists(save_path):
		print("📂 No hay save, usando datos por defecto")
		return

	var file = FileAccess.open(save_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)

	if data:
		save_data = data
	else:
		print("❌ Error al parsear save")

	print("📂 Juego cargado:", save_data)
