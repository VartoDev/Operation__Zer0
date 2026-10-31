extends Button

# ----- Wurzeln -----

@onready var Button_Sound = $"../Button_Sound"

func _on_pressed():
	print("Button-Spielen wurde gedrückt!")
	get_tree().change_scene_to_file("res://Play.tscn")
