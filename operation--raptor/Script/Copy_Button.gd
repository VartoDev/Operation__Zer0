extends Button


# Copy Sound #

@onready var Copy_Sound = $"../Copy_sound"

var Invataion_Code: String = ""

@onready var Inv_code = $"../Innvation_code_generator"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	Inv_code.Invitation.connect(Code)


func _on_pressed() -> void:
	# Kopieren prozess noch einfügen....
	Copy_Sound.play()
	DisplayServer.clipboard_set(Invataion_Code)
	

func Code(code: String):
	Invataion_Code = code
