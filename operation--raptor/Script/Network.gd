
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

	var create_options = EOS.Platform.CreateOptions.new()

	create_options.product_id = "PRODUCT_ID"
	create_options.sandbox_id = "SANDBOX_ID"
	create_options.deployment_id = "DEPLOYMENT_ID"
	create_options.client_id = "CLIENT_ID"
	create_options.client_secret = "CLIENT_SECRET"
	create_options.encryption_key = "64_ZEICHEN_LANGER_SCHLUESSEL"


	# 3. Plattform erstellen

	var success = await HPlatform.create_platform_async(create_options)

	if success:
		platform_created = true
		print("EOS Plattform erfolgreich erstellt!")
	else:
		print("EOS Plattform konnte nicht erstellt werden!")
