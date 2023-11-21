extends Node2D

@onready var camera: = $Camera2D
@onready var player: = $PlayerNew

# Called when the node enters the scene tree for the first time.
func _ready():
	player.remote_transform.remote_path = camera.get_path()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
