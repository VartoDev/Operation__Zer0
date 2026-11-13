extends AudioStreamPlayer3D

@export_group("Stadt Akustik & Physik")
@export var max_hoerweite: float = 250.0 # <--- Hier anpassen: Maximale Hörweite in Metern (schnellerer Abfall)
@export var schall_groesse: float = 15.0  # <--- Hier anpassen: Bestimmt, wie schnell die Lautstärke bei Entfernung abnimmt
@export var basis_lautstaerke_db: float = 0.0
@export var schallgeschwindigkeit_ms: float = 343.0
@export var gebaeude_kollisions_maske: int = 1
@export var boden_kollisions_maske: int = 1

@export_group("Multi-Layer Rotor & Turbine")
@export var stream_leerlauf: AudioStream
@export var stream_vollast: AudioStream
@export var stream_heckrotor: AudioStream
@export var crossfade_dauer: float = 2.2
@export var start_offset_sekunden: float = 0.35
@export var ende_trim_sekunden: float = 0.4
@export var anti_phasing_detune: float = 0.005

@export_group("Aerodynamik, G-Kräfte & Turbulenzen")
@export var basis_pitch: float = 1.0
@export var min_pitch: float = 0.82
@export var max_pitch: float = 1.35
@export var steigflug_last_faktor: float = 0.18
@export var sinkflug_entlastung_faktor: float = 0.12
@export var blade_slap_intensitaet: float = 0.045
@export var bodeneffekt_hoehe: float = 22.0
@export var turbulenz_intensitaet: float = 0.015

var _player_b: AudioStreamPlayer3D
var _player_turbine: AudioStreamPlayer3D
var _player_heck: AudioStreamPlayer3D
var _aktiver_player_ist_a: bool = true
var _im_crossfade: bool = false
var _crossfade_timer: float = 0.0

var _letzte_position: Vector3
var _letzte_geschwindigkeit: Vector3
var _beschleunigung_geglaettet: Vector3
var _zeit_akkumulator: float = 0.0
var _raycast_intervall_timer: float = 0.0
var _turbulenz_seed: float = randf() * 100.0

var _bus_name: String
var _bus_index: int
var _lowpass_effekt: AudioEffectLowPassFilter
var _highpass_effekt: AudioEffectHighPassFilter
var _reverb_effekt: AudioEffectReverb
var _delay_effekt: AudioEffectDelay
var _compressor_effekt: AudioEffectCompressor
var _chorus_effekt: AudioEffectChorus
var _distortion_effekt: AudioEffectDistortion

var _aktueller_cutoff: float = 22000.0
var _ziel_cutoff: float = 22000.0
var _aktueller_highpass: float = 30.0
var _ziel_highpass: float = 30.0
var _aktueller_reverb_wet: float = 0.08
var _ziel_reverb_wet: float = 0.08
var _aktueller_reverb_room: float = 0.3
var _ziel_reverb_room: float = 0.3
var _aktueller_bodeneffekt_db: float = 0.0
var _ziel_bodeneffekt_db: float = 0.0
var _aktueller_delay_ms: float = 1.0
var _ziel_delay_ms: float = 1.0
var _aktueller_distortion_drive: float = 0.0
var _ziel_distortion_drive: float = 0.0

func _ready() -> void:
	_setup_audio_bus_und_effekte()
	_konfiguriere_player(self)
	_erstelle_zusaetzliche_player()
	
	_letzte_position = self.global_position
	_letzte_geschwindigkeit = Vector3.ZERO
	_beschleunigung_geglaettet = Vector3.ZERO
	
	if self.stream:
		_initialisiere_stream(self.stream)
		self.volume_db = basis_lautstaerke_db
		self.play(start_offset_sekunden)
		
	if _player_turbine and _player_turbine.stream:
		_initialisiere_stream(_player_turbine.stream)
		_player_turbine.volume_db = -80.0
		_player_turbine.play(start_offset_sekunden)
		
	if _player_heck and _player_heck.stream:
		_initialisiere_stream(_player_heck.stream)
		_player_heck.volume_db = basis_lautstaerke_db - 5.0
		_player_heck.play(0.0)

func _initialisiere_stream(s: AudioStream) -> void:
	if s is AudioStreamWAV:
		s.loop_mode = AudioStreamWAV.LOOP_DISABLED
	elif "loop" in s:
		s.loop = false

