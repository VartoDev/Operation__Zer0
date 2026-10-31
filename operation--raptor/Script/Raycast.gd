extends RayCast3D

# ----- Wurzeln ------

@onready var Schusslinie = self
@onready var Schuss_auf_Metall = $"../../../GMC/Bullet_Hit_Metall"
@onready var GMC_Modell = $"../../../GMC"
@onready var main_player = $"../.."
@onready var gegner = $"../../../Player2"
@onready var hintmarker_sound = $"../../Hitmarker"


# Munition und Health system
@onready var health_text: Label = get_node("/root/Operation_Raptor/Text_Health")
var Munition := 15
var health := 100

# ----- Main Code ------ 
func _ready() -> void:
	print("SYSTEM [Raycast] FUNKTIONIERT")  
	health_text.text = "Health: " + str(health) + " | Munition: " + str(Munition)
	
	if Global.allowed_move:
		print("Du darfst dich nicht bewegen")
	print("Du darfst dich bewegen")


func _process(delta: float) -> void:
	health_text.text = "Health: " + str(health) + " | Munition: " + str(Munition)
	if Input.is_key_pressed(KEY_R):
		await get_tree().create_timer(2.9).timeout
		Munition = 15
	if Munition == 0:
		Global.allowed_to_shoot = false
	else:
		Global.allowed_to_shoot = true
	if Input.is_action_just_pressed("Schießen") and Global.allowed_to_shoot:
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
				health_text.text = "Health: " + str(health) + " | Munition: " + str(Munition)
				await get_tree().create_timer(0.4).timeout
				hintmarker_sound.play()		
		Munition -= 1
		Munition = max(Munition, 0)
		print("DEBUG: Health = ", health)
		health_text.text = "Health: " + str(health) + " | Munition: " + str(Munition)
		print("Nichts getroffen.")
	
	
				
		
		
			
	
