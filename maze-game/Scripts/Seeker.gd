extends CharacterBody2D
class_name Monster


const SPEED = 400.0
#const SPRINT_SPEED = 600
var last_direction := Vector2(1,0)


func _physics_process(delta: float) -> void:

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	
	move_and_slide()
	#normalize the vector to account for diagonal movement later maybe?
	if direction.length() > 0:
		last_direction = direction
		#play_walk_animation(direction)
		play_idle_animation(direction)
		#print("Debug Direction: ", direction)
	else:
		play_idle_animation(last_direction)
		#print("Debug Direction: ", direction)

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
	elif direction.x < 0:
		$AnimatedSprite2D.play("idle_left")
	elif direction.y > 0:
		$AnimatedSprite2D.play("idle_down")
	elif direction.y < 0:
		$AnimatedSprite2D.play("idle_up")
