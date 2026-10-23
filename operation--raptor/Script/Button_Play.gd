extends Button

# ----- Wurzeln -----

@onready var Button_Sound = $"../Button_Sound"

func _on_pressed():
	print("Spielen wurde gedrückt!")
	Button_Sound.play()
