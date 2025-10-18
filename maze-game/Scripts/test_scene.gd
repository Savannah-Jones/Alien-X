extends Node2D

@onready var objectiveBar = $UI/ProgressBar
@onready var ambient_music := $AmbientMusic
@onready var runner := $TestRunner #make it $Runner later when actual runner is brought in
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass
	ambient_music.play()
	runner.ambient_music = ambient_music


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	objectiveBar.value = Items.itemsCollected
