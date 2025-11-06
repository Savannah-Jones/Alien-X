extends Node

@onready var objectiveBar = $HBoxContainer/SubViewportContainer/SubViewport/Objectives/ProgressBar
@onready var ambient_music := $AmbientMusic
var ambient_pos := 0.0
@onready var chase_music := $MonsterRadius
@onready var runner := $HBoxContainer/SubViewportContainer/SubViewport/Level/Runner
@onready var monster := $HBoxContainer/SubViewportContainer/SubViewport/Level/SeekerPlayer
@onready var escape_area = $HBoxContainer/SubViewportContainer/SubViewport/Level/EscapeArea
@onready var players := {
	"1": {
		viewport = $HBoxContainer/SubViewportContainer/SubViewport,
		camera = $HBoxContainer/SubViewportContainer/SubViewport/Camera2D,
		player = runner
	},
	"2": {
		viewport = $HBoxContainer/SubViewportContainer2/SubViewport,
		camera = $HBoxContainer/SubViewportContainer2/SubViewport/Camera2D,
		player = monster
	}
}
#@onready var escape_area: EscapeArea = players["1"].player.get_parent().get_node("EscapeArea")
var game_over := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	#debug
	for r in get_tree().get_nodes_in_group("Runner"):
		print("DEBUG: Runner found: ", r, " in ", r.get_parent().name)

		
	runner.monster_detected.connect(_on_monster_detected)
	runner.monster_lost.connect(_on_monster_lost)
	runner.collected_item.connect(_on_runner_collected)
	
	
	for area in get_tree().get_nodes_in_group("EscapeArea"):
		if not area.is_connected("player_escaped", Callable(self, "_on_player_escaped")):
			area.player_escaped.connect(Callable(self, "_on_player_escaped"))
			print("DEBUG: Connected escape_area signal from:", area.name)


	
	
	#viewports
	var main_view_size = get_viewport().size  # e.g. (1920,1080)
	var half_width = int(main_view_size.x / 2)
	players["1"].viewport.size = Vector2(half_width, main_view_size.y)
	players["2"].viewport.size = Vector2(half_width, main_view_size.y)
	players["2"].viewport.world_2d = players["1"].viewport.world_2d
	
	
	#cameras
	for node in players.values():
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)
	
	#music
	ambient_music.play()
	
	escape_area.get_node("CollisionShape2D").disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_over:
		return
	
	if runner.current_health <= 0:
		winCondition("Alien")
		

func _on_runner_collected(item):
	Items.itemsCollected += 1
	print("Collected! Total: ", Items.itemsCollected)
	objectiveBar.value = Items.itemsCollected
	if objectiveBar.value == 2: #value = 2 for testing. change back to 18 after testing.
		$HBoxContainer/SubViewportContainer/SubViewport/Objectives/Collect.visible = false
		$HBoxContainer/SubViewportContainer/SubViewport/Objectives/Escape.visible = true
		escape_area.enable_area()


func _on_player_escaped(winner: String) -> void:
	if game_over:
		print("DEBUG: Game already over, ignoring duplicate escape signal.")
		return
	print("Human wins.")
	winCondition(winner)

func winCondition(winner: String) -> void:
	game_over = true
	print("Game over.")
	swapScenes(winner)

func swapScenes(winner: String) -> void:
	print(">>> swapScenes called. Winner: ", winner)
	
	match winner:
		"Alien":
			print(">>> Changing to AlienWIn screen for Alien")
			call_deferred("change_scene_deferred", "res://Scenes/AlienWin.tscn")
		"Human":
			print(">>> Changing to HumanWin screen for Human")
			call_deferred("change_scene_deferred", "res://Scenes/HumanWin.tscn")

func change_scene_deferred(path: String) -> void:
	# Reset static / global variables
	Items.itemsCollected = 0
	
	for area in get_tree().get_nodes_in_group("EscapeArea"):
		area.enabled = false
		area.get_node("CollisionShape2D").disabled = true

	# Now change the scene
	get_tree().change_scene_to_file(path)



func _on_monster_detected():
	print("DEBUG: Monster entered proximity radius!")
	if ambient_music and ambient_music.playing:
		ambient_pos = ambient_music.get_playback_position()
		ambient_music.stop()
	
	if not chase_music.playing:
		chase_music.volume_db = -40
		chase_music.pitch_scale = randf_range(0.95, 1.05)
		chase_music.play()
		var tween = create_tween()
		tween.tween_property(chase_music, "volume_db", 0, 1.2)  # fade in

func _on_monster_lost():
	print("DEBUG: Monster left proximity radius!")
	if chase_music.playing:
		var tween = create_tween()
		tween.tween_property(chase_music, "volume_db", -40, 1.0)
		tween.tween_callback(Callable(chase_music, "stop"))
		tween.tween_callback(func(): _resume_ambient_music())

func _resume_ambient_music():
	if ambient_music:
		ambient_music.play(ambient_pos)
