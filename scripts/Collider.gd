@tool
class_name Collider

extends Node3D

@export_category("Relation")
@export var root_node:Node3D

@export_category("Collision")
@export var points:Array[Vector3]
@export_range(0.0,100.0) var width:float=0
@export_flags_3d_physics var layer:int=1
@export_flags_3d_physics var mask:int=1
@export var _is_hull_rect=false

var _segments:Array[Segment]
var _flag_set_hull:bool=false
var _hull

const _LAYER_NAMES:Array[String]=[
	"Collider_00","Collider_01","Collider_02",
	"Collider_03","Collider_04","Collider_05",
	"Collider_06","Collider_07","Collider_08",
	"Collider_09","Collider_10","Collider_11",
	"Collider_12","Collider_13","Collider_14",
	"Collider_15","Collider_16","Collider_17",
]
#static funcs
static func push_in_layer(collider:Collider)-> void:
	for i in Global.bit_flags_to_index(collider.layer):
		collider.add_to_group(_LAYER_NAMES[i])
		collider.add_to_group("Collider")

static func pop_from_layer(collider:Collider)-> void:
	for i in Global.bit_flags_to_index(collider.layer):
		collider.remove_from_group(_LAYER_NAMES[i])
		collider.add_to_group("Collider")

#public funcs
func hit_test(dest:Collider)-> Collision:
	if _intersect_hull(dest) == false : return null
	var collision:Collision = null
	
	for i in range(_segments.size()):
		if _segments[i].enable == false:
			continue
		for j in range(dest._segments.size()):
			if dest._segments[j].enable == false:
				continue
			collision = _segment_to_segment(i,dest,j)
			if collision != null:
				return collision
	return null

func hit_test_first(layer_mask:int=-1)-> Collision:
	if layer_mask==-1: layer_mask=mask
	else: layer_mask = 1 << layer_mask
	
	for i in Global.bit_flags_to_index(layer_mask):
		for collider in get_tree().get_nodes_in_group(_LAYER_NAMES[i]) as Array[Collider]:
			if collider == self || collider.visible == false: continue
			var hit = hit_test(collider)
			if hit !=null: return hit
	return null
	
func hit_test_all(layer_mask:int=-1)-> Array[Collision]:
	var res:Array[Collision]
	if layer_mask==-1: layer_mask=mask
	else: layer_mask = 1 << layer_mask
	
	for i in Global.bit_flags_to_index(layer_mask):
		for collider in get_tree().get_nodes_in_group(_LAYER_NAMES[i]) as Array[Collider]:
			if collider == self or collider.is_visible_in_tree() == false: continue
			var hit = hit_test(collider)
			if hit != null: res.push_back(hit)	
	return res

func get_segments()->Array[Segment]:
	return _segments

func get_pos_trans(collider:Segment)->Vector3:
	var pos_transed=collider.pos.rotated(Vector3.BACK,global_rotation.z)
	pos_transed+=global_position
	return pos_transed

func get_pos_trans_index(index:int)->Vector3:
	var pos_transed=_segments[index].pos.rotated(Vector3.BACK,global_rotation.z)
	pos_transed+=global_position
	return pos_transed

#private funcs
func _set_hull()-> void:
	if _is_hull_rect:
		_hull = Vector4.ZERO
		for seg in _segments:
			if seg.enable:
				if seg.pos.x-width < _hull.x: _hull.x = seg.pos.x-width
				elif seg.pos.x+width > _hull.z: _hull.z = seg.pos.x+width
				if seg.pos.y-width < _hull.y: _hull.y = seg.pos.y-width
				elif seg.pos.y+width > _hull.w: _hull.w = seg.pos.y+width
	else:
		_hull=0.0
		for seg in _segments:
			if seg.enable and (seg.pos.length()+width > _hull as float):
				_hull = seg.pos.length()+width

