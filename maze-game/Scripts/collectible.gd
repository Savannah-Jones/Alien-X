extends Area2D
class_name Items

@onready var anim = $AnimatedSprite2D
var itemsCollected = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("idle")


func _on_body_entered(body: Node2D) -> void:
	# do something
	if body.name == "Runner":
		print("DEBUG: Runner collided with me.")
		var tween = create_tween()
		tween.tween_property(self, "position", position + Vector2(0,-30), 0.5) # go up
		
		tween.tween_property(self, "modulate:a", 0.0, 0.5) #fade out
		itemsCollected += 1 # Add 1 to itemCount
		
		tween.tween_callback(self.queue_free)
		
