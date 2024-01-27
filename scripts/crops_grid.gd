class_name CropsGrid extends Node

@export var NumCols : int = 16
@export var NumRows : int = 16

@export var WidthPixels : int = 16
@export var HeightPixels : int = 16

@onready var MushroomPrefab1 = preload("res://prefabs/mushroom_sprite.tscn") as PackedScene

var rng = RandomNumberGenerator.new()

var growth_timer = 0.0

var plant_data = []

func get_plant_at_grid_coord(row: int, col: int):
	return plant_data[row][col]

func plant_mushroom_at_grid_coord(row: int, col: int):
	plant_data[row][col].visible = true

func get_plant_at_position(vec: Vector2):
	var gx = (((int)(vec.x)) / WidthPixels)
	var gy = (((int)(vec.y)) / HeightPixels)
	
	print("grid_pos: " + str(gx) + ", " + str(gy))
	
	if gx >= 0 && gy >= 0 && gx < NumCols && gy < NumRows:
		return plant_data[gy][gx]
		
	return null

func _ready():
	
	for row in range(NumCols):
		plant_data.append([])
		
		for col in range(NumRows):
			var newobj = MushroomPrefab1.instantiate() as Plant
			add_child(newobj)
			
			newobj.set_growth_state(0)
			newobj.position = Vector2(WidthPixels * col, HeightPixels * row)
			plant_data[row].append(newobj)


func _process(delta):
	
	growth_timer += delta
	
	if growth_timer > 0.1:
		growth_timer = 0.0
		var plant = get_plant_at_grid_coord(rng.randi_range(0, NumRows-1), rng.randi_range(0, NumCols-1)) as Plant
		
		plant.inc_growth_state()
	
