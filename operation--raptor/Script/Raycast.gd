extends RayCast3D

# ----- Wurzeln ------

@onready var Schusslinie = self
@onready var Schuss_auf_Metall = $"../../../GMC/Bullet_Hit_Metall"
@onready var GMC_Modell = $"../../../GMC"
@onready var main_player = $"../.."
@onready var gegner = $"../../../Player2"
@onready var hintmarker_sound = $"/root/Operation_Raptor/Player/Hitmarker"

#...---- Commander Voicelines ----...

@onready var Watch_Your_Ammo = $"/root/Operation_Raptor/Player/Watch_Your_Ammo"
@onready var Walkie_Talkie = $"/root/Operation_Raptor/Player/Walkie_Talkie"
@onready var Hold_your_position = $"/root/Operation_Raptor/Player/HOLD_YOUR_POSITION"
@onready var Your_on_your_own =  $"/root/Operation_Raptor/Player/Good_Luck"
# ...--- Variablen ----....

@onready var Sound_play = false
@onready var sound_play2 = false
@onready var is_reloading = false

#...--- Liste für Sound system ----....

@onready var SOUND_NAMES = [
	Watch_Your_Ammo,
	Hold_your_position,
	Your_on_your_own
]

# ...----Munition und Health system---...
@onready var health_text: Label = get_node("/root/Operation_Raptor/Text_Health")
var Munition := 15
var health := 100

# ----- Main Code ------ 
func _ready() -> void:
	print("SYSTEM [Raycast] FUNKTIONIERT")  
	health_text.text = "Health: " + str(health) + " | Munition: " + str(Munition)
	
	await get_tree().create_timer(1.8).timeout
	Walkie_Talkie.play()
	Your_on_your_own.play()
	
	if Global.allowed_move:
		print("Du darfst dich nicht bewegen")
	print("Du darfst dich bewegen")

func is_any_sound_playing() -> bool:
	for player in SOUND_NAMES:
		if player.playing:
			return true # Bricht sofort ab und spart Rechenzeit, sobald einer spielt
	return false


func _process(delta: float) -> void:
	health_text.text = "Health: " + str(health) + " | Munition: " + str(Munition)
	if Input.is_action_just_pressed("Reload") and not is_reloading and not is_any_sound_playing():
		is_reloading = true
		await get_tree().create_timer(2.9).timeout
		Munition = 15
	else:
		await get_tree().create_timer(2.9).timeout
		is_reloading = false
	if Munition == 0:
		Global.allowed_to_shoot = false
	else:
		Global.allowed_to_shoot = true
	if Munition == 4 and not Sound_play and not is_any_sound_playing():
		Sound_play = true
		await get_tree().create_timer(0.7).timeout
		Walkie_Talkie.play()
		Watch_Your_Ammo.play()
	if Munition == 15:
		Sound_play = false	
	# <----health system and its effects for different Situation---->
	if health == 50 and not sound_play2 and not is_any_sound_playing():
		sound_play2 = true
		await get_tree().create_timer(0.7).timeout
		Walkie_Talkie.play()
		Hold_your_position.play()
		# Mehr Störeffekte noch einbauen
	elif not health == 50:
		sound_play2 = false
	
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
	
	
# Wichtige Notizen:
# 1. Global System muss noch auf multiplayer modus angespasst werden!!!
# 2. Dein Health-System sollte beim Gegner gespeichert werden.
#elif collider == gegner:
#    health -= 25


#Momentan ziehst du hier die Gesundheit des Skripts ab, das gerade schießt. Wenn das Skript am eigenen Spieler hängt, verliert also der Schütze Health statt des Gegners.

#Später sollte jeder Spieler seine eigene Gesundheit verwalten und bei einem Treffer entsprechend aktualisiert werden.
		
			
	
