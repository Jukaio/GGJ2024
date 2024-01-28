class_name SalesBucket extends Sprite2D

@onready var moneyLabel : Label = $MoneyEarnedLabel
@onready var money_sign : Sprite2D = $MoneySign
@onready var bucket_shadow : Sprite2D = $BucketShadow

@export var time_for_money_animation : int
@export var players_in_range: Array[PlayerCharacter]

var labelStartPosition = Vector2.ZERO

var money_sign_animating = false

var time_elapsed = 0.0

var animating_bucket = false
var animation_time = 0.0
var frame_time = 0.1

func animate_bucket(delta):

	if not animating_bucket:
		return
		
	animation_time += delta
	var currentFrame = animation_time / frame_time;
	frame = int(currentFrame) % 4
	bucket_shadow.frame = frame + 4
	
	if frame_time * 4 < animation_time:
		animating_bucket = false
		frame = 0
		bucket_shadow.frame = 4

func set_bucket_animating(animating: bool):
	animating_bucket = animating
	animation_time = 0

func set_money_sign_animating(animating: bool):
	money_sign_animating = animating
	time_elapsed = 0
	

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
	
	animate_bucket(delta)
	
	if money_sign_animating:
		if time_elapsed > time_for_money_animation:
			flip_money_sign()
			time_elapsed = 0
	
	for player in players_in_range:
		if player.PickedUpMushroom && player.PickedUpMushroom.visible && player.hoeTool.was_interact_pressed_this_frame:
			player.PickedUpMushroom.visible = false
			add_item(player, 100)

func add_item(player: PlayerCharacter, money_value: int):
	
	set_bucket_animating(true)
	
	moneyLabel.visible = true
	
	player.Money += money_value
	
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
