extends MeshInstance3D

# == Parabel ==

@export var speed: float = 2
@export var peak_height: float = 3.0
@export var total_time: float = 10.0

var is_flying: bool = false

var elapsed_time: float = 0.0
var start_position: Vector3
var target_direction: Vector3 = Vector3.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = position
	

func Bullet_shell_travel(delta: float) -> void:
	if elapsed_time < total_time:
			elapsed_time = min(elapsed_time + delta, total_time)
		
			# 1. Horizontale Bewegung 
			var horizontal_displacement = target_direction * speed * elapsed_time
		
			# 2. Vertikale Bewegung 
			
			var t = elapsed_time / total_time 
			
			var height = 4.0 * peak_height * t * (1.0 - t)
		
			# 3. Position updaten
			position = start_position + horizontal_displacement
			position.y += height
			# Debug
			print(global_position)
		
		
		
	if elapsed_time >= total_time:
		is_flying = false
		visible = false
		print("Angekommen shell am Boden!")

	



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Schießen") and not is_flying:
		is_flying = true
		elapsed_time = 0.0
		position = start_position
		visible = true

	if is_flying:
		Bullet_shell_travel(delta)
			
		
