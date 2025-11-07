extends Node

func _on_ready() -> void:
	#add audio here (2secs long)
	$AudioStreamPlayer.play()
	$Animations/AnimationPlayer.play("monster_victory")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "monster_victory":
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
