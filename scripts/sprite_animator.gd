class_name SpriteAnimator

extends Node2D

var animations: Array[SpriteAnimation]
var oneShotAnimationSlot: SpriteAnimation

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children(false);
	for child in children:
		if child is SpriteAnimation:
			animations.append(child)
	push_warning("Animations loaded: " + str(animations.size()))
	DeactivateAll()
	Activate(animations[0])

func DeactivateAll():
	for animation in animations:
		animation.set_process(false)
		animation.visible = false
		
func Activate(animation: SpriteAnimation):
	if animation.visible:
		return
	DeactivateAll()
	animation.visible = true
	animation.set_process(true)
	animation.Reset()
	
func IsOneShotDone():
	if oneShotAnimationSlot == null:
		return true
	
	if oneShotAnimationSlot.visible:
		return false
	else:
		return true
	
	
func ActivateByName(animName: String):
	for animation in animations:
		if animation.name == animName:
			Activate(animation)

func Play(animation: SpriteAnimation):
	if IsOneShotDone() == false:
		return false
	oneShotAnimationSlot = animation
	Activate(oneShotAnimationSlot)
	return true
	
func PlayByName(animName: String):
	for animation in animations:
		if animation.name == animName:
			Play(animation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if oneShotAnimationSlot:
		var currentTime = oneShotAnimationSlot.animationTime
		var currentScaledFrame = currentTime / oneShotAnimationSlot.frameTime
		if currentScaledFrame > (oneShotAnimationSlot.hframes * oneShotAnimationSlot.vframes) - 1:
			# off by one, hihi
			# Do not clear it here, let it live
			oneShotAnimationSlot = null
		
	
