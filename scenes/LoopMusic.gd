extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("finished", Callable(self,"_on_loop_sound").bind(self))
	play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_loop_sound(player):
	play()
