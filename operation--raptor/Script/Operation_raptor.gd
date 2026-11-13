extends CharacterBody3D

# -----Parameter------
@export var speed: float = 5
@export var mouse_sensitivity: float = 0.003
var time_passed: float = 0.0
var rotation_x: float = 0.0 
@export var speed_of_zoom: float = 5
@export var mouse_sensitivity_zoom: float = 0.003
@export var zoom_offset: float = 0.6
@export var zoom_speed: float = 7

# -----Booleans--------
var Sound_gespielt = false
var Sprinting = false
var sound_played = false 
var Ist_Reloading: bool = false
var pos = false

# -----Wurzeln--------
@onready var camera: Camera3D = $Camera3D
@onready var Walking = $Walking_Sound
@onready var reload_animation = $ViewModel2/human_with_ak_reload/Reload_animation
@onready var laser_pointer = $"../Player2/AK47/ViewModel/Gun/MuzzleFlash/LaserMain"
@onready var main_charakter = $"."
@onready var No_ammo = $No_Ammo
@onready var Sprint = $Sprint
@onready var Parameter = $Parameter
@onready var Walkie_Talkie = $Walkie_Talkie
@onready var Watch_Your_Ammo = $"/root/Operation_Raptor/Player/Watch_Your_Ammo"
@onready var Hold_your_position = $"/root/Operation_Raptor/Player/HOLD_YOUR_POSITION"
@onready var Your_on_your_own =  $"/root/Operation_Raptor/Player/Good_Luck"
@onready var Extra = $"/root/Operation_Raptor/Player/Extraction_point"
@onready var Flash_Light = $"/root/Operation_Raptor/Player/AK47/ViewModel/Gun/Mag/Light"
@onready var Animation_Reload = $AK47/AnimationPlayer
@onready var original_pos = camera.position
@onready var SOUND_NAMES = [
	Watch_Your_Ammo,
	Hold_your_position,
	Your_on_your_own
]



#--------func_ready-----

func _ready() -> void:
	print("SYSTEM [Main_Code] FUNKTIONIERT") 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Richtig stellung des laserpointes 
	Animation_Reload.Reload_Status.connect(Check_Reload) 
	Engine.max_fps = 30
	
#------- Main Code-------

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Drehung links/rechts (Y-Achse)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Drehung hoch/runter (X-Achse)
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -PI / 22, PI / 4)
		camera.rotation.x = rotation_x
		
		
		# ALT (Fehlerhaft):

func is_any_sound_playing() -> bool:
	for player in SOUND_NAMES:
		if player.playing:
			return true # Bricht sofort ab und spart Rechenzeit, sobald einer spielt
	return false	

func Check_Reload(status: bool) -> void:
	Ist_Reloading = status	
		
	
