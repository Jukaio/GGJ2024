class_name SalesBucket extends Sprite2D

@onready var moneyLabel : Label = $MoneyEarnedLabel

var labelStartPosition = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	moneyLabel.visible = false
	
	labelStartPosition = moneyLabel.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_item(money_value: int):
	
	moneyLabel.visible = true
	
	moneyLabel.position = labelStartPosition
	moneyLabel.text = str(money_value) + "$"
	
	var tween = get_tree().create_tween()
	
	tween.tween_property(moneyLabel, "position", moneyLabel.position + Vector2(0, -20), 1)
	tween.tween_callback(self.hide_label)

func hide_label():
	moneyLabel.visible = false


func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	add_item(100)
