extends Node


func _ready():
	pass # Replace with function body.


func _process(delta):
	
	if Input.is_action_just_pressed("Start"):
		get_tree().change_scene_to_file("res://scenes/entry_point.tscn")
		
func _unhandled_key_input(event):
	# fallback to make sure we can proceed on any input
	if event.is_pressed():
		get_tree().change_scene_to_file("res://scenes/entry_point.tscn")
