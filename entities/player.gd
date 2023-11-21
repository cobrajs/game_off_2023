extends RigidBody2D

@onready var left_leg: Leg = $LeftLeg
@onready var right_leg: = $RightLeg

func _physics_process(delta):
	if Input.is_action_pressed("left_side"):
		left_leg.extend()
	else:
		left_leg.retract()

	if Input.is_action_pressed("right_side"):
		right_leg.extend()
	else:
		right_leg.retract()
