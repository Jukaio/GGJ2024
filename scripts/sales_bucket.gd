class_name SalesBucket extends Sprite2D

@onready var moneyLabel : Label = $MoneyEarnedLabel
@onready var money_sign : Sprite2D = $MoneySign

@export var time_for_money_animation : int
@export var players_in_range: Array[PlayerCharacter]

var labelStartPosition = Vector2.ZERO

var money_sign_animating = false

var time_elapsed = 0.0


func set_money_sign_animating(animating: bool):
	money_sign_animating = animating
	

# Called when the node enters the scene tree for the first time.
func _ready():
	set_money_sign_animating(true)
	moneyLabel.visible = false
	
	labelStartPosition = moneyLabel.position

func flip_money_sign():
	if money_sign.frame == 0:
		money_sign.frame = 1
	else:
		money_sign.frame = 0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta
	
	if money_sign_animating:
		if time_elapsed > time_for_money_animation:
			flip_money_sign()
			time_elapsed = 0
	
	for player in players_in_range:
		if player.PickedUpMushroom && player.hoeTool.was_interact_pressed_this_frame:
			player.PickedUpMushroom.visible = false
			add_item(100)

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
	if !(area.get_parent() is PlayerCharacter):
		return
	
	var player_character = area.get_parent() as PlayerCharacter
	if players_in_range.find(player_character) != -1:
		push_error("DOUBLE APPEND????")
		return
	
	players_in_range.append(player_character)
	

func _on_area_2d_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if !(area.get_parent() is PlayerCharacter):
		return
	
	var player_character = area.get_parent() as PlayerCharacter
	players_in_range.erase(player_character)
