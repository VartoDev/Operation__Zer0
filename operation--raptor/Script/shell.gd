extends MeshInstance3D

# == Parabel ==

@export var speed: float = 10.0      
@export var peak_height: float = 5.0 
@export var total_time: float = 2.0  

var elapsed_time: float = 0.0
var start_position: Vector3
var target_direction: Vector3 = Vector3.FORWARD 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Schießen"):
		visible = true
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
		
