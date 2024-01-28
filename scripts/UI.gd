class_name UI extends CanvasLayer

@onready var MainMenuUI : Control = $MainMenu
@export var money_text : RichTextLabel

@export var hotbar_slots:Array[Sprite2DWithCounter]

var inventory:Array[Vector2i]

var hState:int

func rotl():
	if inventory.size() == 2:
		var temp = inventory[0]
		inventory[0] = inventory[1]
		inventory[1] = temp
	
	if inventory.size() <= 2:
		return
		
	var temp = inventory[0]
	for i in range(0, inventory.size()-1):
		inventory[i] = inventory[i+1]
		
	inventory[-1] = temp
	
func rotr():
	if inventory.size() == 2:
		var temp = inventory[0]
		inventory[0] = inventory[1]
		inventory[1] = temp
	
	if inventory.size() <= 2:
		return
	
		
	var temp = inventory.back()
	for i in range(inventory.size()-1, 0, -1):
		inventory[i] = inventory[i-1]
		
	inventory[0] = temp
	
func is_full():
	assert(inventory.size() <= 3, "Too full")
	return inventory.size() == 3
	
func contains(item: int):
	for inv_item in inventory:
		if inv_item.x == item:
			return true
	return false
	
func add_item(item : int, count : int):
	for index in range(0, inventory.size()):
		var inv_item = inventory[index]
		if inv_item.x == item:
			inv_item.y += count

			inventory[index] = inv_item
			return
	
	inventory.append(Vector2i(item, count))

func remove_item(item : int, count : int) -> int:
	for index in range(0, inventory.size()):
		var inv_item = inventory[index]
		if inv_item.x == item:
			var removed_count = min(count, inv_item.y)
			inv_item.y -= removed_count

			inventory[index] = inv_item
			if inv_item.y == 0:
				inventory.remove_at(index)
			return removed_count
	return 0

func try_remove_equipped_item():
	return inventory.pop_front()
	

func get_equipped_item():
	return inventory.front() if inventory.size() > 0 else null 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func redraw():
	for i in range(hotbar_slots.size()):
		if i < inventory.size():
			hotbar_slots[i].visible = true
			hotbar_slots[i].frame = inventory[i].x
			hotbar_slots[i].set_count(inventory[i].y)
		else:
			hotbar_slots[i].visible = false
		
		var parent = hotbar_slots[i].counter_label.get_parent() as Control
		parent.visible = hotbar_slots[i].visible


var g_last_money : int = -123

func set_money_text(value : int):
	if g_last_money != value:
		money_text.text = "x%d" % min(value, 9999)
		g_last_money = value

func _process(delta):
	if Input.is_action_just_pressed("inv_prev"):
		rotr()
	if Input.is_action_just_pressed("inv_next"):
		rotl()
		
	var new_state = hash(inventory)
	if new_state != hState:
		redraw()
	hState = new_state
