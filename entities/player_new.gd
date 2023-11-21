extends RigidBody2D

@export var limb_length: Vector2 = Vector2(50, 50)

@onready var left_leg_check: RayCast2D = $LeftLegCheck
@onready var right_leg_check: RayCast2D = $RightLegCheck
@onready var left_arm_check: RayCast2D = $LeftArmCheck
@onready var right_arm_check: RayCast2D = $RightArmCheck

@onready var left_foot: CollisionShape2D = $LeftFoot
@onready var right_foot: CollisionShape2D = $RightFoot
@onready var left_hand: CollisionShape2D = $LeftHand
@onready var right_hand: CollisionShape2D = $RightHand

@onready var remote_transform: RemoteTransform2D = $RemoteTransform2D

var left_extended: = false
var right_extended: = false

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
	remote_transform


func _draw():
	draw_rect(Rect2(-25, -30, 50, 60), Color.ANTIQUE_WHITE)
	var x = limb_extent.x
	var y = limb_extent.y
	if left_extended:
		draw_line(Vector2(0, 0), Vector2(-x, -y), Color.ANTIQUE_WHITE, 20)
		draw_line(Vector2(0, 0), Vector2(-x, y), Color.ANTIQUE_WHITE, 20)
		draw_circle(Vector2(-x, -y), 10, Color.ANTIQUE_WHITE)
		draw_circle(Vector2(-x, y), 10, Color.ANTIQUE_WHITE)
	if right_extended:
		draw_line(Vector2(0, 0), Vector2(x, -y), Color.ANTIQUE_WHITE, 20)
		draw_line(Vector2(0, 0), Vector2(x, y), Color.ANTIQUE_WHITE, 20)
		draw_circle(Vector2(x, -y), 10, Color.ANTIQUE_WHITE)
		draw_circle(Vector2(x, y), 10, Color.ANTIQUE_WHITE)
	

func _physics_process(delta):
	var impulse = null
	
	if Input.is_action_just_pressed("left_side"):
		if left_leg_check.is_colliding():
			var collide_length: float = get_impulse_power(left_leg_check)
			impulse = Vector2(2, -3).normalized() * Global.jump_impulse * collide_length
			print("Pushing left off with: ", collide_length, linear_velocity)
		extend_left()
	elif Input.is_action_just_released("left_side"):
		collapse_left()
	
	if Input.is_action_just_pressed("right_side"):
		if right_leg_check.is_colliding():
			var collide_length: float = get_impulse_power(right_leg_check)
			print("Pushing right off with: ", collide_length, linear_velocity)
			if impulse == null:
				impulse = Vector2(0, 0)
			impulse += Vector2(-2, -3).normalized() * Global.jump_impulse * collide_length
		extend_right()
	elif Input.is_action_just_released("right_side"):
		collapse_right()
	
	if impulse != null:
		apply_central_impulse(-linear_velocity)
		print("Impulse! ", impulse, impulse.length())
		apply_central_impulse(impulse.limit_length(Global.jump_impulse))
	
	
	if Input.is_action_just_pressed("ui_up"):
		Global.jump_impulse += 20
		print("New jump impulse: ", Global.jump_impulse)
	if Input.is_action_just_pressed("ui_down"):
		Global.jump_impulse -= 20
		print("New jump impulse: ", Global.jump_impulse)


func get_impulse_power(leg: RayCast2D) -> float:
	var main_length: = leg.target_position.length()
	return (main_length - (leg.global_position - leg.get_collision_point()).length()) / leg.target_position.length()


const extend_speed: float = 0.1
func tween_limbs(foot: CollisionShape2D, hand: CollisionShape2D, position: Vector2, x: int) -> Tween:
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
	tween.set_parallel(true)
	tween.tween_property(foot, "position", Vector2(position.x * x, position.y), extend_speed)
	tween.tween_property(hand, "position", Vector2(position.x * x, -position.y), extend_speed)
	return tween


func extend_left():
	left_extended = true
	left_foot.extended = true
	left_hand.extended = true
	queue_redraw()
	tween_limbs(left_foot, left_hand, limb_extent, -1)


func extend_right():
	right_extended = true
	right_foot.extended = true
	right_hand.extended = true
	queue_redraw()
	tween_limbs(right_foot, right_hand, limb_extent, 1)


func collapse_left():
	left_extended = false
	left_foot.extended = false
	left_hand.extended = false
	if grabbing and grabbing_with == left_hand:
		print("Release left hand!!")
		grabbing = false
		freeze = false
		apply_central_impulse(Vector2(-2, -3).normalized() * Global.jump_impulse)
	queue_redraw()
	tween_limbs(left_foot, left_hand, start_position, -1)


func collapse_right():
	right_extended = false
	right_foot.extended = false
	right_hand.extended = false
	if grabbing and grabbing_with == right_hand:
		print("Release right hand!!")
		grabbing = false
		freeze = false
		apply_central_impulse(Vector2(2, -3).normalized() * Global.jump_impulse)
	queue_redraw()
	tween_limbs(right_foot, right_hand, start_position, 1)



func _on_grab(part: Endpoint, grab_point: GrabPoint):
	var pin: PinJoint2D = PinJoint2D.new()
	pin.node_a = self.get_path()
	pin.node_b = grab_point.get_path()
	pin.position = grab_point.global_position + (part.global_position - grab_point.global_position) / 2
	get_parent().add_child(pin)
	print("You grabbed me! ", part, grab_point)
	freeze = true
	apply_central_impulse(-linear_velocity)
	grabbing_with = part
	grabbing = true
