extends Button

# ----- Wurzeln -----


@onready var Button_Sound = $"../Button_Sound"



func _on_pressed():
	print("Weiterleitung findet statt!")
	Button_Sound.play()
	get_tree().change_scene_to_file("res://UI_SETTINGS.tscn")
	# Weiterleitung auf Settings
