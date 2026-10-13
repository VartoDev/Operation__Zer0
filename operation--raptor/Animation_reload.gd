extends AnimationPlayer

# ----- Variablen -----
@onready var reload_node = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("DAS SYSTEM FUNKTIONIERT")
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Schießen"):
		reload_node.play("reload")
		reload_node.play("walk-patrol")
		
		
		
