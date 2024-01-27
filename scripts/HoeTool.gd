class_name HoeTool

extends Node2D

@export var hoeLength: float = 8.0
@export var highlightNode: Node2D
@export var hoeTime: float = 1.0

signal plant_picked_up(plant)

var player_character: PlayerCharacter
var is_hoeing: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	player_character = get_parent() as PlayerCharacter

func on_hoe(at: Vector2):
	# fill out with sound, VFX, and RUTA FUCK FOPT FG
	pass

func hoe(tileMap: TileMap):
	var target_position = player_character.position + (player_character.lookDirection * hoeLength)
	var idx = tileMap.local_to_map(target_position)
	var current_cell = tileMap.get_cell_atlas_coords(0, idx)
	
	tileMap.set_cell(0, idx, 1, Vector2i(0, 0))
	
	on_hoe(target_position)

func get_target_plant():
	var target_position = player_character.position + (player_character.lookDirection * hoeLength)
	
	var position_in_grid = player_character.cropsGrid.global_position - target_position
	var plant = player_character.cropsGrid.get_plant_at_position(position_in_grid)
	
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
	
	return current_field_cell == Vector2i(4, 0) && current_seed_cell != Vector2i(0, 0)
		
func highlight(tileMap: TileMap):
	var target_position = player_character.position + (player_character.lookDirection * hoeLength)
	var idx = tileMap.local_to_map(target_position)
	var highlightPosition = tileMap.map_to_local(idx)
	
	highlightNode.visible = true
	highlightNode.global_position = highlightPosition

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var seedMap = player_character.seedMap
	var fieldMap = player_character.fieldMap
	var animator = player_character.animator
	
	var was_hoeing = is_hoeing
	is_hoeing = animator.oneShotAnimationSlot != null

	if is_hoeing || seedMap == null || fieldMap == null || !is_valid_to_hoe():
		highlightNode.visible = false
		return
	
	if !is_hoeing && was_hoeing:
		hoe(seedMap)
		
	highlight(seedMap)
	

func interact():
	var animator = player_character.animator
	var direction = player_character.get_look_direction()
	
	var cropsGrid = player_character.cropsGrid
	
	var plant = get_target_plant()
	
	if plant != null:
		# there is a plant in front of us
		if plant.attempt_pick():
			plant_picked_up.emit(plant)
	
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
	
