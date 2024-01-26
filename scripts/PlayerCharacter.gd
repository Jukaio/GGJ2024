class_name PlayerCharacter

extends Node2D

enum MoveAction { DOWN, UP, LEFT, RIGHT }

@onready var Collider : CollisionShape2D = $Area2D/CollisionShape2D
@onready var DirectionArea : Area2D = $Area2D

@export var speed: float = 90.0
@export var fieldMap: TileMap

var lookDirection: Vector2 = Vector2.DOWN

var isColliding = false

var movementInput: Array[MoveAction]

var animator: SpriteAnimator
var hoeTool: HoeTool
# Called when the node enters the scene tree for the first time.
func _ready():
	animator = get_node("SpriteAnimator")
	hoeTool = get_node("HoeTool")

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
		
	if !movementInput.is_empty():
		ProcessMovement(delta)
	else:
		ProcessIdle(delta)
	
func ProcessMovement(delta):
	
	var tmpLookDirection = lookDirection
	lookDirection = GetFourAxisDirection(delta)
	
	if tmpLookDirection != lookDirection:
		DirectionArea.position = lookDirection.normalized() * DirectionArea.position
		isColliding = false
	# TODO: implement eight-axis 
	
	if isColliding:
		return
	
	var angle = rad_to_deg(atan2(lookDirection.y, lookDirection.x));
	if angle > -45.0 && angle < 45.0:
		animator.ActivateByName("MoveRight")
	elif angle >= 45.0 && angle < 135.0:
		animator.ActivateByName("MoveDown") 
	elif angle <= -45.0 && angle > -135.0:
		animator.ActivateByName("MoveUp")
	else:
		animator.ActivateByName("MoveLeft")
	position += lookDirection * speed * delta

func GetFourAxisDirection(delta):
	var direction = Vector2.ZERO
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
	# TODO: Implement eight axis!
	direction = direction.normalized()
	return direction

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
	print("collision with shape")
	isColliding = true
	
	pass # Replace with function body.
