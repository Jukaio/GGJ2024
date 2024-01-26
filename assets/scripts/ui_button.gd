class_name UIButton extends Control

signal clicked

@export var ButtonName : String = "notset"

@onready var UpImage = $UpImage
@onready var DownImage = $DownImage

var _selected : bool = false

func select(selected):
	_selected = selected

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if _selected && Input.is_action_just_pressed("ui_accept"):
		emit_signal("clicked", ButtonName)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
