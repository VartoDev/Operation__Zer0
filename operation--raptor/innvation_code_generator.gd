extends Label

var length: int = 12

signal Invitation(password)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var password := ""
	
	for i in range(length):
		var random_index := randi() % chars.length()
		password += chars[random_index]
		
	self.text = password
	Invitation.emit(password)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
