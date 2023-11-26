@tool
extends RayCast2D
class_name Limb

@export var extended: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var endpoint: Marker2D = $EndPoint
@onready var startpoint: Marker2D = $StartPoint

# Called when the node enters the scene tree for the first time.
func _ready():
	if extended:
		extend()
	else:
		collapse()


func extend() -> void:
	animation_player.play("extend")


func collapse() -> void:
	animation_player.play("collapse")


func set_extended() -> void:
	extended = true


func set_collapsed() -> void:
	extended = false

