class_name Camera

extends Camera3D

@export var follow_node:Node3D
@export var follow_power:float=3.0

var _shake_vector:Vector3=Vector3.ZERO
@onready var _pos_origin:Vector3 = self.global_position

func shake(vec:Vector3)->void:
	if _shake_vector != Vector3.ZERO:
		_shake_vector=vec
		return
	else:
		_shake_vector=vec
		while _shake_vector.length() > 0.005:
			await Gb.timer(0.015)
			_shake_vector *= -0.9
		_shake_vector=Vector3.ZERO
	

func _ready():
	pass # Replace with function body.

func _process(_delta):
	if follow_node != null:
		var move_vec:Vector3=follow_node.global_position
		move_vec = move_vec-_pos_origin + Vector3.BACK
		move_vec *= Global.get_time_delta() * 3.0
		_pos_origin += move_vec
		global_position=_pos_origin + _shake_vector
