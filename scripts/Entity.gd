class_name Entity

extends Node3D

@export var time_scaled:bool = true
@export_range(-1.0,1.0,0.01) var friction:float = -1.0
@export var is_friction_onair = false
@export var is_sticky:bool = false
@export var gravity_scale:float = 1.0
@export var body:Collider = null

var move_vec:Vector3 = Vector3.ZERO
var on_air:bool =true

var slide_vector:Vector3

static func arrow_to_quater(arrow:Vector3)->Vector3:
	if abs(arrow.x) > abs(arrow.y):
		return Vector3.RIGHT * (arrow.x + abs(arrow.y))
	else:
		return Vector3.UP * (arrow.y + abs(arrow.x))

static func rot_to_vec(degree:float)->Vector3:
	var vec:Vector3=Vector3.ZERO
	vec.x=cos(deg_to_rad(degree))
	vec.y=sin(deg_to_rad(degree))
	return vec

func move(speed:Vector3)->void:
	move_vec += time_scaled_vec(speed)
	
func move_forward(speed:float)->void:
	move(Entity.rot_to_vec(global_rotation_degrees.z) * speed)

func slide_x(speed:float)->void:
	move(slide_vector * speed)

func time_scaled_vec(vec:Vector3)->Vector3:
	var scaled:float
	
	if time_scaled: scaled = Global.get_time_delta()
	else: scaled = Global.get_time_delta_fixed()
	
	return vec * scaled

func time_scaled_float(value:float)->float:
	var scaled:float
	
	if time_scaled: scaled = Global.get_time_delta()
	else: scaled = Global.get_time_delta_fixed()
	
	return value * scaled

func trans(vec:Vector3)->void:
	translate(time_scaled_vec(vec))

func trans_forward(speed:float)->void:
	trans(Entity.rot_to_vec(global_rotation_degrees.z) * speed)

func rotate_entity(degree:float)->void:
	if time_scaled: rotate_z(degree * Gb.time_scale)
	else: rotate_z(degree)

func scale_entity(vec:Vector3)->void:
	var scale_vec:Vector3
	if time_scaled: scale_vec = vec * Gb.time_scale
	else: scale_vec = vec
	scale_object_local(scale_vec)

func _frict(value:float)->void:
	var friction_vector:Vector3 = time_scaled_vec(Vector3.LEFT * sign(move_vec.x) * value)
	if abs(move_vec.x) < abs(friction_vector.x):
		move_vec.x=0.0
	else:
		move_vec+=friction_vector

func _ready():
	pass

func _process(_delta):
	translate(move_vec)
	
	move(Vector3.DOWN * Gb.gravity)
	if friction < 0 :
		if gravity_scale == 0 : move_vec *= 0.0
		else: move_vec *= Vector3.UP
	if body != null:
		on_air=false
		slide_vector=Vector3.RIGHT
		var friction_value:float = 0.0
		var move_length = move_vec.length()
		var bounce:Vector3
		for collision in body.hit_test_all():
			var bounce_arrow:Vector3 = collision.point.normalized()
			var collision_width:float = collision.point.length() - body.width
			bounce = bounce_arrow * collision_width
			if abs(bounce_arrow.y)>abs(bounce_arrow.x) :
				on_air=true
				slide_vector = bounce_arrow.rotated(Vector3.BACK,PI*0.5)
				
			if is_sticky: bounce = arrow_to_quater(bounce)
			translate(bounce)
			if is_sticky : 
				friction_value = friction
			else :
				friction_value = friction * bounce.normalized().y
				
		move_vec += bounce
		if friction > 0:
			if is_friction_onair: _frict(friction)
			else : _frict(friction_value)
