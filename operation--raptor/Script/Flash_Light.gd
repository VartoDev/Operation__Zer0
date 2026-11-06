extends DirectionalLight3D

#...--- Sound für flashLight ---....


@onready var Click = $"../../../../../Click"
@onready var Taschenlampe_an = false # <--- An oder aus Taschenlampe!
@onready var Battery_life_exp = 1 # <--- Der Delay damit ein Prozent runtergeht

# Batterie Bilder:

@onready var Low_Battery = $"../../../../../../Low_Battery"
@onready var Middle_Battery = $"../../../../../../Middle_Battery"
@onready var High_Battery = $"../../../../../../High_Battery"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("SYSTEM [TASCHENLAMPE] FUNKTIONIERT")
	visible = false # <--- Wichtig damit die Lampe zunächst aus ist 
	High_Battery.visible = !High_Battery.visible
	Battery_life(100)

# Check für Batter life und verschiedene Bilder für verschiedene Situationen einsetzen
func Battery_life(Percent):
	if Taschenlampe_an:
		if Percent > 0:
			if Percent < 50:
				Middle_Battery.visible = true
				High_Battery.visible = false
			else:
				Middle_Battery.visible = false
				High_Battery.visible = true
			if Percent < 20:
				Low_Battery.visible = true
				Middle_Battery.visible = false
			else:
				Low_Battery.visible = false
			
			Percent -= 1
			Percent = max(Percent, 0)
			await get_tree().create_timer(Battery_life_exp).timeout
			print(Percent)
			Battery_life(Percent)
		else:
			visible = false
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
		
			