func _process(delta: float) -> void:
	
	time_passed += delta                                            
	 # Atemverhalten bis Z. 71  
	# ----------------->
	
	var breathing = sin(0.5 * time_passed ) * 0.02                 
	var breathing2 = sin(0.5 * time_passed ) * 0.02 
	var breathing3 = sin(0.5 * time_passed ) * 0.04 
	
	
	var is_moving = (
	Input.is_key_pressed(KEY_W)
	or Input.is_key_pressed(KEY_S)
	or Input.is_key_pressed(KEY_A)
	or Input.is_key_pressed(KEY_D)
	)
	
	var is_Sprint =  Input.is_action_pressed("Sprint")
	var is_gehen = is_moving and not is_Sprint
	

	#if is_Sprint:
		#breathing3 = sin(10 * time_passed) * 0.13
		#breathing = sin(8 * time_passed) * 0.03
		#breathing2 = sin(8 * time_passed) * 0.03

	if is_gehen:
		breathing3 = sin(7 * time_passed) * 0.07
		breathing = sin(5 * time_passed) * 0.01
		breathing2 = sin(5 * time_passed) * 0.01
		

	else:
		breathing = sin(0.5 * time_passed) * 0.02
		breathing2 = sin(0.5 * time_passed) * 0.02
		breathing3 = sin(0.5 * time_passed) * 0.04
		
	$".".position.y = breathing3 
	$AK47.position.y = breathing + 1.5
	$AK47.position.x = breathing2
	
	


	
	
	
	
	if Input.is_action_just_pressed("Schießen") and Global.allowed_to_shoot and not Ist_Reloading:
		$Shot.play()
		var pos_offset_x = [-0.05, 0.05].pick_random()
		var pos_offset_y = [-0.05, 0.08].pick_random()
		var pos_offset_z = [-0.05, 0.05].pick_random()

		# Ursprüngliche Position merken (wichtig, falls sich die Kamera bewegt!)
		
		

		# 2. Kamera um die zufälligen Werte verschieben
		camera.position += Vector3(pos_offset_x, pos_offset_y, pos_offset_z)
		# Alternativ einzeln:
		# camera.position.x += pos_offset_x
		# camera.position.y += pos_offset_y
		# camera.position.z += pos_offset_z

		# 3. Kurz warten
		await get_tree().create_timer(0.08).timeout

		# 4. Kamera wieder auf die ursprüngliche Position zurücksetzen
		camera.position = original_pos
		# Zufällige Rotationswerte wählen
		var rotation_deg_x = [-3.81, 3.81].pick_random()
		var rotation_deg_z = [-0.5, 3].pick_random()
		var rotation_deg_y = [-0.5, 3].pick_random()

	# Zielrotation berechnen (Ausgangswert + zufälliger Ausschlag)
		var target_rot = camera.rotation
		target_rot.z += deg_to_rad(rotation_deg_x)
		target_rot.x += deg_to_rad(rotation_deg_z)
		# target_rot.y += deg_to_rad(rotation_deg_y)

		# Tween erstellen für einen sanften Übergang
		var tween = create_tween()

		# 1. Schneller Ausschlag nach außen (0.04 Sekunden)
		tween.tween_property(camera, "rotation", target_rot, 0.04)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

		# 2. Sanftes Zurückgleiten auf 0 (0.15 Sekunden)
		tween.tween_property(camera, "rotation:z", 0.0, 0.15)\
			.set_trans(Tween.TRANS_SINE)\
	.		set_ease(Tween.EASE_IN_OUT)

		# Parallel dazu die Y-Rotation zurücksetzen (falls genutzt)
		tween.parallel().tween_property(camera, "rotation:y", 0.0, 0.15)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
		await get_tree().create_timer(0.4).timeout  
		$Shell_drop.play()  # <---- ändere es noch um das shell drop random.radiant (1,4) ist 
		var Chance = randi_range(1,50)
		if Chance == 1 and is_any_sound_playing():
					Walkie_Talkie.play()
					Parameter.play()
		
		
							
	elif Input.is_action_just_pressed("Schießen") and not Global.allowed_to_shoot:
		No_ammo.play() # <---- Wenn keine Muntion drin ist dann kommt ein sound hinweis
		
		
		
	
	# Prüfen, ob die rechte Maustaste gedrückt gehalten wird
	var target_z = original_pos.x
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		target_z = original_pos.x + zoom_offset
	
	# Kamera sanft auf die Ziel-Z-Position bewegen
	camera.position.x = lerp(camera.position.x, target_z, zoom_speed * delta)
	
	# --- Hier folgt dein restlicher Bewegungscode (move_and_slide usw.) ---
		
		
	
		
		
		
		
	
	
		
	
		  
		

	
#----- movement -----

func _physics_process(_delta: float) -> void:
	var input_dir = Vector3.ZERO

	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up") and Global.allowed_move and not Sprinting:
		#if Input.is_key_pressed(KEY_SHIFT):
			#input_dir -= transform.basis.z 
			#speed = 7.5
			#Sprinting = true
			#if not sound_played:
				#sound_played = true
				#Sprint.play()
				#print("Es spielt!")
			
		#else:
				#Sprinting = false
				#Sprint.stop()
				#sound_played = false
				#speed = 5
		input_dir -= transform.basis.z
		if not Sound_gespielt and not sound_played:
			Walking.play()
			Sound_gespielt = true
			
	
		
		
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down") and Global.allowed_move and not Sprinting:
		input_dir += transform.basis.z
		if not Sound_gespielt and not sound_played:
			Walking.play()
			Sound_gespielt = true
	
	# A steuert fest nach -X (Westen)
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left") and Global.allowed_move and not Sprinting:
		input_dir -= transform.basis.x
		if not Sound_gespielt and not sound_played:
			Walking.play()
			Sound_gespielt = true
	
	# D steuert fest nach +X (Osten)
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right") and Global.allowed_move and not Sprinting:
		input_dir += transform.basis.x
		if not Sound_gespielt and not sound_played:
			Walking.play()
			Sound_gespielt = true
	
	if input_dir != Vector3.ZERO:
		velocity = input_dir.normalized() * speed
	else:
		velocity = Vector3.ZERO
		
		if Sound_gespielt:
			Walking.stop()
			Sound_gespielt = false
			
		if Sprint.playing:
			Sprint.stop()
		
		
			
		
		

		
	


	move_and_slide()
	
	


	

	
