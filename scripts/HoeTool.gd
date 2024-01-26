class_name HoeTool

extends Node2D

@export var hoeLength: float = 8.0
@export var highlightNode: Node2D

var player_character: PlayerCharacter

# Called when the node enters the scene tree for the first time.
func _ready():
	player_character = get_parent() as PlayerCharacter

func on_hue(at: Vector2):
	# fill out with sound, VFX, and RUTA FUCK FOPT FG
	pass

func hoe(tileMap: TileMap):
	var target_position = player_character.position + (player_character.lookDirection * hoeLength)
	var idx = tileMap.local_to_map(target_position)
	var current_cell = tileMap.get_cell_atlas_coords(0, idx)
	
	tileMap.set_cell(0, idx, 0, Vector2i(2, 0))
	
	on_hue(target_position)
		
func is_valid_to_hoe(tileMap: TileMap):
	var target_position = player_character.position + (player_character.lookDirection * hoeLength)
	var idx = tileMap.local_to_map(target_position)
	var current_cell = tileMap.get_cell_atlas_coords(0, idx)
	
	return current_cell ==  Vector2i(4, 0)
		
func highlight(tileMap: TileMap):
	var target_position = player_character.position + (player_character.lookDirection * hoeLength)
	var idx = tileMap.local_to_map(target_position)
	var highlightPosition = tileMap.map_to_local(idx)
	
	highlightNode.visible = true
	highlightNode.global_position = highlightPosition

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tileMap = player_character.fieldMap;
	if tileMap == null:
		highlightNode.visible = false
		return
	
	if !is_valid_to_hoe(tileMap):
		highlightNode.visible = false
		return
		
	highlight(tileMap)
	
	if Input.is_action_just_pressed("interact"):
		hoe(tileMap)
