class_name HoeTool

extends Node2D

var hoeSound = preload("res://sounds/Hoe.wav")
var liftSound = preload("res://sounds/Lift.wav")

var audioPlayer : AudioStreamPlayer = null

@export var hoeLength: float = 8.0
@export var highlightNode: Node2D
@export var hoeTime: float = 1.0
@export var seedTime: float = 1.0
@export var liftUpTime: float = 0.5

signal plant_picked_up(plant)

#var is_holding_plant: bool = false
var was_interact_pressed_this_frame: bool = false

var player_character: PlayerCharacter
var is_hoeing: bool = false
var is_seeding: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	player_character = get_parent() as PlayerCharacter
	
	audioPlayer = get_tree().get_root().get_node("EntryPoint/AudioStreamPlayer")
	
	assert(audioPlayer != null, "audioPlayer is null")
	

func on_hoe(at: Vector2):
	pass
	

func hoe(tileMap: TileMap):
	var target_position = player_character.position + (player_character.lookDirection * hoeLength)
	var idx = get_target_cell_idx(tileMap)
	var current_cell = tileMap.get_cell_atlas_coords(0, idx)
	
	tileMap.set_cell(0, idx, 0, Vector2i(1, 0))
	
	on_hoe(target_position)

func seed_field(crops_field: CropsGrid, frameId: int):
	var plant = get_target_plant()
	plant.MushroomTypeStartIndex = frameId / plant.hframes
	plant.set_growth_state(0)
	plant.visible = true
	

func get_target_plant() -> Plant:
	var target_position = player_character.global_position + (player_character.lookDirection * hoeLength)
	
	var position_in_grid = target_position - player_character.cropsGrid.global_position
	var plant = player_character.cropsGrid.get_plant_at_position(position_in_grid)
	
	if plant != null:
		return plant
	
	return null
		
func is_valid_to_hoe():
	var fieldMap = player_character.fieldMap
	
	var idx = get_target_cell_idx(fieldMap)
	var current_field_cell = fieldMap.get_cell_atlas_coords(0, idx)
	
	var plant = get_target_plant()
	
	return (current_field_cell == Vector2i(4, 0) && plant != null) || (current_field_cell == Vector2i(1, 0) && plant != null && plant.visible)
	
func is_valid_to_seed():
	var equipped_item = player_character.ui.get_equipped_item()
	if equipped_item == null:
		return false
	
	# if hoe
	if equipped_item.x == 3  || equipped_item.y == 0:
		return false
	
	var fieldMap = player_character.fieldMap
	var idx = get_target_cell_idx(fieldMap)
	var current_field_cell = fieldMap.get_cell_atlas_coords(0, idx)

	var plant = get_target_plant()
	
	return current_field_cell == Vector2i(1, 0) && plant != null && !plant.visible
		
func get_target_cell_idx(tileMap: TileMap):
	var target_position = player_character.global_position + (player_character.lookDirection * hoeLength)
	var local_in_tilemap = tileMap.to_local(target_position)
	
	var idx = tileMap.local_to_map(local_in_tilemap)
	return idx
		
func highlight(tileMap: TileMap):
	var idx = get_target_cell_idx(tileMap)
	var highlight_position = tileMap.map_to_local(idx)
	
	highlightNode.visible = true
	var global_highLight_position = tileMap.to_global(highlight_position)
	highlightNode.global_position.x = ceilf(global_highLight_position.x)
	highlightNode.global_position.y = ceilf(global_highLight_position.y)


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

	var fieldMap = player_character.fieldMap
	var crops_field = player_character.cropsGrid
	if player_character.PickedUpMushroom.visible || fieldMap == null:
		highlightNode.visible = false
		return

	var animator = player_character.animator
	
	# now means is_interacting!!
	var was_hoeing = is_hoeing
	is_hoeing = animator.oneShotAnimationSlot != null && animator.oneShotAnimationSlot.name.contains("Hoe")

	var was_seeding = is_seeding
	is_seeding = animator.oneShotAnimationSlot != null && animator.oneShotAnimationSlot.name.contains("Seed")

	if (is_hoeing || !is_valid_to_hoe()) && (is_seeding || !is_valid_to_seed()):
		highlightNode.visible = false
		return
	
	if !is_hoeing && was_hoeing:
		hoe(fieldMap)
		
	if !is_seeding && was_seeding:
		var equipped_item = player_character.ui.get_equipped_item()
		var frame = equipped_item.x
		equipped_item.y = equipped_item.y - 1
		seed_field(crops_field, frame)
		
		if equipped_item.y == 0:
			player_character.ui.try_remove_equipped_item()
		
		
	highlight(fieldMap)
	

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
			player_character.PickedUpMushroom.MushroomTypeStartIndex = plant.MushroomTypeStartIndex
			player_character.PickedUpMushroom.set_growth_state(plant.GrowthState)
			
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
		if is_valid_to_seed():
			match direction:
				PlayerCharacter.MoveAction.RIGHT:
					animator.PlayByName("SeedRight")
				PlayerCharacter.MoveAction.LEFT:
					animator.PlayByName("SeedLeft")
				PlayerCharacter.MoveAction.UP:
					animator.PlayByName("SeedUp")
				PlayerCharacter.MoveAction.DOWN:
					animator.PlayByName("SeedDown")
			
			animator.oneShotAnimationSlot.frameTime = seedTime / animator.oneShotAnimationSlot.total_frames()
			return
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
			
	audioPlayer.stream = hoeSound
	audioPlayer.play()
	
	animator.oneShotAnimationSlot.frameTime = hoeTime / animator.oneShotAnimationSlot.total_frames()
	
