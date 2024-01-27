class_name SpriteAnimation

extends Sprite2D

@export var frameTime: float = 0.16
var animationTime: float = 0.0

var is_oneshot = false

func total_frames():
	return hframes * vframes

func total_animation_time():
	return total_frames() * frameTime

# Called when the node enters the scene tree for the first time.
func _ready():
	is_oneshot = false

func set_one_shot(oneshot: bool):
	is_oneshot = oneshot

func Reset():
	animationTime = 0.0
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animationTime += delta;
	
	var currentFrame = animationTime / frameTime;
	
	if is_oneshot and total_animation_time() < animationTime:
		visible = false
		return

	frame = int(currentFrame) % total_frames();
		
