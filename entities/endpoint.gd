@tool
extends CollisionShape2D
class_name Endpoint

@export var type: String = "hand"
@export var extended: bool = false : set = set_extended
@export var grabbing: bool = false : set = set_grabbing
@export var side: String = "left"

@onready var sprite: Sprite2D = $Sprite2D

const HAND = "hand"
const FOOT = "foot"

const OPEN_HAND_REGION = Rect2(1, 10, 62, 74)
const CLOSED_HAND_REGION = Rect2(0, 94, 63, 49)
const FOOT_REGION = Rect2(83, 8, 63, 62)
const FOOT_OFFSET = Vector2(8, 0)

func _ready():
	if type == HAND:
		set_hand()
	elif type == FOOT:
		set_foot()
	
	if side == "left":
		sprite.scale.x = -1


func set_hand() -> void:
	sprite.region_rect = OPEN_HAND_REGION
	sprite.offset = Vector2.ZERO


func set_foot() -> void:
	sprite.region_rect = FOOT_REGION
	sprite.offset = FOOT_OFFSET

func set_grabbing(new_grabbing: bool) -> void:
	grabbing = new_grabbing
	if type == HAND:
		if grabbing:
			sprite.region_rect = CLOSED_HAND_REGION
		else:
			sprite.region_rect = OPEN_HAND_REGION
	elif type == FOOT:
		sprite.region_rect = FOOT_REGION


func set_extended(new_extended: bool) -> void:
	extended = new_extended
	if extended:
		sprite.modulate.a = 0.5
	else:
		sprite.modulate.a = 1
