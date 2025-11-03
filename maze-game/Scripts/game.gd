extends Node

@onready var objectiveBar = $HBoxContainer/ColorRect/UI/ProgressBar
@onready var players := {
	"1": {
		viewport = $HBoxContainer/SubViewportContainer/SubViewport,
		camera = $HBoxContainer/SubViewportContainer/SubViewport/Camera2D,
		player = $HBoxContainer/SubViewportContainer/SubViewport/Level/Runner
	},
	"2": {
		viewport = $HBoxContainer/SubViewportContainer2/SubViewport,
		camera = $HBoxContainer/SubViewportContainer2/SubViewport/Camera2D,
		player = $HBoxContainer/SubViewportContainer/SubViewport/Level/SeekerPlayer
	}
}
@onready var ambient_music := $AmbientMusic
@onready var runner := $HBoxContainer/SubViewportContainer/SubViewport/Level/Runner
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	var main_view_size = get_viewport().size  # e.g. (1920,1080)
	var half_width = int(main_view_size.x / 2)
	
	players["1"].viewport.size = Vector2(half_width, main_view_size.y)
	players["2"].viewport.size = Vector2(half_width, main_view_size.y)
	
	players["2"].viewport.world_2d = players["1"].viewport.world_2d
	
	
	for c in get_tree().get_nodes_in_group("Collectibles"):
		print("Collectible:", c.name, "at", c.global_position)
		var marker = ColorRect.new()
		marker.color = Color(1, 0, 0, 0.5)
		marker.size = Vector2(8, 8)
		add_child(marker)
		marker.global_position = c.global_position
	
	for node in players.values():
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)
	ambient_music.play()
	runner.ambient_music = ambient_music

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	objectiveBar.value = Items.itemsCollected
