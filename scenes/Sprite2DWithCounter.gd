class_name Sprite2DWithCounter

extends Sprite2D

@export var counter_label: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(counter_label)
	pass # Replace with function body.

func set_count(value: int):
	counter_label.text = "x%d" % value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
