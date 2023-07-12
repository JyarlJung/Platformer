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
	var length:float = pow(arrow.length(),2.0)
	if abs(arrow.x) > abs(arrow.y):
		return Vector3.RIGHT * length/arrow.x
	else:
		return Vector3.UP * length/arrow.y

static func rot_to_vec(degree:float)->Vector3:
	var vec:Vector3=Vector3.ZERO
	vec.x=cos(deg_to_rad(degree))
	vec.y=sin(deg_to_rad(degree))
	return vec

func move(speed:Vector3)->void:
	move_vec += get_time_scale() * speed
	
func move_forward(speed:float)->void:
	move(Entity.rot_to_vec(global_rotation_degrees.z) * speed)

func slide(speed:float)->void:
	if abs(slide_vector.y) < 0.5:
		move(slide_vector * speed)

func get_time_delta()->float:
	if time_scaled: return Global.get_time_delta()
	else: return Global.get_time_delta_fixed()
	
func get_time_scale()->float:
	if time_scaled: return Global.time_scale
	else: return 1.0
	

func trans(vec:Vector3)->void:
	translate(vec * get_time_delta())

func trans_forward(speed:float)->void:
	trans(Entity.rot_to_vec(global_rotation_degrees.z) * speed)

func rot(degree:float)->void:
	if time_scaled: rotate_z(degree * Gb.time_scale)
	else: rotate_z(degree)

func scl(vec:Vector3)->void:
	var scale_vec:Vector3
	if time_scaled: scale_vec = vec * Gb.time_scale
	else: scale_vec = vec
	scale_object_local(scale_vec)

func _frict(value:float)->void:
	var friction_vector:Vector3 = slide_vector * sign(move_vec.x)
	friction_vector *= value * get_time_scale()
	if abs(move_vec.x) < abs(friction_vector.x):
		move_vec.x=0.0
	elif abs(friction_vector.x) > abs(friction_vector.y):
		move_vec-=friction_vector

func _collide(collision:Collider.Collision)->void:
	var bounce_arrow:Vector3 = collision.point.normalized()
	var collision_width:float = min(collision.point.length() - body.width, move_vec.length())
	var bounce:Vector3 = bounce_arrow * collision_width
	if bounce_arrow.y < -0.5 :
		on_air=false
		slide_vector = bounce_arrow
	elif bounce_arrow.y < abs(slide_vector.y):
		slide_vector = bounce_arrow
	if is_sticky:
		translate(Entity.arrow_to_quater(bounce))
	else:
		translate(bounce)
	move_vec += bounce / get_time_delta()
func _ready():
	pass

func _process(_delta):
	if is_visible_in_tree() == false: return
	trans(move_vec)
	move(Vector3.DOWN * Global.gravity)
	if body != null:
		on_air=true
		slide_vector=Vector3.DOWN
		for collision in body.hit_test_all():
			_collide(collision)
		slide_vector=slide_vector.cross(Vector3.FORWARD)
	if friction < 0 :
		if gravity_scale == 0 : move_vec *= 0.0
		else: move_vec *= Vector3.UP
	else:
		if is_friction_onair: _frict(friction)
		elif on_air == false : _frict(friction)
