extends Control

@onready var main_buttons: VBoxContainer = $Node/MainButtons
@onready var options: Panel = $AudioStreamPlayer/Options


func _ready():
	main_buttons.visible = true
	options.visible = false

func _on_start_pressed() -> void:
	#This is where you would put the main scene level for the game in the ("").
	$Starting_Sound.play()
	$Timer.start()
	await $Timer.timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_settings_pressed() -> void:
	main_buttons.visible = false
	options.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_options_pressed() -> void:
	_ready()