func _intersect_hull(dest:Collider)-> bool:
	if _is_hull_rect and dest._is_hull_rect:
		if dest.global_position.x+dest._hull.x > global_position.x+_hull.z and dest.global_position.x > global_position.x: return false
		if dest.global_position.x+dest._hull.z < global_position.x+_hull.x and dest.global_position.x <= global_position.x: return false
		if dest.global_position.y+dest._hull.y > global_position.y+_hull.w and dest.global_position.y > global_position.y: return false
		if dest.global_position.y+dest._hull.w < global_position.y+_hull.y and dest.global_position.y <= global_position.y: return false
	elif _is_hull_rect == false and dest._is_hull_rect == false:
		if (global_position-dest.global_position).length() > _hull + dest._hull:
			return false
	else:
		var rect_pos:Vector3
		var rect:Vector4
		var dest_pos:Vector3
		var dest_radius:float
		if _is_hull_rect:
			rect_pos = global_position
			rect = _hull as Vector4
			dest_pos=dest.global_position
			dest_radius=dest._hull as float
		elif dest._is_hull_rect:
			rect_pos = dest.global_position
			rect = dest._hull as Vector4
			dest_pos=global_position
			dest_radius=_hull as float	
		var dx:float = max(rect_pos.x+rect.x-dest_pos.x, dest_pos.x-(rect_pos.x+rect.z))
		var dy:float = max(rect_pos.y+rect.y-dest_pos.y, dest_pos.y-(rect_pos.y+rect.w))
		if dx >= 0 and dy >= 0:
			if sqrt(dx*dx + dy*dy) > dest_radius: return false
	return true

func _point_to_point(ind:int, dest:Collider, dest_ind:int)-> Collision: 
	var src_point:Vector3 = get_pos_trans_index(ind)
	var dest_point:Vector3 = dest.get_pos_trans_index(dest_ind)
	var closet:Vector3 = dest_point-src_point
	if closet.length() < width + dest.width:
		return Collider.Collision.new(ind, dest, dest_ind, closet - closet.normalized()*dest.width)
	else:
		return null

func _point_to_segment(ind:int, dest:Collider, dest_ind:int)-> Collision:
	if dest_ind == dest._segments.size()-1:
		return _point_to_point(ind,dest,dest_ind)
	else :
		var src_point:Vector3 = get_pos_trans_index(ind)
		var dest_point:Vector3 = dest.get_pos_trans_index(dest_ind) - src_point
		var dest_point_end:Vector3 = dest.get_pos_trans_index(dest_ind+1) -src_point
		var closet:Vector3 = Geometry3D.get_closest_point_to_segment(Vector3.ZERO, dest_point, dest_point_end)
		
		if closet.length() < width + dest.width:
			return Collider.Collision.new(ind, dest, dest_ind, closet - closet.normalized()*dest.width)
		else :
			return null
			
func _segment_to_segment(ind:int, dest:Collider, dest_ind:int)-> Collision:
	if ind == _segments.size()-1:
		return _point_to_segment(ind,dest,dest_ind)
	if dest_ind == dest._segments.size()-1:
		return dest._point_to_segment(dest_ind,self,ind)
	
	var src_point:Vector3 = get_pos_trans_index(ind)
	var src_point_end:Vector3 = get_pos_trans_index(ind+1)
	var dest_point:Vector3 = dest.get_pos_trans_index(dest_ind) - src_point
	var dest_point_end:Vector3 = dest.get_pos_trans_index(dest_ind+1) -src_point
	
	var array:= Geometry3D.get_closest_points_between_segments(src_point, src_point_end, dest_point, dest_point_end)
	var closet:Vector3 = array[1] - array[0]
	var distance:float = closet.length()
	if distance < width + dest.width:
		return Collider.Collision.new(ind, dest, dest_ind, closet - closet.normalized()*dest.width)
	else :
		return null
		
func _set_segment():
	_segments.clear()
	if points.size() == 0:
		_segments.push_back(Segment.new())
	else:
		for pos in points:
			_segments.push_back(Segment.new(pos,true))
	Collider.push_in_layer(self)
	_set_hull()
	
#override func
func _ready():
	_set_segment()

func _process(_delta):
	if Engine.is_editor_hint():
		if _segments.size() != points.size():
			_set_segment()
	if _flag_set_hull:
		_set_hull()
		_flag_set_hull=false

func _exit_tree():
	Collider.pop_from_layer(self)

func _notification(what):
	if what == 1:
		Collider.pop_from_layer(self)

#inner classes	
class Segment:
	var pos:Vector3
	var enable:bool
	
	func _init(pos_in:Vector3=Vector3.ZERO, enable_in:bool=true)-> void:
		self.pos=pos_in
		self.enable=enable_in

class Collision:
	var index:int
	var obj:Collider
	var obj_index:int
	var point:Vector3
	func _init(index_in:int, obj_in:Collider, obj_index_in:int, point_in:Vector3)-> void:
		self.index=index_in
		self.obj=obj_in
		self.obj_index=obj_index_in
		self.point=point_in
		
