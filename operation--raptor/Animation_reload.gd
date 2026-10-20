extends AnimationPlayer

# ----- Wurzeln -----
@onready var reload_node = self
@onready var Reload := $"/root/Operation_Raptor/Player/Reload"

# ------ Variablen ------

var walk_patrol = false
var aim_fire = false
var fire_single = false
var idle_to_aim = false
var reload = false
var walk_aim = false
var walk_aim_fire = false
var walk_fire = false
var walk_reload = false

var reload_sound_gespielt = false


var animation_active = true in [walk_patrol, aim_fire, fire_single, idle_to_aim, reload, walk_aim, walk_aim_fire, walk_fire, walk_reload]




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("SYSTEM: [Animation] FUNKTIONIERT")
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# walk - patrol
	if (Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_D) \
	or Input.is_key_pressed(KEY_A)) and not idle_to_aim and not fire_single\
	and not reload and not walk_aim and not walk_aim_fire and not walk_fire :
		reload_node.play("walk-aim")
		walk_patrol = true
		
	else:
		if reload_node.current_animation == "walk-aim":
			reload_node.pause()
		walk_patrol = false
	# fire - single
	if not Input.is_key_pressed(KEY_W) and not Input.is_key_pressed(KEY_S) and not Input.is_key_pressed(KEY_D) \
	and not Input.is_key_pressed(KEY_A) and not walk_patrol and not idle_to_aim \
	and not reload and not walk_aim and not walk_aim_fire and not walk_fire and not walk_reload and Input.is_action_just_pressed("Schießen"):
		reload_node.play("aim-fire-single")
		aim_fire = true
		
	else:
		if  reload_node.current_animation == "fire-single":
			await get_tree().create_timer(0.25).timeout

			reload_node.stop()
		aim_fire = false
	# reload
	if not Input.is_key_pressed(KEY_W) and not Input.is_key_pressed(KEY_S) and not Input.is_key_pressed(KEY_D) \
	and not Input.is_key_pressed(KEY_A) and not walk_patrol and not idle_to_aim and not aim_fire\
	and not walk_aim and not walk_aim_fire and not walk_fire and not walk_reload and Input.is_action_just_pressed("Reload"):
		reload_node.play("reload-stance")
		reload = true	
		if not reload_sound_gespielt:
			await get_tree().create_timer(1.2).timeout

			Reload.play()
			reload_sound_gespielt = true
	else:
		if not reload_node.current_animation == "reload-stance":
			reload = false
		if not Reload.playing:
			reload_sound_gespielt = false
	# aim - single shot - walk patrol
	if (Input.is_key_pressed(KEY_W) or  Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_D) \
	or Input.is_key_pressed(KEY_A)) and walk_patrol and not idle_to_aim \
	and not reload and not walk_aim and not walk_aim_fire and not walk_fire and not walk_reload and Input.is_action_just_pressed("Schießen"):
		reload_node.play("walk-aim-fire-single")
		walk_aim_fire = true
		
	else:
		if reload_node.current_animation == "walk-aim-fire-single":
			await get_tree().create_timer(0.2).timeout

			reload_node.pause()
		walk_aim_fire = false
	
	
		
	  
		
		
		
		
