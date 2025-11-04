extends Node

@onready var objectiveBar = $HBoxContainer/SubViewportContainer/SubViewport/Objectives/ProgressBar
@onready var ambient_music := $AmbientMusic
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

var game_over := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	#viewports
	var main_view_size = get_viewport().size  # e.g. (1920,1080)
	var half_width = int(main_view_size.x / 2)
	players["1"].viewport.size = Vector2(half_width, main_view_size.y)
	players["2"].viewport.size = Vector2(half_width, main_view_size.y)
	players["2"].viewport.world_2d = players["1"].viewport.world_2d
	
	#debug
	for c in get_tree().get_nodes_in_group("Collectibles"):
		print("Collectible: ", c.name, " at ", c.global_position)
		var marker = ColorRect.new()
		marker.color = Color(1, 0, 0, 0.5)
		marker.size = Vector2(8, 8)
		add_child(marker)
		marker.global_position = c.global_position
	
	#cameras
	for node in players.values():
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)
	
	#music
	ambient_music.play()
	runner.ambient_music = ambient_music
	
	escape_area.get_node("CollisionShape2D").disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_over:
		return
	
	objectiveBar.value = Items.itemsCollected
	if objectiveBar.value == 9:
		$HBoxContainer/SubViewportContainer/SubViewport/Objectives/Collect.visible = false
		$HBoxContainer/SubViewportContainer/SubViewport/Objectives/Escape.visible = true
		escape()
	

	
	if runner.current_health <= 0:
		winCondition("Alien")
		

func escape() -> void:
	escape_area.enable_area()
	if not escape_area.is_connected("player_escaped", Callable(self, "_on_player_escaped")):
		escape_area.player_escaped.connect(Callable(self, "_on_player_escaped"))

func _on_player_escaped(winner: String) -> void:
	winCondition(winner)

func winCondition(winner: String) -> void:
	game_over = true
	print("Game over.")
	swapScenes(winner)

func swapScenes(winner: String) -> void:
	match winner:
		"Alien":
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn") #main menu scene for now
		"Human":
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
