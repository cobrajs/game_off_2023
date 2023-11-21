extends Area2D
class_name GrabPoint

@onready var shape: CollisionShape2D = $CollisionShape2D


func _on_body_entered(body):
	print("Body collide from ", self, " to ", body)


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):	
	print("Shape collide", body, body_shape_index)
	var owner = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	if owner is Endpoint and owner.extended and owner.type == Endpoint.HAND:
		print("Owner: ", owner, owner.type, owner.extended)
		body.emit_signal("grab", owner, self)
