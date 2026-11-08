extends Button


# Copy Sound #

@onready var Copy_Sound = $"../Copy_sound"

var Invataion_Code: String = ""

@onready var Inv_code = $"../Innvation_code_generator"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	


func _on_pressed() -> void:
	if Network.invitation_code.is_empty():
		return

	DisplayServer.clipboard_set(Network.invitation_code)
	Copy_Sound.play()
	
