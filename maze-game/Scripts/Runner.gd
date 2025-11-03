extends CharacterBody2D
class_name Runner

const SPEED = 300.0
const SPRINT_SPEED = 500
var last_direction := Vector2(1,0)

@export var footprint_scene: PackedScene
@export var distance_between_footprints := 64.0
@export var footprint_lifetime := 30.0
var last_footprint_pos: Vector2


@export var max_sprint_time := 8.0 #time allowed to sprint
@export var sprint_recharge_rate := 10.0 #Recharge rate until can sprint again
@export var Health := 12.0
var current_health := Health
var current_sprint_time := max_sprint_time
var is_sprinting = false
var can_sprint := true
var sprint_cooldown_timer := 0.0

@onready var chase_music = $Sounds/MonsterRadius
var ambient_music: AudioStreamPlayer2D
var ambient_pos := 0.0  # store playback position



func _ready() -> void:
	last_footprint_pos = global_position



func fade_out_outofsprint_sound():
	if $Sounds/OutofSprint.playing:
		var tween = create_tween()
		tween.tween_property($Sounds/OutofSprint, "volume_db", -40, 3.0) # fade to -40 dB over 1.5s
		tween.tween_callback(Callable($Sounds/OutofSprint, "stop"))


func _physics_process(delta: float) -> void:
	
	#give runner w,a,s,d
	var direction = Input.get_vector("human_left", "human_right", "human_up", "human_down")
	
	
# --- Sprint handling ---
# If sprint is currently active
	if is_sprinting:
		velocity = direction * SPRINT_SPEED
		current_sprint_time = max(current_sprint_time - delta, 0.0)
		$StaminaBar.value = current_sprint_time
		#print("DEBUG: Runner is sprinting. Stamina: ", current_sprint_time)

		# If sprint ran out, end it and start cooldown
		if current_sprint_time <= 0.0:
			is_sprinting = false
			can_sprint = false
			sprint_cooldown_timer = sprint_recharge_rate
			if not $Sounds/OutofSprint.playing:
				$Sounds/OutofSprint.pitch_scale = randf_range(0.95, 1.05)
				$Sounds/OutofSprint.volume_db = 0
				$Sounds/OutofSprint.play()
			#print("DEBUG: Sprint ended. Starting cooldown...")

# If sprint is not active and the player tries to start sprinting
	elif can_sprint and Input.is_action_just_pressed("human_run") and direction != Vector2.ZERO:
		is_sprinting = true
		current_sprint_time = max_sprint_time  # reset to full sprint time on start
		$Sounds/Running.pitch_scale = randf_range(0.95, 1.05)
		$Sounds/Running.play()
		velocity = direction * SPRINT_SPEED
		$StaminaBar.value = current_sprint_time
		#print("DEBUG: Sprint start")

	# If sprint is not active but in cooldown
	elif not can_sprint:
		velocity = direction * SPEED
		if sprint_cooldown_timer > 0.0:
			sprint_cooldown_timer = max(sprint_cooldown_timer - delta, 0.0)
			#print("DEBUG: Sprint unavailable. Cooldown remaining: ", sprint_cooldown_timer)
		else:
			can_sprint = true
			current_sprint_time = max_sprint_time
			$StaminaBar.value = current_sprint_time
			if $Sounds/OutofSprint.playing:
				fade_out_outofsprint_sound()
			#print("DEBUG: Sprint recharged.")

	# If no sprinting and no cooldown
	else:
		velocity = direction * SPEED
		if direction != Vector2.ZERO:
			if not $Sounds/Walking.playing:
				$Sounds/Walking.pitch_scale = randf_range(0.95, 1.05)
				$Sounds/Walking.play()
				#print("DEBUG: Not sprinting")
		else:
			if $Sounds/Walking.playing:
				$Sounds/Walking.stop()

	
	
	move_and_slide()
	#normalize the vector to account for diagonal movement later maybe?
	
	# --- Animation ---
	if direction.length() > 0:
		last_direction = direction
		play_walk_animation(direction)
		#print("Debug Direction: ", direction)
	else:
		play_idle_animation(last_direction)
		#print("Debug Direction: ", direction)
	
	# --- Footprints ---
	if direction.length() > 0:
		var dist = global_position.distance_to(last_footprint_pos)
		if dist >= distance_between_footprints:
			spawn_footprint()
			last_footprint_pos = global_position
			


func play_walk_animation(direction):
	if direction.x > 0:
		$AnimatedSprite2D.play("walk_right")
	elif direction.x < 0:
		$AnimatedSprite2D.play("walk_left")
	elif direction.y > 0:
		$AnimatedSprite2D.play("walk_down")
	elif direction.y < 0:
		$AnimatedSprite2D.play("walk_up")

func play_idle_animation(direction):
	if direction.x > 0:
		$AnimatedSprite2D.play("idle_right")
	elif direction.x > 0:
		$AnimatedSprite2D.play("idle_left")
	elif direction.y > 0:
		$AnimatedSprite2D.play("idle_down")
	elif direction.y < 0:
		$AnimatedSprite2D.play("idle_up")


func spawn_footprint():
	
	var fp = footprint_scene.instantiate() as Footsteps
	get_parent().add_child(fp)
	fp.global_position = global_position
	fp.rotation = last_direction.angle() + deg_to_rad(90)
	fp.time_to_live = footprint_lifetime

func take_damage(amount: float) -> void:
	current_health -= amount
	$HealthBar.value = current_health
	print("Runner took ", amount, " damage! HP: ", current_health)
	if current_health <= 0:
		die()
	else:
		$Sounds/TakeDmg.play()

func die():
	print("Runner died!")
	#death sound
	$MonsterDetectRadius/CollisionShape2D.disabled = true
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0,-15), 0.5) # go up
	tween.tween_property(self, "modulate:a", 0.0, 0.5) #fade out
	$Sounds/Death.play()
	await get_tree().create_timer(3.3).timeout
	$MonsterDetectRadius/CollisionShape2D.queue_free()
	tween.tween_callback(self.queue_free)
	# do death screen/ death music before resetting scene to main menu


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
