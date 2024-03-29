class_name ShopPurchaseSlot extends Sprite2D

var purchaseSound = preload("res://sounds/purchase.wav")

@onready var priceLabel : Label = $PriceLabel
@onready var highlight : Sprite2D = $Highlight

@export var Cost : int 
@export var audioPlayer : AudioStreamPlayer

signal shop_item_selected(shop_item : ShopPurchaseSlot, cost: int)
signal shop_item_unselected(shop_item : ShopPurchaseSlot, cost: int)

var seedType = -1

func get_seed_type() -> int:
	return self.frame / hframes
	
func purchased():
	visible = false
	if not audioPlayer.is_playing():
		audioPlayer.stream = purchaseSound
		audioPlayer.play()

func set_shop_item(mushroomTypeStartIndex: int, cost: int):
	self.seedType = mushroomTypeStartIndex
	self.frame = mushroomTypeStartIndex * hframes
	Cost = cost
	visible = true
	
	priceLabel.text = "$%d"%(cost)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_purchase_1_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	highlight.visible = false
	
	if area.get_parent() is PlayerCharacter:
		shop_item_selected.emit(self, Cost)
	


func _on_purchase_1_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	highlight.visible = false
	
	if area.get_parent() is PlayerCharacter:
		shop_item_unselected.emit(self, Cost)
