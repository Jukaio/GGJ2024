class_name ShopKeeperCharacter extends Node2D

@export var StartPos : Vector2
@export var EndPos : Vector2
@export var Speed : float
@export var TimeForOpenShop : float
@export var TimeForClosedShop : float

@onready var animator : SpriteAnimator = $SpriteAnimator

enum ShopKeeperState { ENTERING, SHOP_OPEN, EXITING, SHOP_CLOSED }

var timeElapsed = 0.0

var state : ShopKeeperState = ShopKeeperState.SHOP_CLOSED

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_state_machine(delta)
	
	
func process_state_machine(delta):
	
	timeElapsed += delta
	
	var dir = Vector2.DOWN
	
	match state:
		ShopKeeperState.ENTERING:
			if position != EndPos:
				dir = (position - StartPos).normalized()
				
				position = position.move_toward(EndPos, delta * Speed)
				
				animate_movement(dir)
			else:
				position = EndPos
				state = ShopKeeperState.SHOP_OPEN
				timeElapsed = 0
				dir = Vector2.DOWN
		
		ShopKeeperState.SHOP_OPEN:
			process_idle(Vector2.DOWN, delta)
			
			if timeElapsed > TimeForOpenShop:
				state = ShopKeeperState.EXITING
				timeElapsed = 0
				
		ShopKeeperState.EXITING:
			if position != StartPos:
				dir = (position - EndPos).normalized()
				
				position = position.move_toward(StartPos, delta * Speed)
				
				animate_movement(dir)
			else:
				position = StartPos
				state = ShopKeeperState.SHOP_CLOSED
				timeElapsed = 0
		
		ShopKeeperState.SHOP_CLOSED:
			if timeElapsed > TimeForClosedShop:
				state = ShopKeeperState.ENTERING
				timeElapsed = 0
				
	
func process_idle(dir, delta):
	var angle = rad_to_deg(atan2(dir.y, dir.x));
	if angle > -45.0 && angle < 45.0:
		animator.ActivateByName("IdleRight")
	elif angle >= 45.0 && angle < 135.0:
		animator.ActivateByName("IdleDown") 
	elif angle <= -45.0 && angle > -135.0:
		animator.ActivateByName("IdleUp")
	else:
		animator.ActivateByName("IdleLeft")
		


func animate_movement(dir: Vector2):
	var angle = rad_to_deg(atan2(dir.y, dir.x));
	if angle > -45.0 && angle < 45.0:
		animator.ActivateByName("MoveRight")
	elif angle >= 45.0 && angle < 135.0:
		animator.ActivateByName("MoveDown") 
	elif angle <= -45.0 && angle > -135.0:
		animator.ActivateByName("MoveUp")
	else:
		animator.ActivateByName("MoveLeft")
	
