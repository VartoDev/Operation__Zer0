extends Node



#--... Button Sound ..---

@onready var Button_Sound = $"../Button_Sound"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
	
	
func _on_pressed() -> void:
	print("Create_lobby-Spielen wurde gedrückt!")
	Button_Sound.play()
	
	get_tree().change_scene_to_file("res://Lobbyraum.tscn")
