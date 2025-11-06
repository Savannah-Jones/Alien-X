extends Area2D
class_name EscapeArea

signal player_escaped(winner: String)
var enabled := false

func _ready():
	$CollisionShape2D.disabled = false #should be true
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
			connect("body_entered", Callable(self, "_on_body_entered"))
			print("DEBUG: body_entered signal connected for ", self)

func enable_area():
	for area in get_tree().get_nodes_in_group("EscapeArea"):
		area.enabled = true
		area.get_node("CollisionShape2D").disabled = false
		print("DEBUG: Escape area is now enabled: ", area)


func _on_body_entered(body: Node2D) -> void: #connected via node
	if body.is_in_group("Runner") and enabled:
		print("DEBUG: PLAYER ENTERED ESCAPE AREA.")
		emit_signal("player_escaped", "Human")
	else:
		print("DEBUG: Something entered escape area -> ", body.name)
		print("DEBUG: EscapeArea emitting from:" , self, "id:", self.get_instance_id())
