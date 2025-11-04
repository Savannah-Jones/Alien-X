extends Area2D
class_name EscapeArea

signal player_escaped(winner: String)

func _ready():
	$CollisionShape2D.disabled = true
	# Connect the body_entered signal to this script's handler
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		body_entered.connect(Callable(self, "_on_body_entered"))

func enable_area():
	$CollisionShape2D.disabled = false
	# No need to connect player_escaped here; other scripts listen to this signal

func _on_body_entered(body: Node) -> void:
	if body == $"../Runner":
	#if body.is_in_group("Runner"):
		print("DEBUG: PLAYER ENTERED ESCAPE AREA.")
		emit_signal("player_escaped", "Human")
