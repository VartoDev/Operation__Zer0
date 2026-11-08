extends Label

var length: int = 12

signal Invitation(password)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = Network.invitation_code
