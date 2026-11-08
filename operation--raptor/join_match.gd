
extends Button

@onready var Code_Input: LineEdit = $"../LobbyCodeInput"
@onready var Button_Sound = $"../Button_Sound"
@onready var Info_Label: Label = $"../Info"


func _ready() -> void:
	pressed.connect(_on_pressed)

	
	disabled = HAuth.product_user_id.is_empty()
	HAuth.logged_in_connect.connect(_on_logged_in)


func _on_logged_in() -> void:
	disabled = false


func _on_pressed() -> void:

   
	var code = Code_Input.text.strip_edges().to_upper()

   
	if code.length() != 12:
		Info_Label.text = "CODE MUSS 12 ZEICHEN HABEN!"
		return

	disabled = true
	Info_Label.text = "SUCHE LOBBY..."

	
	var success = await Network.join_lobby(code)

	if not success:
		Info_Label.text = "LOBBY NICHT GEFUNDEN ODER BEITRITT FEHLGESCHLAGEN!"
		disabled = false
		return

	
	Info_Label.text = "VERBUNDEN!"
	Button_Sound.play()

	get_tree().change_scene_to_file("res://Lobbyraum.tscn")
	# WARTERAUM HINZUFÜGEN!!!
