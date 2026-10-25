extends Button

# ...--- Wurzeln ---...

@onready var Button_Sound = $Button_Sound


# ...--- Die drei buttons welche die Lautsärke regulieren können ---...


func _on_pressed() -> void:
	Button_Sound.play()
	# Reduziere den Sound
	
	
func _on_pressed_medium():
	Button_Sound.play()
	# Mittel Lautstärke
	
func _on_pressed_high():
	Button_Sound.play()
	# Hohe Lautstärke 
	
