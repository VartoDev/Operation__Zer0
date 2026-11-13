
class_name VideoHelper
extends RefCounted


static func start_video(player: VideoStreamPlayer) -> void:

	# Das Video der aktuellen Szene ermitteln
	if player.stream == null:
		push_error("VIDEO: Kein Video zugewiesen!")
		return

	var source_path: String = player.stream.file

	# Zielordner für die Videodateien
	var folder = "user://menu_videos"

	var error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(folder)
	)

	if error != OK:
		push_error("VIDEO: Ordner konnte nicht erstellt werden!")
		return

	var target_path = folder.path_join(source_path.get_file())

	# Originalvideo lesen
	var source = FileAccess.open(source_path, FileAccess.READ)

	if source == null:
		push_error("VIDEO: Datei fehlt: " + source_path)
		return

	# Video als echte Datei speichern
	var target = FileAccess.open(target_path, FileAccess.WRITE)

	if target == null:
		source.close()
		push_error("VIDEO: Datei konnte nicht gespeichert werden!")
		return

	while source.get_position() < source.get_length():
		var remaining: int = source.get_length() - source.get_position()
		var amount: int = mini(remaining, 1024 * 1024)

		target.store_buffer(source.get_buffer(amount))

	source.close()
	target.close()

	# Eigenen Videostream erzeugen
	var new_stream = player.stream.duplicate() as VideoStream

	if new_stream == null:
		push_error("VIDEO: Stream konnte nicht kopiert werden!")
		return

	new_stream.file = target_path

	player.stop()
	player.stream = new_stream
	player.play()

	print("VIDEO GELADEN: ", source_path)
