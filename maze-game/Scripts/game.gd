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
	players["2"].viewport.world_2d = players["1"].viewport.world_2d
	
	for node in players.values():
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)
	ambient_music.play()
	runner.ambient_music = ambient_music

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	objectiveBar.value = Items.itemsCollected
