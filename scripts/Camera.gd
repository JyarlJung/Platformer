class_name Camera

extends Camera3D

@export var follow_node:Node3D
@export var node_position:Vector3=Vector3.BACK

func _ready():
	pass # Replace with function body.


func _process(delta):
	if follow_node != null:
		var move_vec:Vector3=follow_node.global_position+node_position
		move_vec = move_vec-global_position
		translate(move_vec * Global.get_time_delta() * 3.0)
	pass
