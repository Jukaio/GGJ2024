class_name HoeTool

extends Node2D

@export var hoeLength: float = 8.0

var playerCharacter: PlayerCharacter

# Called when the node enters the scene tree for the first time.
func _ready():
	playerCharacter = get_parent() as PlayerCharacter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tileMap = playerCharacter.fieldMap;
	if tileMap == null:
		return
	
	var targetPosition = playerCharacter.position + (playerCharacter.lookDirection * hoeLength)
	var idx = tileMap.local_to_map(targetPosition)
	tileMap.set_cell(0, idx)	
	
	pass
