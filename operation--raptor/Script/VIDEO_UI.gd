extends VideoStreamPlayer

# ....---- Wurzeln ----....

@onready var Gun_Sound = $"../Gun"
@onready var Communication_Sound = $"../Radio"
@onready var Jet_Sound = $"../Jet"
@onready var Radio_old_sound = $"../Radio_old"
@onready var Shots_distance = $"../Shots_from_far_away"

# ....---- Variablen ----....



# ....----* Main Code *----.... 
func _ready():
	play()  # <----- Video wird abgespielt
	Random_Zahl_generieren() # <---- Loop für die Sounds wird in rollen gebracht 
	while 1 == 1:
		Sound_play(Communication_Sound)
		await get_tree().create_timer(3).timeout  # Wiederholend |
		Sound_play(Jet_Sound)                     # abspielende  |
		await get_tree().create_timer(3).timeout  # sounds       |
		Sound_play(Shots_distance)                # für          |
		await get_tree().create_timer(30).timeout # menü         |

	
	
	
	
func Sound_play(Name_of_song):
	var Random_Zahl = randi_range(3, 15)
	await get_tree().create_timer(Random_Zahl).timeout  # Eine Funktion die ein Sound nach einer gewissen Zeit abspielt
	Name_of_song.play()


func Random_Zahl_generieren():
	var Gun_Freq = randi_range(11, 28)
	Sound_Abspielen(Gun_Freq)  # <----- Unendlicher cycle
	
func Sound_Abspielen(frequenz):
	await get_tree().create_timer(frequenz).timeout
	Gun_Sound.play() # <--- weitere Menü background sounds
	Radio_old_sound.play() # <--- weitere Menü background sounds
	await get_tree().create_timer(15).timeout 
	Random_Zahl_generieren() # <---- Schleifenerzeuger
	 

	
	
	
	
	

	  

		
