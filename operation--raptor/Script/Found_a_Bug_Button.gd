extends Node


# ....---- Wurzeln ----....

@onready var Button_Sound = $"../Button_Sound"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

func _on_pressed() -> void:
	Button_Sound.play()
	print("Weiterleitung findet statt!") # <----- Weitergeiletet auf Website wo bugs reportet werden können
	OS.shell_open("https://varto-games.itch.io") # Du musst noch das auswechseln und da stattdessen die page zeigen wenn sie auch fertig ist!
