extends Button

# ----- Wurzeln -----


@onready var Button_Sound = $"../Button_Sound"



func _on_pressed():
	print("Weiterleitung findet statt!")
	Button_Sound.play()
	OS.shell_open("https://varto-games.itch.io")
	# Weiterleitung auf mein Git oder itch....
