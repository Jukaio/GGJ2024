class_name HoeTool

extends Node2D

var hoeSound = preload("res://sounds/Hoe.wav")
var liftSound = preload("res://sounds/Lift.wav")

var audioPlayer : AudioStreamPlayer = null

@export var hoeLength: float = 8.0
@export var highlightNode: Node2D
@export var hoeTime: float = 1.0
@export var liftUpTime: float = 0.5

signal plant_picked_up(plant)

#var is_holding_plant: bool = false
var was_interact_pressed_this_frame: bool = false

var player_character: PlayerCharacter
var is_hoeing: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	player_character = get_parent() as PlayerCharacter
	
	audioPlayer = get_tree().get_root().get_node("EntryPoint/AudioStreamPlayer")
	
	assert(audioPlayer != null, "audioPlayer is null")
	

func on_hoe(at: Vector2):
	
	audioPlayer.stream = hoeSound
	audioPlayer.play()
	

func hoe(tileMap: TileMap):
	var target_position = player_character.position + (player_character.lookDirection * hoeLength)
	var idx = tileMap.local_to_map(target_position)
	var current_cell = tileMap.get_cell_atlas_coords(0, idx)
	
	tileMap.set_cell(0, idx, 0, Vector2i(1, 0))
	
	on_hoe(target_position)

func get_target_plant():
	var target_position = player_character.global_position + (player_character.lookDirection * hoeLength)
	
	var position_in_grid = target_position - player_character.cropsGrid.global_position
	var plant = player_character.cropsGrid.get_plant_at_position(position_in_grid)
	print(position_in_grid)
	if plant != null:
		print("mushroom position in grid: " + str(position_in_grid) + " name: " + plant.name)
		
		return plant
	
	return null
		
func is_valid_to_hoe():
	var seedMap = player_character.seedMap
	var fieldMap = player_character.fieldMap
	
	var target_position = player_character.position + (player_character.lookDirection * hoeLength)
	var idx = fieldMap.local_to_map(target_position)
	var current_field_cell = fieldMap.get_cell_atlas_coords(0, idx)
	
	idx = seedMap.local_to_map(target_position)
	var current_seed_cell = seedMap.get_cell_atlas_coords(0, idx)
	
	return current_field_cell == Vector2i(4, 0) && current_seed_cell == Vector2i(-1, -1)
		
func highlight(tileMap: TileMap):
	var target_position = player_character.position + (player_character.lookDirection * hoeLength)
	var idx = tileMap.local_to_map(target_position)
	var highlightPosition = tileMap.map_to_local(idx)
	
	highlightNode.visible = true
	highlightNode.global_position = highlightPosition


func on_animation_override(delta, inputDir):
	if !player_character.PickedUpMushroom.visible:
		return false
	
	var is_moving = inputDir.length_squared() > 0.0
	
	var animator = player_character.animator
	var direction = player_character.get_look_direction()
	
	if is_moving:
		match direction:
			PlayerCharacter.MoveAction.RIGHT:
				animator.ActivateByName("LiftMoveRight")
			PlayerCharacter.MoveAction.LEFT:
				animator.ActivateByName("LiftMoveLeft")
			PlayerCharacter.MoveAction.UP:
				animator.ActivateByName("LiftMoveUp")
			PlayerCharacter.MoveAction.DOWN:
				animator.ActivateByName("LiftMoveDown")
		player_character.apply_movement(delta, inputDir)
	else:
		match direction:
			PlayerCharacter.MoveAction.RIGHT:
				animator.ActivateByName("LiftIdleRight")
			PlayerCharacter.MoveAction.LEFT:
				animator.ActivateByName("LiftIdleLeft")
			PlayerCharacter.MoveAction.UP:
				animator.ActivateByName("LiftIdleUp")
			PlayerCharacter.MoveAction.DOWN:
				animator.ActivateByName("LiftIdleDown")
	return true
	
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	was_interact_pressed_this_frame = Input.is_action_just_pressed("interact")

	var seedMap = player_character.seedMap
	var fieldMap = player_character.fieldMap
	var animator = player_character.animator
	
	# now means is_interacting!!
	var was_hoeing = is_hoeing
	is_hoeing = animator.oneShotAnimationSlot != null && animator.oneShotAnimationSlot.name.contains("Hoe")


	if is_hoeing || seedMap == null || fieldMap == null || !is_valid_to_hoe():
		highlightNode.visible = false
		return
	
	if !is_hoeing && was_hoeing:
		hoe(fieldMap)
			
		
	highlight(seedMap)
	

func interact():
	var animator = player_character.animator
	
	var cropsGrid = player_character.cropsGrid
	
	var plant = get_target_plant()
	
	if player_character.PickedUpMushroom.visible: 
		return
	
	var direction = player_character.get_look_direction()
	if plant != null:
		# there is a plant in front of us
		if plant.attempt_pick():
			audioPlayer.stream = liftSound
			audioPlayer.play()
			
			player_character.PickedUpMushroom.visible = true
			player_character.PickedUpMushroom.frame = plant.frame
			
			plant_picked_up.emit(plant)
			match direction:
				PlayerCharacter.MoveAction.RIGHT:
					animator.PlayByName("LiftUpRight")
				PlayerCharacter.MoveAction.LEFT:
					animator.PlayByName("LiftUpLeft")
				PlayerCharacter.MoveAction.UP:
					animator.PlayByName("LiftUpUp")
				PlayerCharacter.MoveAction.DOWN:
					animator.PlayByName("LiftUpDown")
			animator.oneShotAnimationSlot.frameTime = liftUpTime / animator.oneShotAnimationSlot.total_frames()
			return
	
	if !is_valid_to_hoe():
		return
	
	match direction:
		PlayerCharacter.MoveAction.RIGHT:
			animator.PlayByName("HoeRight")
		PlayerCharacter.MoveAction.LEFT:
			animator.PlayByName("HoeLeft")
		PlayerCharacter.MoveAction.UP:
			animator.PlayByName("HoeUp")
		PlayerCharacter.MoveAction.DOWN:
			animator.PlayByName("HoeDown")
			
	animator.oneShotAnimationSlot.frameTime = hoeTime / animator.oneShotAnimationSlot.total_frames()
	
