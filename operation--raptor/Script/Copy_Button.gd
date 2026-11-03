extends Button


# Copy Sound #

@onready var Copy_Sound = $"../Copy_sound"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_pressed() -> void:
	# Kopieren prozess noch einfügen....
	Copy_Sound.play()
