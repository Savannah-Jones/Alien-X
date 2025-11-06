extends Node


func _ready() -> void:
	#add audio here (3secs long)
	$Ship/AnimationPlayer.play("Ship_Flying")
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Ship_Flying":
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
