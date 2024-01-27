class_name UI extends CanvasLayer

@onready var MainMenuUI : Control = $MainMenu

@export var hotbar_slots:Array[Sprite2D]

var inventory:Array[Vector2i]

var hState:int

func rotl():
	if inventory.size() <= 2:
		return
		
	var temp = inventory[0]
	for i in range(0, inventory.size()-1):
		inventory[i] = inventory[i+1]
		
	inventory[-1] = temp
	
func rotr():
	if inventory.size() <= 2:
		return
		
	var temp = inventory.back()
	for i in range(inventory.size()-1, 0, -1):
		inventory[i] = inventory[i-1]
		
	inventory[0] = temp
	
	
func add_item(item : int, count : int):
	for inv_item in inventory:
		if inv_item.x == item:
			inv_item.y += count
			return
	
	inventory.append(Vector2i(item, count))
	
func get_equipped_item():
	return inventory.front()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_item(2, 2)
	add_item(2, 2)
	add_item(2, 2)
	add_item(6, 2)
	add_item(8, 2)
	add_item(9, 2)
	add_item(10, 2)
	pass # Replace with function body.

func redraw():
	print("redraw")
	for i in range(hotbar_slots.size()):
		var item = inventory[i]
		if item == null:
			hotbar_slots[i].frame = 0
		else:
			hotbar_slots[i].frame = item.x
			
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("inv_prev"):
		rotl()
	if Input.is_action_just_pressed("inv_next"):
		rotr()
	
	var new_state = hash(inventory)
	if new_state != hState:
		redraw()
	hState = new_state
