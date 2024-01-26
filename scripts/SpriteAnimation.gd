class_name SpriteAnimation

extends Sprite2D

@export var frameTime: float = 0.16
var animationTime: float = 0.0

func total_frames():
	return hframes * vframes

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func Reset():
	animationTime = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animationTime += delta;
	var currentFrame = animationTime / frameTime;
	frame = int(currentFrame) % total_frames();
