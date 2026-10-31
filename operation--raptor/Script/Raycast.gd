extends RayCast3D

# ----- Wurzeln ------

@onready var Schusslinie = self
@onready var Schuss_auf_Metall = $"../../../GMC/Bullet_Hit_Metall"
@onready var GMC_Modell = $"../../../GMC"
@onready var main_player = $"../.."
@onready var gegner = $"../../../Player2"
@onready var hintmarker_sound = $"../../Hitmarker"


@onready var health_text: Label = get_node("/root/Operation_Raptor/Text")
var health := 100


# ----- Main Code ------ 
func _ready() -> void:
	print("SYSTEM [Raycast] FUNKTIONIERT")  
	health_text.text = "Health:" + str(health)



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Schießen"):
		if Schusslinie.is_colliding():
			var collider = Schusslinie.get_collider()
			print("Getroffen: ", collider.name)
			if collider == GMC_Modell:
				await get_tree().create_timer(0.1).timeout
				Schuss_auf_Metall.play()
			elif collider == gegner:
				health -= 25
				health = max(health, 0)
				# Text ändern zu aktuelle health!
				health_text.text = "Health: " + str(health)
				await get_tree().create_timer(0.4).timeout
				hintmarker_sound.play()			
		print("Nichts getroffen.")
	
	
				
		
		
			
	
