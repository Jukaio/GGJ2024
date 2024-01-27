class_name ShopPurchaseSlot extends Sprite2D

var purchaseSound = preload("res://sounds/purchase.wav")

@onready var priceLabel : Label = $PriceLabel
@onready var shopItemPlant : Plant = $MushroomSprite

@export var Cost : int 
@export var audioPlayer : AudioStreamPlayer

signal shop_item_selected(shop_item : ShopPurchaseSlot, cost: int)

func purchased():
	visible = false
	if not audioPlayer.is_playing():
		audioPlayer.stream = purchaseSound
		audioPlayer.play()

func set_shop_item(mushroomTypeStartIndex: int, cost: int):
	shopItemPlant.MushroomTypeStartIndex = mushroomTypeStartIndex
	Cost = cost
	visible = true
	
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
		shop_item_selected.emit(self, Cost)
	
