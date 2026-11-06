extends DirectionalLight3D

#...--- Sound für flashLight ---....


@onready var Click = $"../../../../../Click"
@onready var Taschenlampe_an = false 
@onready var Battery_life_exp = 1.3 # <--- Der Delay damit ein Prozent runtergeht



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("SYSTEM [TASCHENLAMPE] FUNKTIONIERT")
	visible = false
	Battery_life(100)


func Battery_life(Percent):
	if Taschenlampe_an:
		Percent -= 1
		await get_tree().create_timer(Battery_life_exp).timeout
		print(Percent)
		Battery_life(Percent)
	else:
		await get_tree().create_timer(Battery_life_exp).timeout
		Battery_life(Percent)
		

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_F and event.pressed and not event.echo:
			Click.play()
			Taschenlampe_an = !Taschenlampe_an
			visible = !visible
			print("Taschenlampe: ", "AN" if visible else "AUS")
		
			
