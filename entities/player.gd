extends RigidBody2D
class_name Player

@export var limb_length: Vector2 = Vector2(150, 150)

@onready var right_leg: Limb = $RightLeg
@onready var left_leg: Limb = $LeftLeg
@onready var right_arm: Limb = $RightArm
@onready var left_arm: Limb = $LeftArm

@onready var left_foot: Endpoint = $LeftFoot
@onready var right_foot: Endpoint = $RightFoot
@onready var left_hand: Endpoint = $LeftHand
@onready var right_hand: Endpoint = $RightHand

@onready var remote_transform: RemoteTransform2D = $RemoteTransform2D

var left_extended: = false
var left_transitioning: = false
var right_extended: = false
var right_transitioning: = false

var start_position: Vector2
var limb_extent: Vector2

var grabbing: bool = false
var grabbing_with = null

signal grab(part, grab_point)

func _ready():
	start_position = $Body.shape.size / 2
	limb_extent = start_position + limb_length
	collapse_left()
	collapse_right()
	

func _physics_process(delta):
	var impulse = null
	
	if Input.is_action_pressed("left_side") and not left_extended and not left_transitioning:
		if left_leg.is_colliding():
			var collide_length: float = get_impulse_power(left_leg)
			impulse = Vector2(2, -3).normalized() * Global.jump_impulse * collide_length
			print("Pushing left off with: ", collide_length, linear_velocity)
		else:
			print("No push from left", left_leg)
		extend_left()
	elif not Input.is_action_pressed("left_side") and left_extended and not left_transitioning:
		collapse_left()
	
	if Input.is_action_pressed("right_side") and not right_extended and not right_transitioning:
		if right_leg.is_colliding():
			var collide_length: float = get_impulse_power(right_leg)
			print("Pushing right off with: ", collide_length, linear_velocity)
			if impulse == null:
				impulse = Vector2(0, 0)
			impulse += Vector2(-2, -3).normalized() * Global.jump_impulse * collide_length
		extend_right()
	elif not Input.is_action_pressed("right_side") and right_extended and not right_transitioning:
		collapse_right()
	
	if impulse != null:
		apply_central_impulse(-linear_velocity)
		print("Impulse! ", impulse, impulse.length())
		apply_central_impulse(impulse.limit_length(Global.jump_impulse))
	
	if left_extended and (left_hand.global_position - left_arm.endpoint.global_position).length() < 6:
		left_hand.extended = true
	else:
		left_hand.extended = false

	if right_extended and (right_hand.global_position - right_arm.endpoint.global_position).length() < 6:
		right_hand.extended = true
	else:
		right_hand.extended = false
	
	if Input.is_action_just_pressed("ui_up"):
		Global.jump_impulse += 20
		print("New jump impulse: ", Global.jump_impulse)
	if Input.is_action_just_pressed("ui_down"):
		Global.jump_impulse -= 20
		print("New jump impulse: ", Global.jump_impulse)


func get_impulse_power(leg: RayCast2D) -> float:
	var main_length: = leg.target_position.length()
	return (main_length - (leg.global_position - leg.get_collision_point()).length()) / leg.target_position.length()


const extend_speed: float = 0.2
func tween_limbs(foot: CollisionShape2D, hand: CollisionShape2D, leg: Limb, arm: Limb, end: bool) -> Tween:
	var tween = get_tree().create_tween()#.set_trans(Tween.TRANS_QUAD)
	tween.set_parallel(true)
	tween.tween_property(foot, "position", (leg.endpoint.global_position if end else leg.startpoint.global_position) - global_position, extend_speed)
	tween.tween_property(hand, "position", (arm.endpoint.global_position if end else arm.startpoint.global_position) - global_position, extend_speed)
	return tween


func extend_left():
	left_transitioning = true
	left_arm.extend()
	left_leg.extend()
	await tween_limbs(left_foot, left_hand, left_leg, left_arm, true).finished
	left_extended = true
	left_transitioning = false


func extend_right():
	right_transitioning = true
	right_arm.extend()
	right_leg.extend()
	await tween_limbs(right_foot, right_hand, right_leg, right_arm, true).finished
	right_extended = true
	right_transitioning = false


func collapse_left():
	left_transitioning = true
	left_foot.extended = false
	left_hand.extended = false
	left_arm.collapse()
	left_leg.collapse()
	if grabbing and grabbing_with == left_hand:
		grabbing_with.grabbing = false
		grabbing = false
		freeze = false
		apply_central_impulse(Vector2(-2, -3).normalized() * Global.jump_impulse)
	await tween_limbs(left_foot, left_hand, left_leg, left_arm, false).finished
	left_extended = false
	left_transitioning = false


func collapse_right():
	right_transitioning = true
	right_foot.extended = false
	right_hand.extended = false
	right_arm.collapse()
	right_leg.collapse()
	if grabbing and grabbing_with == right_hand:
		grabbing_with.grabbing = false
		grabbing = false
		freeze = false
		apply_central_impulse(Vector2(2, -3).normalized() * Global.jump_impulse)
	queue_redraw()
	await tween_limbs(right_foot, right_hand, right_leg, right_arm, false).finished
	right_extended = false
	right_transitioning = false


func _on_grab(part: Endpoint, grab_point: GrabPoint):
	print("You grabbed me! ", part, grab_point, part.extended)
	set_deferred("freeze", true)
	apply_central_impulse(-linear_velocity)
	grabbing_with = part
	grabbing = true
	part.grabbing = true
