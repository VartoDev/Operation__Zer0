extends Button

# ...--- Wurzeln ---...

@onready var Button_Sound = $"../Button_Sound"


# ...--- Die drei buttons welche die Lautsärke regulieren können ---...


func _on_pressed() -> void:
	Button_Sound.play()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(0.2))
	
	
func _on_pressed_medium():
	Button_Sound.play()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(0.5))
	
func _on_pressed_high():
	Button_Sound.play()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(1))
	
