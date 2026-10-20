extends CharacterBody3D

# -----Parameter------
@export var speed: float = 5
@export var mouse_sensitivity: float = 0.003
var time_passed: float = 0.0
var rotation_x: float = 0.0 

# -----Booleans--------
var Sound_gespielt = false




# -----Wurzeln--------
@onready var camera: Camera3D = $Camera3D
@onready var Walking = $Walking_Sound
@onready var reload_animation = $ViewModel2/human_with_ak_reload/Reload_animation
@onready var laser_pointer = $"../Player2/AK47/ViewModel/Gun/MuzzleFlash/LaserMain"
@onready var main_charakter = $"."





#--------func_ready-----

func _ready() -> void:
	print("SYSTEM [Main_Code] FUNKTIONIERT") 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
#------- Main Code-------

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Drehung links/rechts (Y-Achse)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Drehung hoch/runter (X-Achse)
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -PI / 2, PI / 2)
		camera.rotation.x = rotation_x
		
		

		
		
		# ALT (Fehlerhaft):

		
		
		
	
func _process(delta: float) -> void:
	
	time_passed += delta                                            
	 # Atemverhalten bis Z. 71  
	# ----------------->
	var breathing = sin(0.5 * time_passed ) * 0.02                 
	var breathing2 = sin(0.5 * time_passed ) * 0.02 
	var breathing3 = sin(0.5 * time_passed ) * 0.04 

	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_S)\
	 or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_A) :
		breathing3 = sin(7 * time_passed ) * 0.07 
		breathing = sin(5 * time_passed ) * 0.01 
		breathing2 = sin(5 * time_passed ) * 0.01 
	else:
		breathing3 = sin(1.5 * time_passed ) * 0.04 
	
	$".".position.y = breathing3 
	$AK47.position.y = breathing + 1
	$AK47.position.x = breathing2
	
	# Richtig stellung des laserpointes 
	
	

	
	if Input.is_action_just_pressed("Schießen"):
		$Shot.play()
		$Shell_drop.play()                 #ändere es noch um das shell drop random.radiant (1,4) ist 
							
		 
		
		
		
		
		
		
	
		
		
		
		
	
	
		
	
		  
		

	
#----- movement -----

func _physics_process(_delta: float) -> void:
	var input_dir = Vector3.ZERO

	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up") and Global.allowed_move:
		input_dir -= transform.basis.z
		if not Sound_gespielt:
			Walking.play()
			Sound_gespielt = true
	
			
		
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down") and Global.allowed_move:
		input_dir += transform.basis.z
		if not Sound_gespielt:
			Walking.play()
			Sound_gespielt = true
	
		
	# A steuert fest nach -X (Westen)
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left") and Global.allowed_move:
		input_dir -= transform.basis.x
		if not Sound_gespielt:
			Walking.play()
			Sound_gespielt = true
	
	# D steuert fest nach +X (Osten)
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right") and Global.allowed_move:
		input_dir += transform.basis.x
		if not Sound_gespielt:
			Walking.play()
			Sound_gespielt = true
	
	if input_dir != Vector3.ZERO:
		velocity = input_dir.normalized() * speed
	else:
		velocity = Vector3.ZERO
		
		if Sound_gespielt:
			Walking.stop()
			Sound_gespielt = false
		
		

		
	


	move_and_slide()
	
	


	

	
