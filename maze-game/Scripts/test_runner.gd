#test_runner
#has no movement. Can be spawned with monster in scene without issue
extends CharacterBody2D


@export var Health := 12.0
var current_health := Health

func _ready():
	add_to_group("Runner")
	print("DEBUG: test runner added to runner group.")

func take_damage(amount: float) -> void:
	current_health -= amount
	$HealthBar.value = current_health
	if current_health <= 0:
		var tween = create_tween()
		tween.tween_property(self, "position", position + Vector2(0,-15), 0.5) # go up
		tween.tween_property(self, "modulate:a", 0.0, 0.5) #fade out
		$Death.play()
		await get_tree().create_timer(3.3).timeout
		tween.tween_callback(self.queue_free)
	$TakeDmg.play()
	print("Runner took ", amount, " damage! HP: ", current_health)


func _on_monster_detect_radius_body_entered(body: Node2D) -> void:
	if body.is_in_group("Monster"):
		print("Monster entered proximity radius!")
		$MonsterRadius.play()


func _on_monster_detect_radius_body_exited(body: Node2D) -> void:
	if body.is_in_group("Monster"):
		print("Monster left proximity radius!")
		$MonsterRadius.stop()
