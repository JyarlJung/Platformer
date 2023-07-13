@tool
class_name Global

extends Node

static var _time:float = 0.0
static var _time_fixed:float = 0.0
static var _time_delta:float = 0.0
static var _time_delta_fixed:float = 0.0
static var time_scale:float=1.0
static var camera:Camera3D
var is_draw_debug:bool = true
static var gravity:float =0.15

var _debug_mesh:MeshInstance3D = MeshInstance3D.new()
var _debug_material:StandardMaterial3D=StandardMaterial3D.new()

static func bit_flags_to_index(bit:int , max_size:int=32)-> PackedInt32Array:
	var ind:int=0
	var res:PackedInt32Array=[]
	while bit > 0 and ind<=max_size:
		if bit & (1<<ind) !=0:
			res.push_back(ind)
		ind+=1
		bit=bit>>1
	return res

static func get_time()->float:
	return _time
	
static func get_time_fixed()->float:
	return _time_fixed
	
static func get_time_delta()->float:
	return _time_delta
	
static func get_time_delta_fixed()->float:
	return _time_delta_fixed
	
static func set_time_scale(value:float)->float:
	value = clamp(value,0.0,4.0)
	time_scale=value
	return value

func timer(time:float, scaled=true)->void:
	if scaled:
		var start_time:float = _time
		while start_time+time > _time: 
			await get_tree().process_frame	
		return
	else:
		var start_time:float = _time_fixed
		while start_time+time > _time_fixed: 
			await get_tree().process_frame	
		return		

func draw_debug()->void:
	var mesh:ImmediateMesh = _debug_mesh.mesh as ImmediateMesh
	mesh.clear_surfaces()
	for collider in get_tree().get_nodes_in_group("Collider") as Array[Collider]:
		mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP,_debug_material)
		
		mesh.surface_add_vertex(collider.get_pos_trans_index(0)+Vector3.UP*collider.width)
		mesh.surface_add_vertex(collider.get_pos_trans_index(0)+Vector3.DOWN*collider.width)
		
		for seg in collider.get_segments():
			mesh.surface_add_vertex(collider.get_pos_trans(seg))
			
		mesh.surface_add_vertex(collider.get_pos_trans_index(collider.get_segments().size()-1)+Vector3.UP*collider.width)
		mesh.surface_add_vertex(collider.get_pos_trans_index(collider.get_segments().size()-1)+Vector3.DOWN*collider.width)
		
		mesh.surface_end()

func _ready():
	add_child(_debug_mesh)
	_debug_mesh.mesh = ImmediateMesh.new()
	_debug_mesh.sorting_offset=10
	_debug_material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	_debug_material.no_depth_test=true
	_debug_material.depth_draw_mode=BaseMaterial3D.DEPTH_DRAW_DISABLED
	_time_delta_fixed = 1.0/Engine.max_fps
	camera=get_viewport().get_camera_3d()


func _process(_delta):
	if is_draw_debug or Engine.is_editor_hint():
		draw_debug()
	_time_delta = _time_delta_fixed * time_scale
	_time +=_time_delta
	_time_fixed += _time_delta_fixed
