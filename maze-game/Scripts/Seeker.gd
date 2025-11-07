extends CharacterBody2D
class_name Monster


const SPEED = 262.0
var last_direction := Vector2(1,0)
@onready var anim = $Animations
@onready var slash_effect = $Slash
@onready var slash_particles = $SlashParticles
@onready var slash_hitbox = $SlashHitbox
@onready var slash_sounds = $SlashSounds #might need to change since #SlashSounds is now just a node holding audiostreamplayers
var _slash_hit_happened := false
@export var attack_damage := 3.0


func _ready():
	#slash_hitbox.connect("area_entered", Callable(self, "_on_slash_area_entered"))
	slash_hitbox.connect("body_entered", Callable(self, "_on_slash_body_entered"))


func _on_slash_body_entered(body: Node2D) -> void:
	if body.is_in_group("Runner"):
		print("Slash hit runner!")
		if body.has_method("take_damage"):
			body.call("take_damage", attack_damage)
		play_random_hit_sound()
		_slash_hit_happened = true
	else:
		play_miss_sound()

func _physics_process(delta: float) -> void:

	#give monster arrow keys
	var direction = Input.get_vector("monster_left", "monster_right", "monster_up", "monster_down")
	velocity = direction * SPEED
	
	move_and_slide()
	#normalize the vector to account for diagonal movement later maybe?
	if direction.length() > 0:
		direction = direction.normalized() #<---if something breaks later, remove
		last_direction = direction
		play_idle_animation(direction)
		#print("Debug Direction: ", direction)
	else:
		play_idle_animation(last_direction)
		#print("Debug Direction: ", direction)
		
	if Input.is_action_just_pressed("monster_attack"):
		attack()

func play_walk_animation(direction):
	if direction.x > 0:
		anim.play("walk_right")
	elif direction.x < 0:
		anim.play("walk_left")
	elif direction.y > 0:
		anim.play("walk_down")
	elif direction.y < 0:
		anim.play("walk_up")

func play_idle_animation(direction):
	if direction.x > 0:
		anim.play("idle_right")
	elif direction.x < 0:
		anim.play("idle_left")
	elif direction.y > 0:
		anim.play("idle_down")
	elif direction.y < 0:
		anim.play("idle_up")


func attack():
	#add attack delay later.

	slash_effect.visible = true
	slash_effect.play("slash")

	# --- Calculate angle from last_direction ---
	var angle_deg = rad_to_deg(last_direction.angle())  # Converts from radians to degrees
	slash_effect.rotation_degrees = angle_deg - 90  
	# Optional: adjust so 0° is to the right

	# Godot’s Vector2.angle() gives angle relative to x-axis pointing right, counter-clockwise
	slash_effect.rotation_degrees = angle_deg
	slash_hitbox.rotation_degrees = angle_deg

	# --- Adjust hitbox position dynamically ---
	var offset_distance = 37  # How far in front of player the slash appears
	var offset = last_direction.normalized() * offset_distance
	slash_hitbox.position = offset

	# --- Flip sprite for left-facing directions (optional) ---
	slash_effect.flip_v = last_direction.x < 0
	
	
	$SlashHitbox/CollisionShape2D.disabled = false
	slash_particles.restart()
	slash_particles.emitting = true

	
#
func _on_slash_done():
	slash_effect.visible = false
	$SlashHitbox/CollisionShape2D.disabled = true
	
	if not _slash_hit_happened:
		play_miss_sound()  # nothing was hit during this slash

	_slash_hit_happened = false  # reset for next attack

# Pick a random hit sound and play it
func play_random_hit_sound() -> void:
	var hit_nodes = []
	for child in slash_sounds.get_children():
		if child.name.begins_with("Hit") and child is AudioStreamPlayer2D:
			hit_nodes.append(child)
	if hit_nodes.size() == 0:
		return
	var node = hit_nodes[randi() % hit_nodes.size()]
	node.play()

# Play the miss sound
func play_miss_sound() -> void:
	var miss_nodes = []
	for child in slash_sounds.get_children():
		if child.name.begins_with("Miss") and child is AudioStreamPlayer2D:
			miss_nodes.append(child)
	if miss_nodes.size() == 0:
		return
	var node = miss_nodes[randi() % miss_nodes.size()]
	node.play()
