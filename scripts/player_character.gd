class_name PlayerCharacter
extends CharacterBody2D

enum MoveAction { DOWN, UP, LEFT, RIGHT }

@onready var Collider : CollisionShape2D = $Area2D/CollisionShape2D
@onready var DirectionArea : Area2D = $Area2D
@onready var PickedUpMushroom : Plant = $PickingUpSprite/MushroomSprite
@onready var Shadow : Sprite2D = $Shadow
@onready var ShadowLeft : Sprite2D = $ShadowLeft
@onready var ShadowRight : Sprite2D = $ShadowRight


@export var Money : int
@export var speed: float = 90.0
@export var fieldMap: TileMap
@export var cropsGrid: CropsGrid
@export var ui: UI
@export var sales_bucket: SalesBucket
@export var SmokeEffect : SpriteAnimation

var lookDirection: Vector2 = Vector2.DOWN

var isColliding = false

var movementInput: Array[MoveAction]

var selectedShopItems: Array[ShopPurchaseSlot]

var animator: SpriteAnimator
var hoeTool: HoeTool
# Called when the node enters the scene tree for the first time.

static var g_use_eight_way : bool = false
static var g_use_eight_way_inited : bool = true
static var g_always_random : bool = false

var smoke_cooldown = 0.0

func get_use_eight_way():
	if g_use_eight_way_inited:
		return g_use_eight_way
	
	var config = ConfigFile.new()
	var file_path = "user://persistent_data.cfg"
	var error = config.load(file_path)
	
	if error != OK or g_always_random:
		g_use_eight_way = RandomNumberGenerator.new().randi_range(0,1) == 1
		config.set_value("Settings", "use_eight_way", g_use_eight_way)
		config.save(file_path)
		
	else:
		var default = RandomNumberGenerator.new().randi_range(0,1) == 1
		g_use_eight_way = config.get_value("Settings", "use_eight_way", default)
		
	g_use_eight_way_inited = true
	return g_use_eight_way

func _ready():
	SmokeEffect.visible = false
	SmokeEffect.set_one_shot(true)
	animator = get_node("SpriteAnimator")
	hoeTool = get_node("HoeTool")
	PickedUpMushroom.visible = false
	
	Shadow.visible = true
	ShadowLeft.visible = false
	ShadowRight.visible = false


func PushMovementAction(action: MoveAction):
	if movementInput.find(action) == -1:
		movementInput.append(action)
		return
	push_warning("DOUBLE PUSH INPUT???!!")

func PopMovementAction(action: MoveAction):
	var index = movementInput.find(action);
	if index != -1:
		movementInput.remove_at(index);
		return;
	push_warning("DOUBLE POP INPUT???!!")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	smoke_cooldown += delta
	
	sales_bucket.set_money_sign_animating(PickedUpMushroom.visible)
	ui.set_money_text(Money)

	# Fix later -> 8 axis
	# TODO: Nvm, add 8-axis movement -> 50% chance to use 4-axis or 8-axis
	# TODO: David
	if Input.is_action_just_pressed("left"):
		PushMovementAction(MoveAction.LEFT)
	if Input.is_action_just_pressed("right"):
		PushMovementAction(MoveAction.RIGHT)
	if Input.is_action_just_pressed("up"):
		PushMovementAction(MoveAction.UP)
	if Input.is_action_just_pressed("down"):
		PushMovementAction(MoveAction.DOWN)
		
	if Input.is_action_just_released("left"):
		PopMovementAction(MoveAction.LEFT)
	if Input.is_action_just_released("right"):
		PopMovementAction(MoveAction.RIGHT)
	if Input.is_action_just_released("up"):
		PopMovementAction(MoveAction.UP)
	if Input.is_action_just_released("down"):
		PopMovementAction(MoveAction.DOWN)
		
	if !animator.IsOneShotDone():
		return
	
	var dir = GetEightAxisDirection(delta) if get_use_eight_way() else GetFourAxisDirection(delta)
	var overwroteAnimation = hoeTool.on_animation_override(delta, dir)
	
	if !overwroteAnimation:
		if dir.is_zero_approx() or movementInput.is_empty():
			ProcessIdle(delta)
		else:
			ProcessMovement(delta, dir)
		
	if Input.is_action_just_pressed("interact"):
		hoeTool.interact()
		
	process_purchase(delta)
		