func _setup_audio_bus_und_effekte() -> void:
	_bus_name = "Heli_CinematicBus_" + str(self.get_instance_id())
	AudioServer.add_bus()
	_bus_index = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(_bus_index, _bus_name)
	AudioServer.set_bus_send(_bus_index, "Master")
	
	_highpass_effekt = AudioEffectHighPassFilter.new()
	_highpass_effekt.cutoff_hz = 30.0
	AudioServer.add_bus_effect(_bus_index, _highpass_effekt, 0)
	
	_lowpass_effekt = AudioEffectLowPassFilter.new()
	_lowpass_effekt.cutoff_hz = 22000.0
	_lowpass_effekt.resonance = 0.25
	AudioServer.add_bus_effect(_bus_index, _lowpass_effekt, 1)
	
	_chorus_effekt = AudioEffectChorus.new()
	_chorus_effekt.voice_count = 2
	_chorus_effekt.set_voice_delay_ms(0, 10.0)
	_chorus_effekt.set_voice_rate_hz(0, 1.1)
	_chorus_effekt.wet = 0.08
	AudioServer.add_bus_effect(_bus_index, _chorus_effekt, 2)
	
	_reverb_effekt = AudioEffectReverb.new()
	_reverb_effekt.room_size = 0.35
	_reverb_effekt.damping = 0.85
	_reverb_effekt.spread = 0.50
	_reverb_effekt.wet = 0.08
	_reverb_effekt.dry = 0.95
	AudioServer.add_bus_effect(_bus_index, _reverb_effekt, 3)
	
	_delay_effekt = AudioEffectDelay.new()
	_delay_effekt.dry = 0.0
	_delay_effekt.tap1_active = true
	_delay_effekt.tap1_delay_ms = 1.0
	_delay_effekt.tap1_level_db = 0.0
	_delay_effekt.tap2_active = true
	_delay_effekt.tap2_delay_ms = 45.0
	_delay_effekt.tap2_level_db = -22.0
	_delay_effekt.feedback_active = false
	AudioServer.add_bus_effect(_bus_index, _delay_effekt, 4)
	
	_distortion_effekt = AudioEffectDistortion.new()
	_distortion_effekt.mode = AudioEffectDistortion.MODE_CLIP
	_distortion_effekt.drive = 0.01
	AudioServer.add_bus_effect(_bus_index, _distortion_effekt, 5)
	
	_compressor_effekt = AudioEffectCompressor.new()
	_compressor_effekt.threshold = -4.0
	_compressor_effekt.ratio = 3.5
	_compressor_effekt.attack_us = 15.0
	_compressor_effekt.release_ms = 140.0
	AudioServer.add_bus_effect(_bus_index, _compressor_effekt, 6)

func _konfiguriere_player(p: AudioStreamPlayer3D) -> void:
	p.bus = _bus_name
	p.unit_size = schall_groesse
	p.max_distance = max_hoerweite
	p.max_db = basis_lautstaerke_db + 8.0
	# Inverse Distance sorgt für den natürlichen, steilen Lautstärkeabfall bei Annäherung/Entfernung
	p.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	p.panning_strength = 1.2
	p.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_PHYSICS_STEP
	p.attenuation_filter_cutoff_hz = 12000.0
	p.attenuation_filter_db = -8.0

func _erstelle_zusaetzliche_player() -> void:
	_player_b = AudioStreamPlayer3D.new()
	_player_b.stream = self.stream
	_konfiguriere_player(_player_b)
	_player_b.volume_db = -80.0
	self.add_child(_player_b)
	
	if stream_vollast:
		_player_turbine = AudioStreamPlayer3D.new()
		_player_turbine.stream = stream_vollast
		_konfiguriere_player(_player_turbine)
		self.add_child(_player_turbine)
		
	if stream_heckrotor:
		_player_heck = AudioStreamPlayer3D.new()
		_player_heck.stream = stream_heckrotor
		_konfiguriere_player(_player_heck)
		_player_heck.pitch_scale = 2.45
		self.add_child(_player_heck)

func _physics_process(delta: float) -> void:
	if delta <= 0.0 or not self.stream:
		return
		
	_zeit_akkumulator += delta
	_raycast_intervall_timer += delta
	
	_verarbeite_crossfade_loop(delta)
	_verarbeite_aerodynamik_und_pitch(delta)
	
	if _raycast_intervall_timer >= 0.06:
		_berechne_stadt_akustik_und_bodeneffekt()
		_raycast_intervall_timer = 0.0
		
	_interpoliere_audio_parameter(delta)

