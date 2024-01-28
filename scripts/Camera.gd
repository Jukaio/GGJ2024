class_name FarmCamera

extends Camera2D

@export var decay: float = 30.0

var rng = RandomNumberGenerator.new()

var shake_strength:float = 0.0

func apply_shake(strength: float):
	shake_strength = strength
	
# TODO: Add in some sort of rotation reset.
func _process(delta):  
	if shake_strength > 0.1:
		shake_strength = lerpf(shake_strength, 0, decay * delta)
		
		offset = random_offset()
	else:
		offset = Vector2.ZERO

func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength),rng.randf_range(-shake_strength, shake_strength))
