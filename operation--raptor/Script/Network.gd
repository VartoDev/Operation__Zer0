
extends Node

var eos_initialized: bool = false


func _ready() -> void:
	var options = EOS.Platform.InitializeOptions.new()

	options.product_name = "Operation Zero"
	options.product_version = "0.1.0"

	var result = await HPlatform.initialize_async(options)

	if EOS.is_success(result):
		eos_initialized = true
		print("EOS wurde erfolgreich initialisiert!")
	else:
		print("EOS-Fehler: ", EOS.result_str(result))
