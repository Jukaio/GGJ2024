class_name SalesBucket extends Sprite2D

var dunk_in_bin_sound = preload("res://sounds/dunk_in_bin.wav")
var sell_sound = preload("res://sounds/sell.wav")

@onready var moneyLabel : Label = $MoneyEarnedLabel
@onready var money_sign : Sprite2D = $MoneySign
@onready var bucket_shadow : Sprite2D = $BucketShadow

@export var time_for_money_animation : int
@export var players_in_range: Array[PlayerCharacter]
@export var audio_player : AudioStreamPlayer

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
	
	animate_bucket(delta)
	
	if money_sign_animating:
		time_elapsed += delta
		
		if time_elapsed > time_for_money_animation:
			flip_money_sign()
			time_elapsed = 0
	
	for player in players_in_range:
		if player.PickedUpMushroom && player.PickedUpMushroom.visible && player.hoeTool.was_interact_pressed_this_frame:
			player.PickedUpMushroom.visible = false
			var base_value = (player.PickedUpMushroom.MushroomTypeStartIndex + 1)
			var sales_value = 2 + base_value + (base_value * 2)
			
			add_item(player, sales_value)

func add_item(player: PlayerCharacter, money_value: int):
	
	set_bucket_animating(true)
	
	audio_player.stream = dunk_in_bin_sound
	audio_player.volume_db = 20.0
	audio_player.play()
	
	player.Money += money_value
	
	moneyLabel.position = labelStartPosition
	moneyLabel.text = str(money_value) + "$"
	
	var tween_delay = get_tree().create_tween()
	
	tween_delay.tween_callback(show_money_label).set_delay(1)
	

func show_money_label():
	audio_player.stream = sell_sound
	audio_player.volume_db = 0.0
	audio_player.play()
	
	moneyLabel.visible = true
	
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
