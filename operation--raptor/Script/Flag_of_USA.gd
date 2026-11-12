extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.play("Object_0")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not current_animation == "Object_0":
		self.play("Object_0")
	
