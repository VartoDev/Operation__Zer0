extends Button

# ....---- Wurzeln ----....

@onready var Button_Sound = $"../Button_Sound"



func _on_pressed() -> void:
	
	
	# Vor dem Szenenwechsel Lobby verlassen
	var success = await Network.leave_lobby()

	if not success:
		print("Zurückgehen abgebrochen!")
		disabled = false
		return

	
	
	
	
	print("Weiterleitung findet statt!")
	Button_Sound.play()
	await get_tree().create_timer(0.1).timeout  # <---- Verzögerung damit der Button Sound spielt
	get_tree().change_scene_to_file("res://UI.tscn")
	# Weiterleitung auf Main menü
