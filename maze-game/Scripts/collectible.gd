extends Area2D
class_name Items

@onready var anim = $AnimatedSprite2D
@onready var pickUp = $PickUp
static var itemsCollected = 0;
var picked_up := false
signal collected(item)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("idle")


func _on_body_entered(body: Node2D) -> void:
	if picked_up:
		return
		
	if body.name == "Runner":
		picked_up = true
		print("DEBUG: Runner collided with me.")
		
		emit_signal("collected", self)
		
		var tween = create_tween()
		tween.tween_property(self, "position", position + Vector2(0,-30), 0.5) # go up
		
		tween.tween_property(self, "modulate:a", 0.0, 0.5) #fade out
		#itemsCollected += 1 # Add 1 to itemCount
		pickUp.play()
		
		tween.tween_callback(self.queue_free)
		
