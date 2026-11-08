
extends Node

var eos_initialized: bool = false
var platform_created: bool = false


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

	var success = await HPlatform.create_platform_async(create_options)

	if success:
		platform_created = true
		print("EOS Plattform erfolgreich erstellt!")
	else:
		print("EOS Plattform konnte nicht erstellt werden!")
