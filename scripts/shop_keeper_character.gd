class_name ShopKeeperCharacter extends Node2D

@export var StartPos : Vector2
@export var EndPos : Vector2
@export var Speed : float
@export var TimeForOpenShop : float
@export var TimeForClosedShop : float

@onready var shopSlot1 : ShopPurchaseSlot = $PurchaseSlot1
@onready var shopSlot2 : ShopPurchaseSlot = $PurchaseSlot2
@onready var shopSlot3 : ShopPurchaseSlot = $PurchaseSlot3
@onready var speechBubble : Sprite2D = $SpeechBubbleSprite2D

@onready var animator : SpriteAnimator = $SpriteAnimator

enum ShopKeeperState { ENTERING, SHOP_OPEN, EXITING, SHOP_CLOSED }

var timeElapsed = 0.0
var hideBubbleTimer = 0.0

var state : ShopKeeperState = ShopKeeperState.SHOP_CLOSED

# Called when the node enters the scene tree for the first time.
func _ready():
	
	shopSlot1.set_shop_item(0, 100)
	shopSlot2.set_shop_item(1, 300)
	shopSlot3.set_shop_item(2, 450)
	
	shopSlot1.visible = false
	shopSlot2.visible = false
	shopSlot3.visible = false
	
	speechBubble.visible = false


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
				
				shopSlot1.visible = true
				shopSlot2.visible = true
				shopSlot3.visible = true
				
				speechBubble.visible = true
				
				hideBubbleTimer = 0
		
		ShopKeeperState.SHOP_OPEN:
			process_idle(Vector2.DOWN, delta)
			
			hideBubbleTimer += delta
			
			if hideBubbleTimer > 1.0:
				speechBubble.visible = false
				
			if timeElapsed > TimeForOpenShop:
				state = ShopKeeperState.EXITING
				timeElapsed = 0
				
				shopSlot1.visible = false
				shopSlot2.visible = false
				shopSlot3.visible = false
		
				
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
	
