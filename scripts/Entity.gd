class_name Entity

extends Node3D

@export var time_scaled:bool = true
@export var use_inertial:bool = true
@export var gravity_scale:float = 1.0

var move_vec:Vector3 = Vector3.ZERO

static func rot_to_vec(degree:float)->Vector3:
	var vec:Vector3=Vector3.ZERO
	vec.x=cos(deg_to_rad(degree))
	vec.y=sin(deg_to_rad(degree))
	return vec

func move_forward(speed:float)->void:
	move(Entity.rot_to_vec(global_rotation_degrees.z) * speed)

func move(speed:Vector3)->void:
	if time_scaled: move_vec += speed * Gb._time_delta
	else: move_vec += speed * Gb._time_delta_fixed

func move_forward_imm(speed:float)->void:
	move_imm(Entity.rot_to_vec(global_rotation_degrees.z) * speed)

func move_imm(speed:Vector3)->void:
	if time_scaled: translate(speed * Gb._time_delta)
	else: translate(speed * Gb._time_delta_fixed)

func rotate_entity(degree:float)->void:
	if time_scaled: rotate_z(degree * Gb.time_scale)
	else: rotate_z(degree)

func scale_entity(vec:Vector3)->void:
	var scale_vec:Vector3
	if time_scaled: scale_vec = vec * Gb.time_scale
	else: scale_vec = vec
	scale_object_local(scale_vec)

func _ready():
	pass

func _process(_delta):
	move(Vector3.DOWN * Gb.gravity)
	translate(move_vec)
	if use_inertial == false :
		if gravity_scale == 0 : move_vec *= 0.0
		else: move_vec *= Vector3.UP
