extends Node2D
class_name Footsteps

@onready var sprite = $Sprite2D

var time_to_live := 30.0 # seconds
var time_alive := 0.0

func _process(delta: float) -> void:
	time_alive += delta
	
	# Calculate alpha fade (1.0 -> 0.0 over time_to_live)
	var alpha := 1.0 - (time_alive / time_to_live)
	alpha = clamp(alpha, 0.0, 1.0)
	
	# Apply fade to sprite
	var modulate_color = sprite.modulate
	modulate_color.a = alpha
	sprite.modulate = modulate_color
	
	# Free after lifetime
	if time_alive >= time_to_live:
		queue_free()
