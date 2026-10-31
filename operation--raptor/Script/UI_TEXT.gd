extends Label

# ...---- Wurzeln ---...

@onready var Main_Text = $"."
@onready var Camera3d = $"../Player/Camera3D"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("SYSTEM [UI_TEXT] FUNKTIONIERT") 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Main_Text.text = str(Camera3d.rotation_degrees.x) + "°"