func _verarbeite_crossfade_loop(delta: float) -> void:
	var gesamt_laenge: float = self.stream.get_length()
	var effektives_ende: float = gesamt_laenge - ende_trim_sekunden
	if effektives_ende <= crossfade_dauer + start_offset_sekunden:
		return
		
	var aktiver_p: AudioStreamPlayer3D = self if _aktiver_player_ist_a else _player_b
	var naechster_p: AudioStreamPlayer3D = _player_b if _aktiver_player_ist_a else self
	
	if not _im_crossfade and aktiver_p.playing:
		var restzeit: float = effektives_ende - aktiver_p.get_playback_position()
		if restzeit <= crossfade_dauer:
			_im_crossfade = true
			_crossfade_timer = 0.0
			naechster_p.volume_db = -80.0
			naechster_p.play(start_offset_sekunden)
			
	if _im_crossfade:
		_crossfade_timer += delta
		var t: float = clamp(_crossfade_timer / crossfade_dauer, 0.0, 1.0)
		var s_curve: float = t * t * (3.0 - 2.0 * t)
		
		var vol_alt: float = cos(s_curve * PI * 0.5)
		var vol_neu: float = sin(s_curve * PI * 0.5)
		
		var ziel_basis_db: float = basis_lautstaerke_db + _aktueller_bodeneffekt_db
		aktiver_p.volume_db = linear_to_db(max(vol_alt, 0.0001)) + ziel_basis_db
		naechster_p.volume_db = linear_to_db(max(vol_neu, 0.0001)) + ziel_basis_db
		
		if t >= 1.0:
			aktiver_p.stop()
			_aktiver_player_ist_a = not _aktiver_player_ist_a
			_im_crossfade = false
	else:
		aktiver_p.volume_db = basis_lautstaerke_db + _aktueller_bodeneffekt_db

func _verarbeite_aerodynamik_und_pitch(delta: float) -> void:
	var aktuelle_pos: Vector3 = self.global_position
	var rohe_geschw: Vector3 = (aktuelle_pos - _letzte_position) / delta
	var rohe_beschl: Vector3 = (rohe_geschw - _letzte_geschwindigkeit) / delta
	
	_letzte_position = aktuelle_pos
	_letzte_geschwindigkeit = rohe_geschw
	_beschleunigung_geglaettet = _beschleunigung_geglaettet.lerp(rohe_beschl, delta * 4.0)
	
	var horizontal_speed: float = Vector2(rohe_geschw.x, rohe_geschw.z).length()
	var vertikal_speed: float = rohe_geschw.y
	var g_last: float = clamp(_beschleunigung_geglaettet.length() / 22.0, 0.0, 1.0)
	
	var speed_faktor: float = clamp(horizontal_speed / 65.0, 0.0, 1.0)
	var pitch_ziel: float = lerp(basis_pitch, max_pitch, speed_faktor)
	
	if vertikal_speed > 0.5:
		pitch_ziel += clamp(vertikal_speed / 14.0, 0.0, 1.0) * steigflug_last_faktor
	elif vertikal_speed < -0.5:
		pitch_ziel -= clamp(abs(vertikal_speed) / 18.0, 0.0, 1.0) * sinkflug_entlastung_faktor
		
	var turbulenz: float = sin(_zeit_akkumulator * 23.4 + _turbulenz_seed) * cos(_zeit_akkumulator * 11.1) * turbulenz_intensitaet * (0.5 + g_last)
	var blade_slap: float = (sin(_zeit_akkumulator * 18.2) + sin(_zeit_akkumulator * 36.4) * 0.45) * blade_slap_intensitaet * (0.35 + g_last * 0.75)
	var final_pitch: float = clamp(pitch_ziel + blade_slap + turbulenz, min_pitch, max_pitch + 0.15)
	
	self.pitch_scale = lerp(self.pitch_scale, final_pitch, delta * 7.0)
	
	if is_instance_valid(_player_b):
		var detune: float = anti_phasing_detune if _im_crossfade else 0.0
		_player_b.pitch_scale = self.pitch_scale + detune
		
	if is_instance_valid(_player_turbine):
		_player_turbine.pitch_scale = self.pitch_scale * 0.95
		var turbine_mix: float = clamp((horizontal_speed / 40.0) + (g_last * 0.5), 0.0, 1.0)
		_player_turbine.volume_db = linear_to_db(max(turbine_mix, 0.0001)) + basis_lautstaerke_db
		_ziel_distortion_drive = g_last * 0.12
		
	if is_instance_valid(_player_heck):
		_player_heck.pitch_scale = 2.4 + (g_last * 0.15)

