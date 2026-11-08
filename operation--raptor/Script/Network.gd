
extends Node

var eos_initialized: bool = false
var platform_created: bool = false
var current_lobby: HLobby = null
var invitation_code: String = ""



func _ready() -> void:

	# 1. EOS SDK initialisieren

	var options = EOS.Platform.InitializeOptions.new()

	options.product_name = "Operation Zero"
	options.product_version = "0.1.0"

	var result = await HPlatform.initialize_async(options)

	if not EOS.is_success(result):
		print("EOS Fehler: ", EOS.result_str(result))
		return

	eos_initialized = true
	print("EOS erfolgreich initialisiert!")


	# 2. Plattform konfigurieren

		
	# Konfigurationsdatei laden
	var config = ConfigFile.new()
	var error = config.load("res://eos_local.cfg")

	if error != OK:
		print("Konfigurationsdatei nicht gefunden!")
		return

	# EOS-Einstellungen übernehmen
	var create_options = EOS.Platform.CreateOptions.new()

	create_options.product_id = config.get_value("eos", "product_id", "")
	create_options.sandbox_id = config.get_value("eos", "sandbox_id", "")
	create_options.deployment_id = config.get_value("eos", "deployment_id", "")
	create_options.client_id = config.get_value("eos", "client_id", "")
	create_options.client_secret = config.get_value("eos", "client_secret", "")
	create_options.encryption_key = config.get_value("eos", "encryption_key", "")

	
	


	# 3. Plattform erstellen

	# Prüfen, ob der Encryption Key gültig ist

	if create_options.encryption_key.length() != 64:	
		print("EOS: Encryption Key muss 64 Zeichen haben!")
		return
	
	# Prüfen, ob noch Platzhalter vorhanden sind

	var fields = {
		"Product ID": create_options.product_id,
		"Sandbox ID": create_options.sandbox_id,
		"Deployment ID": create_options.deployment_id,
		"Client ID": create_options.client_id,
		"Client Secret": create_options.client_secret
	}

	for field in fields:
		var value = fields[field]

		if value.is_empty() or value.contains("DEINE_"):
			print("EOS: ", field, " ist noch nicht eingerichtet!")
			return
	
	var success = await HPlatform.create_platform_async(create_options)

	
	if success:
		platform_created = true
		print("EOS Plattform erfolgreich erstellt!")

		# Spieler bei EOS Game Services anmelden
		var login_success: bool = await HAuth.login_anonymous_async("Player")

		if login_success:
			print("EOS: Spieler erfolgreich angemeldet!")
		else:
			print("EOS: Spieleranmeldung fehlgeschlagen!")

	else:
		print("EOS Plattform konnte nicht erstellt werden!")


func create_lobby() -> bool:

	if not platform_created:
		print("EOS-Plattform ist nicht bereit!")
		return false

	if HAuth.product_user_id.is_empty():
		print("Spieler ist nicht angemeldet!")
		return false

	var lobby_options = EOS.Lobby.CreateLobbyOptions.new()

	lobby_options.bucket_id = "operation_zero_1v1"
	lobby_options.max_lobby_members = 2
	lobby_options.permission_level = EOS.Lobby.LobbyPermissionLevel.PublicAdvertised
	var lobby = await HLobbies.create_lobby_async(lobby_options)
	if lobby == null:
		print("Lobby konnte nicht erstellt werden!")
		return false
	
	# Einladungscode generieren
	var chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	var code = ""

	for i in range(12):
		var random_index = randi_range(0, chars.length() - 1)
		code += chars[random_index]

	# Einladungscode bei EOS speichern
	lobby.add_attribute("JOIN_CODE", code)

	var saved = await lobby.update_async()

	if not saved:
		print("Lobby-Code konnte nicht gespeichert werden!")
		await lobby.destroy_async()
		return false

	# Erfolgreiche Lobby speichern
	current_lobby = lobby
	invitation_code = code

	print("Lobby erfolgreich erstellt!")
	print("Einladungscode: ", invitation_code)

	return true




func join_lobby(code: String) -> bool:

	
	if HAuth.product_user_id.is_empty():
		print("Spieler ist nicht angemeldet!")
		return false

	
	var results = await HLobbies.search_by_attribute_async({
		"key": "JOIN_CODE",
		"value": code,
		"comparison": EOS.ComparisonOp.Equal
	})

	
	if results == null or results.is_empty():
		print("Keine Lobby mit diesem Code gefunden!")
		return false

   
	var lobby = await HLobbies.join_async(results[0])

	if lobby == null:
		print("Beitritt zur Lobby fehlgeschlagen!")
		return false

   
	current_lobby = lobby
	invitation_code = code

	print("Lobby erfolgreich beigetreten!")
	print("Lobby ID: ", lobby.lobby_id)

	return true
	
func leave_lobby() -> bool:

   
	if current_lobby == null:
		return true

   
	if not current_lobby.is_valid():
		current_lobby = null
		invitation_code = ""
		return true

	var success: bool = false

   
	if current_lobby.is_owner():
		success = await current_lobby.destroy_async()
		return true
	else:
		success = await current_lobby.leave_async()
		return true

   
	if not success:
		print("Fehler beim Verlassen der Lobby!")
		return false

	
	current_lobby = null
	invitation_code = ""

	print("Lobby erfolgreich verlassen!")
