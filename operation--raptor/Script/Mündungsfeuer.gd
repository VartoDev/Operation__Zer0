extends Node

# ----- Wurzeln ------

var Mündungsfeuer := self


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("SYSTEM [Mündungsfeuer] FUNKTIONIERT") 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Schießen") and Global.allowed_to_shoot:
		Mündungsfeuer.transparency = 0
		await get_tree().create_timer(0.05).timeout  # <----- Mesh instance
		Mündungsfeuer.transparency = 1


		
	
