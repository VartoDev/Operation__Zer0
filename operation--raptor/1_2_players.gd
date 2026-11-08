
extends Label

func _ready() -> void:

	if Network.current_lobby == null:
		text = "0/2 Players"
		return

	Network.current_lobby.lobby_updated.connect(update_players)

	update_players()


func update_players() -> void:

	var lobby = Network.current_lobby

	if lobby == null or not lobby.is_valid():
		text = "0/2 Players"
		return

	var players = lobby.members.size()
	var maximum = lobby.max_members

	text = str(players) + "/" + str(maximum) + " Players"
