class_name ShopPurchaseSlot extends Sprite2D

@onready var priceLabel : Label = $PriceLabel
@onready var shopItemPlant : Plant = $MushroomSprite

@export var Cost : int 

signal shop_item_selected(plant, cost)


func set_shop_item(mushroomTypeStartIndex: int, cost: int):
	shopItemPlant.MushroomTypeStartIndex = mushroomTypeStartIndex
	Cost = cost
	
	priceLabel.text = str(cost)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_purchase_1_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if not visible:
		return
	
	if area.get_parent() is PlayerCharacter:
		shop_item_selected.emit(area as Plant, Cost)
	
