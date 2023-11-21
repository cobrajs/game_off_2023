extends RigidBody2D
class_name Leg

@onready var foot: RigidBody2D = $Foot

@export var thrust = Vector2(0, 250)

func extend() -> void:
	foot.apply_central_force(thrust * 1000)

func retract() -> void:
	foot.apply_central_force(-thrust * 100)
