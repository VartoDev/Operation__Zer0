extends MeshInstance3D

# == Parabel ==

@export var speed: float = 2
@export var peak_height: float = 5.0 
@export var total_time: float = 10.0

@onready var is_flying = false

var elapsed_time: float = 0.0
var start_position: Vector3
var target_direction: Vector3 = Vector3.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func Bullet_shell_travel(delta: float) -> void:
	if elapsed_time < total_time:
			elapsed_time += delta
		
			# 1. Horizontale Bewegung 
			var horizontal_displacement = target_direction * speed * elapsed_time
		
			# 2. Vertikale Bewegung 
			
			var t = elapsed_time / total_time 
			
			var height = 4.0 * peak_height * t * (1.0 - t)
		
			# 3. Position updaten
			position = start_position + horizontal_displacement
			position.y += height
			print(global_position)
			Bullet_shell_travel(delta)
		
		
	if elapsed_time >= total_time:
		is_flying = false
		visible = false
		print("Angekommen shell am Boden!")

	



func _process(delta: float) -> void:
	if Input.is_action_pressed("Schießen"):
		visible = true
		Bullet_shell_travel(delta)
		
			
		
