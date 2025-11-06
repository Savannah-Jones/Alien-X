extends Area2D
class_name EscapeArea

signal player_escaped(winner: String)

func _ready():
	$CollisionShape2D.disabled = false #should be true
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
		print("DEBUG: body_entered signal connected.")

func enable_area():
	$CollisionShape2D.disabled = false
	print("DEBUG: Escape area is now enabled.")

func _on_body_entered(body: Node2D) -> void: #connected via node
	print("DEBUG: Something entered escape area -> ", body.name)
	print("DEBUG: EscapeArea emitting from:" , self, "id:", self.get_instance_id())
	if body.is_in_group("Runner"):
		print("DEBUG: PLAYER ENTERED ESCAPE AREA.")
		emit_signal("player_escaped", "Human")
