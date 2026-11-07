extends Node

# ----- Wurzeln ------

var Mündungsfeuer := self
var Ist_Reloading: bool = false

@onready var Animation_Reload = $"../AnimationPlayer"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("SYSTEM [Mündungsfeuer] FUNKTIONIERT")
	
	Animation_Reload.Reload_Status.connect(Check_Reload) 
	

func Check_Reload(status: bool) -> void:
	Ist_Reloading = status


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Schießen") and Global.allowed_to_shoot and not Ist_Reloading:
		Mündungsfeuer.visible = true
		await get_tree().create_timer(0.1).timeout  # <----- Mesh instance
		Mündungsfeuer.visible = false


		
	
