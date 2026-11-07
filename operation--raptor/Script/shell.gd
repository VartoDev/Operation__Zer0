extends MeshInstance3D

# == Parabel ==

@export var speed: float = 5
@export var peak_height: float = 3.0
@export var total_time: float = 10
@export var raycast_node: RayCast3D
var Munition_Anzahl: float = 15

@onready var Shell = self
@onready var Main_Player = $".."

var is_flying: bool = false
var Darf_Schießen: bool = true

var elapsed_time: float = 0.0
var start_position: Vector3
var target_direction: Vector3 = Vector3.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = position
	# Wir überprüfen ob es überhaupt Munition gibt damit wir schießen können
	print("Shell: ", get_path())
	print("Raycast: ", raycast_node)
	print("Ist Kopie: ", is_in_group("Bullet_duplicated"))

	if not is_in_group("Bullet_duplicated"):
		if raycast_node != null:
			raycast_node.Schuss_abgegeben.connect(_on_schuss)
		else:
			push_error("Diese Shell hat keinen Raycast!")
		

func _on_schuss() -> void:
	var Bullet_Kopie = Shell.duplicate()

	Bullet_Kopie.add_to_group("Bullet_duplicated")
	Main_Player.add_child(Bullet_Kopie)

	Bullet_Kopie.position = start_position
	Bullet_Kopie.start_position = start_position
	Bullet_Kopie.elapsed_time = 0.0
	Bullet_Kopie.is_flying = true
	Bullet_Kopie.visible = true


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
			var Sensi_Rotation = randi_range(1, 10)
			rotation.x += Sensi_Rotation
			# Debug
			print(global_position)
		
		
		
	if elapsed_time >= total_time:
		is_flying = false
		visible = false
		print("Angekommen shell am Boden!")
		


	
func Lösch_alle_instanzen():
		var alte_bullets = get_tree().get_nodes_in_group("Bullet_duplicated")
		for Bullet_instanz in alte_bullets:
			Bullet_instanz.queue_free()


func _process(delta: float) -> void:
	
	if Darf_Schießen:
		if is_flying:
			Bullet_shell_travel(delta)
	else:
		await get_tree().create_timer(0.7).timeout
		Lösch_alle_instanzen()
			
	
		
