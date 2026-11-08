extends Label



func _ready() -> void:
	if Network.current_lobby == null:
		text = "Waiting for Player..."
		return

	Network.current_lobby.lobby_updated.connect(Update_status)

	Update_status()


func Update_status() -> void:
	var lobby = Network.current_lobby

	if lobby == null or not lobby.is_valid():
		text = "Waiting for Player..."
		self.add_theme_color_override("font_color", Color.RED)
		return

	var players = lobby.members.size()

	if players == 2:
		text = "CONNECTED"
		self.add_theme_color_override("font_color", Color.GREEN)
	else:
		text = "Waiting for Player..."
		self.add_theme_color_override("font_color", Color.RED)
