extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
	

#--... Button Sound ..---

@onready var Button_Sound = $"../Button_Sound"


	
	
func _on_pressed() -> void:
	
	
	
	disabled = true

	var success = await Network.create_lobby()

	if not success:
		print("Fehler beim Erstellen der Lobby!")
		disabled = false
		return

	
	
	
	print("Join_lobby-Spielen wurde gedrückt!")
	Button_Sound.play()
	
	get_tree().change_scene_to_file("res://Lobbyraum.tscn")