func _berechne_stadt_akustik_und_bodeneffekt() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var heli_pos: Vector3 = self.global_position
	var exclude_rids: Array[RID] = []
	if self.get_parent() is CollisionObject3D:
		exclude_rids.append(self.get_parent().get_rid())
		
	var barometrischer_faktor: float = clamp(1.0 - (heli_pos.y * 0.000022), 0.82, 1.0)
	var aktuelle_schallgeschwindigkeit: float = schallgeschwindigkeit_ms * barometrischer_faktor
		
	var boden_query := PhysicsRayQueryParameters3D.create(heli_pos, heli_pos + Vector3.DOWN * bodeneffekt_hoehe)
	boden_query.collision_mask = boden_kollisions_maske
	boden_query.exclude = exclude_rids
	var boden_treffer: Dictionary = space_state.intersect_ray(boden_query)
	
	if not boden_treffer.is_empty():
		var abstand_boden: float = heli_pos.distance_to(boden_treffer.position)
		var boden_faktor: float = 1.0 - clamp(abstand_boden / bodeneffekt_hoehe, 0.0, 1.0)
		_ziel_bodeneffekt_db = boden_faktor * 4.0
	else:
		_ziel_bodeneffekt_db = 0.0
		
	var kamera: Camera3D = get_viewport().get_camera_3d()
	if not kamera:
		return
		
	var kam_pos: Vector3 = kamera.global_position
	var distanz: float = heli_pos.distance_to(kam_pos)
	var distanz_faktor: float = clamp(distanz / max_hoerweite, 0.0, 1.0)
	
	_ziel_delay_ms = clamp((distanz / aktuelle_schallgeschwindigkeit) * 1000.0, 1.0, 1400.0)
	
	var richtung_zu_kam: Vector3 = (kam_pos - heli_pos).normalized()
	var rechts: Vector3 = richtung_zu_kam.cross(Vector3.UP).normalized()
	if rechts.length_squared() < 0.01:
		rechts = Vector3.RIGHT
	var oben: Vector3 = rechts.cross(richtung_zu_kam).normalized()
	
	var strahlen_offsets: Array[Vector3] = [
		Vector3.ZERO,
		rechts * 4.0,
		-rechts * 4.0,
		oben * 3.0,
		-oben * 3.0
	]
	
	var treffer_anzahl: int = 0
	for offset in strahlen_offsets:
		var q := PhysicsRayQueryParameters3D.create(heli_pos + offset, kam_pos)
		q.collision_mask = gebaeude_kollisions_maske
		q.exclude = exclude_rids
		if not space_state.intersect_ray(q).is_empty():
			treffer_anzahl += 1
			
	var occlusion_ratio: float = float(treffer_anzahl) / float(strahlen_offsets.size())
	
	var frei_cutoff: float = lerp(22000.0, 7500.0, distanz_faktor)
	var blockiert_cutoff: float = lerp(4500.0, 1200.0, distanz_faktor)
	_ziel_cutoff = lerp(frei_cutoff, blockiert_cutoff, occlusion_ratio)
	
	_ziel_reverb_wet = clamp(0.06 + (distanz_faktor * 0.10) + (occlusion_ratio * 0.12), 0.05, 0.30)
	_ziel_reverb_room = clamp(0.30 + (distanz_faktor * 0.10), 0.25, 0.60)

func _interpoliere_audio_parameter(delta: float) -> void:
	_aktueller_cutoff = lerp(_aktueller_cutoff, _ziel_cutoff, delta * 6.0)
	_lowpass_effekt.cutoff_hz = _aktueller_cutoff
	
	_aktueller_highpass = lerp(_aktueller_highpass, _ziel_highpass, delta * 4.5)
	_highpass_effekt.cutoff_hz = _aktueller_highpass
	
	_aktueller_reverb_wet = lerp(_aktueller_reverb_wet, _ziel_reverb_wet, delta * 4.0)
	_reverb_effekt.wet = _aktueller_reverb_wet
	
	_aktueller_reverb_room = lerp(_aktueller_reverb_room, _ziel_reverb_room, delta * 3.5)
	_reverb_effekt.room_size = _aktueller_reverb_room
	
	_aktueller_bodeneffekt_db = lerp(_aktueller_bodeneffekt_db, _ziel_bodeneffekt_db, delta * 4.5)
	
	_aktueller_delay_ms = lerp(_aktueller_delay_ms, _ziel_delay_ms, delta * 8.5)
	_delay_effekt.tap1_delay_ms = _aktueller_delay_ms
	_delay_effekt.tap2_delay_ms = _aktueller_delay_ms + 44.0
	
	_aktueller_distortion_drive = lerp(_aktueller_distortion_drive, _ziel_distortion_drive, delta * 5.0)
	_distortion_effekt.drive = _aktueller_distortion_drive

func _exit_tree() -> void:
	var idx: int = AudioServer.get_bus_index(_bus_name)
	if idx != -1:
		AudioServer.remove_bus(idx)
