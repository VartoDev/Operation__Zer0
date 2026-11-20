extends Button

# ...--- Wurzeln ---...

@onready var Button_Sound = $"../Button_Sound"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_pressed_low_glitch():
	Button_Sound.play()
	
func on_pressed_medium_glitch():
	Button_Sound.play()

func _on_pressed_high_glitch():
	Button_Sound.play()
