class_name Plant extends Sprite2D

@export var GrowthState : int
@export var TimeForStateIncrease : float
@export var MushroomTypeStartIndex : int
@export var EnabledCollider : bool

@onready var Collider : CollisionShape2D = $Area2D/CollisionShape2D


var timer = 0.0
var animation_timer = 0.0
var frame_index = 0

func set_growth_state(state: int):
	
	self.frame = (MushroomTypeStartIndex * hframes) + state
	
	if GrowthState == 0:
		Collider.disabled = true
	else:
		Collider.disabled = false
	
	GrowthState = state

func animate_mushroom(delta):
	
	if not visible:
		return
	
	animation_timer += delta
	
	if animation_timer > 0.3:
		animation_timer = 0
		
		frame_index = frame_index + 1
		
		if frame_index > 2:
			frame_index = 0
			
		set_growth_state_frame(frame_index)
		

func set_growth_state_frame(index: int):
	if GrowthState == 0 || GrowthState == 1:
		return
	
	self.frame = (MushroomTypeStartIndex * hframes) + GrowthState + (index * 2)
	

func inc_growth_state():
	if GrowthState >= 3:
		return
		
	set_growth_state(GrowthState+1)


func attempt_pick():
	if visible == false:
		return false
		
	visible = false
	
	if GrowthState < 3:
		return false
	
	return true


func get_growth_state():
	return GrowthState

# Called when the node enters the scene tree for the first time.
func _ready():
	set_growth_state(GrowthState)
	Collider.disabled = not EnabledCollider
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	
	if timer > TimeForStateIncrease:
		inc_growth_state()
		timer = 0
	
	if GrowthState == 2 || GrowthState == 3:
		animate_mushroom(delta)
	else:
		set_growth_state(GrowthState)
