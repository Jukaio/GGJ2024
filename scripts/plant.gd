class_name Plant extends Sprite2D

@export var GrowthState : int

func set_growth_state(state: int):
	self.frame = state
	GrowthState = state

func inc_growth_state():
	if GrowthState >= 3:
		return
		
	set_growth_state(GrowthState+1)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_growth_state(GrowthState)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_growth_state(GrowthState)
	
