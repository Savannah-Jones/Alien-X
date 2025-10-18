#test_runner
#has no movement. Can be spawned with monster in scene without issue
extends CharacterBody2D


@export var Health := 12.0
var current_health := Health
var ambient_pos := 0.0  # store playback position
@onready var chase_music = $MonsterRadius
var ambient_music: AudioStreamPlayer2D

func _ready():
	add_to_group("Runner")
	print("DEBUG: test runner added to runner group.")

func take_damage(amount: float) -> void:
	current_health -= amount
	$HealthBar.value = current_health
	if current_health <= 0:
		$MonsterDetectRadius/CollisionShape2D.disabled = true
		var tween = create_tween()
		tween.tween_property(self, "position", position + Vector2(0,-15), 0.5) # go up
		tween.tween_property(self, "modulate:a", 0.0, 0.5) #fade out
		$Death.play()
		await get_tree().create_timer(3.3).timeout
		$MonsterDetectRadius/CollisionShape2D.queue_free()
		tween.tween_callback(self.queue_free)
	$TakeDmg.play()
	print("Runner took ", amount, " damage! HP: ", current_health)


func _on_monster_detect_radius_body_entered(body: Node2D) -> void:
	if body.is_in_group("Monster"):
		print("Monster entered proximity radius!")
		
		if ambient_music:
			ambient_pos = ambient_music.get_playback_position()
			ambient_music.stop()
		
		if not chase_music.playing:
			chase_music.volume_db = -40  # start silent, then fade in
			chase_music.pitch_scale = randf_range(0.95, 1.05)
			chase_music.play()
			var tween = create_tween()
			tween.tween_property(chase_music, "volume_db", 0, 1.2)  # fade in over 1.5s


func _on_monster_detect_radius_body_exited(body: Node2D) -> void:
	if body.is_in_group("Monster"):
		print("Monster left proximity radius!")
		
		var tween = create_tween()
		# Fade volume down
		tween.tween_property(chase_music, "volume_db", -40, 1.0)  # fade out over 1.5s
		tween.tween_callback(Callable(chase_music, "stop"))  # stops after fade completes
		tween.tween_callback(Callable(self, "_resume_ambient_music"))

func _resume_ambient_music():
	ambient_music.play(ambient_pos)  # resume from stored position