func process_purchase(delta):	
	var closest: ShopPurchaseSlot = null
	var delta_distance = 133737.0
	for item in selectedShopItems:
		if not item.visible:
			continue
			
		item.highlight.visible = false
		var distance = global_position.distance_to(item.global_position)
		if distance < delta_distance:
			delta_distance = distance
			closest = item
	
	if closest == null:
		return	
	
	closest.highlight.visible = true
	
	if not Input.is_action_just_pressed("interact"):
		return
	
	

	if closest.Cost <= Money:
		if !ui.is_full() || ui.contains(closest.frame):
			Money -= closest.Cost
			closest.purchased()
			ui.add_item(closest.frame, 1)

func ProcessMovement(delta, dir):
	apply_movement(delta, dir)
	
	var angle = rad_to_deg(atan2(lookDirection.y, lookDirection.x));
	if angle > -45.0 && angle < 45.0:
		Shadow.visible = false
		ShadowLeft.visible = false
		ShadowRight.visible = true
		
		animator.ActivateByName("MoveRight")
		
	elif angle >= 45.0 && angle < 135.0:
		Shadow.visible = true
		ShadowLeft.visible = false
		ShadowRight.visible = false

		animator.ActivateByName("MoveDown")
		
	elif angle <= -45.0 && angle > -135.0:
		Shadow.visible = true
		ShadowLeft.visible = false
		ShadowRight.visible = false

		animator.ActivateByName("MoveUp")
		
	else:
		Shadow.visible = false
		ShadowLeft.visible = true
		ShadowRight.visible = false

		animator.ActivateByName("MoveLeft")
		
	if smoke_cooldown > 2.0:
		SmokeEffect.global_position = global_position
		SmokeEffect.visible = true
		SmokeEffect.Reset()
		smoke_cooldown = 0.0
		
	
func apply_movement(delta, dir):
	var tmpLookDirection = lookDirection
	lookDirection = dir
	
	if tmpLookDirection != lookDirection:
		DirectionArea.position = lookDirection.normalized() * DirectionArea.position
		isColliding = false
	
	if isColliding:
		return
	
	var move =  lookDirection * speed * delta
	var collision = move_and_collide(move)


func GetFourAxisDirection(delta):
	var direction = Vector2.ZERO
	if movementInput.is_empty():
		return direction
	
	var moveAction = movementInput.back()

	match moveAction:
		MoveAction.LEFT:
			direction += Vector2.LEFT
		MoveAction.RIGHT:
			direction += Vector2.RIGHT
		MoveAction.UP:
			direction += Vector2.UP
		MoveAction.DOWN:
			direction += Vector2.DOWN
	direction = direction.normalized()
	return direction
	
func GetEightAxisDirection(delta):
	var direction = Vector2.ZERO
	for action in movementInput:
		match action:
			MoveAction.LEFT:
				direction += Vector2.LEFT
			MoveAction.RIGHT:
				direction += Vector2.RIGHT
			MoveAction.UP:
				direction += Vector2.UP
			MoveAction.DOWN:
				direction += Vector2.DOWN
	
	direction = direction.normalized()
	return direction

func get_look_direction():
	var angle = rad_to_deg(atan2(lookDirection.y, lookDirection.x));
	if angle > -45.0 && angle < 45.0:
		return MoveAction.RIGHT
	elif angle >= 45.0 && angle < 135.0:
		return MoveAction.DOWN
	elif angle <= -45.0 && angle > -135.0:
		return MoveAction.UP
	else:
		return MoveAction.LEFT

func ProcessIdle(delta):
	var angle = rad_to_deg(atan2(lookDirection.y, lookDirection.x));
	if angle > -45.0 && angle < 45.0:
		animator.ActivateByName("IdleRight")
	elif angle >= 45.0 && angle < 135.0:
		animator.ActivateByName("IdleDown") 
	elif angle <= -45.0 && angle > -135.0:
		animator.ActivateByName("IdleUp")
	else:
		animator.ActivateByName("IdleLeft")


func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	#isColliding = true
	pass


func _on_hoe_tool_plant_picked_up(plant):
	# Probably unused
	print("player picked up plant: " + plant.name)
	PickedUpMushroom.visible = true



func _on_purchase_slot_1_shop_item_selected(shop_item: ShopPurchaseSlot, cost):
	print("slot 1 purchase, cost: " + str(cost))
	
	if selectedShopItems.find(shop_item) == -1:
		selectedShopItems.append(shop_item)


func _on_purchase_slot_1_shop_item_unselected(shop_item: ShopPurchaseSlot, cost):
	selectedShopItems.erase(shop_item)
