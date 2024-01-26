class_name Plant extends Sprite2D

@export var GrowthState : int
@export var TimeForStateIncrease : float
@export var MushroomTypeStartIndex : int

var timer = 0.0

func set_growth_state(state: int):
	
	self.frame = (MushroomTypeStartIndex * 4) + state
	print("set frame: " + str(self.frame))
	GrowthState = state

func inc_growth_state():
	if GrowthState >= 3:
		return
		
	set_growth_state(GrowthState+1)

func pick():
	queue_free()


func get_growth_state():
	return GrowthState

# Called when the node enters the scene tree for the first time.
func _ready():
	set_growth_state(GrowthState)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_growth_state(GrowthState)
	
	timer += delta
	
	if timer > TimeForStateIncrease:
		inc_growth_state()
		timer = 0
	
