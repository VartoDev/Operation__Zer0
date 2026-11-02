extends DirectionalLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("SYSTEM [TASCHENLAMPE] FUNKTIONIERT")
	visible = false


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_F and event.pressed and not event.echo:
			visible = !visible
			print("Taschenlampe: ", "AN" if visible else "AUS")
