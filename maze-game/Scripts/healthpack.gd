extends Area2D
class_name HealthPack


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Runner":
		print("DEBUG: Runner restored health.")
		$"../Runner".current_health = 12.0
		queue_free()
