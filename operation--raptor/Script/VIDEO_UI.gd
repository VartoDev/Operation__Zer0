extends VideoStreamPlayer

# ....---- Wurzeln ----....

@onready var Gun_Sound = $"../Gun"
@onready var Communication_Sound = $"../Radio"
@onready var Jet_Sound = $"../Jet"
@onready var Radio_old_sound = $"../Radio_old"
@onready var Shots_distance = $"../Shots_from_far_away"
@onready var Car_Sound = $"../Car"
@onready var shots_from_far = $"../Shots"
@onready var Reload = $"../Reload"


# ....---- Variablen ----....



# ....----* Main Code *----.... 
func _ready():
	
	print("VIDEO-DATEI: ",
	FileAccess.file_exists("res://videos/1001.mp4"))

	print("VIDEO-RESSOURCE: ", stream)

	VideoHelper.start_video(self)

	await get_tree().create_timer(2.0).timeout

	print("VIDEO LÄUFT: ", is_playing())
	print("VIDEO POSITION: ", stream_position)

	#play()  # <----- Video wird abgespielt
	Random_Zahl_generieren() # <---- Loop für die Sounds wird in rollen gebracht 
	while 1 == 1:
		Sound_play(Communication_Sound, 3, 15)
		await get_tree().create_timer(3).timeout 
		Sound_play(Jet_Sound, 3, 15)                     
		await get_tree().create_timer(3).timeout  
		Sound_play(Shots_distance, 3, 15)                
		await get_tree().create_timer(3).timeout
		Sound_play(Car_Sound, 10, 22)
		await get_tree().create_timer(3).timeout
		Sound_play(shots_from_far, 10, 22)
		await get_tree().create_timer(3).timeout
		Sound_play(Reload, 10, 22)
		await get_tree().create_timer(30).timeout 

	
	
	
	
func Sound_play(Name_of_song, Anfang, Ende):
	var Random_Zahl = randi_range(Anfang, Ende)
	await get_tree().create_timer(Random_Zahl).timeout  # Eine Funktion die ein Sound nach einer gewissen Zeit abspielt
	print(Name_of_song)
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
	 

	
	

func _enter_tree() -> void:
	autoplay = false
