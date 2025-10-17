extends CharacterBody2D
class_name Runner

const SPEED = 300.0
const SPRINT_SPEED = 500
var last_direction := Vector2(1,0)

@export var footprint_scene: PackedScene
@export var distance_between_footprints := 64.0
@export var footprint_lifetime := 30.0
var last_footprint_pos: Vector2

var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
var time_to_run := 5.0 #time allowed to sprint before needs to be recharged

func _ready() -> void:
	last_footprint_pos = global_position


func _physics_process(delta: float) -> void:

	velocity = direction * SPEED
	
	move_and_slide()
	#normalize the vector to account for diagonal movement later maybe?
	
	
	if direction.length() > 0:
		last_direction = direction
		play_walk_animation(direction)
		#print("Debug Direction: ", direction)
	else:
		play_idle_animation(last_direction)
		#print("Debug Direction: ", direction)
		
	if direction.length() > 0:
		var dist = global_position.distance_to(last_footprint_pos)
		if dist >= distance_between_footprints:
			spawn_footprint()
			last_footprint_pos = global_position
	
	if Input.is_action_just_pressed("Run"):
		sprint()
		

func play_walk_animation(direction):
	if direction.x > 0:
		$AnimatedSprite2D.play("walk_right")
	elif direction.x > 0:
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

func sprint():
	pass
	#velocity = direction * SPRINT_SPEED
	#for ():
		#
