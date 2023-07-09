class_name Global

extends Node

var is_draw_debug:bool = true
var gravity:float =0.2
var time_scale:float=1.0

var _time_delta:float = 0.0
var _time_delta_fixed:float = 0.0
var _time:float = 0.0
var _time_fixed:float = 0.0
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

func get_time()->float:
	return _time

func draw_debug()->void:
	var mesh:ImmediateMesh = _debug_mesh.mesh as ImmediateMesh
	mesh.clear_surfaces()
	for collider in get_tree().get_nodes_in_group("Collider") as Array[Collider]:
		if collider.get_segments().size() < 2: continue
		mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP,_debug_material)
		for segment in collider.get_segments():
			var color:Color = Color.BLUE if segment.enable else Color.RED
			mesh.surface_set_color(color)
			mesh.surface_add_vertex(collider.get_pos_trans(segment))
		mesh.surface_end()

func _ready():
	add_child(_debug_mesh)
	_debug_mesh.mesh = ImmediateMesh.new()
	_debug_material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	_debug_material.no_depth_test=true
	_debug_material.depth_draw_mode=BaseMaterial3D.DEPTH_DRAW_DISABLED
	_time_delta_fixed = 1.0/Engine.max_fps


func _process(_delta):
	if is_draw_debug:
		draw_debug()
	_time_delta = _time_delta_fixed * time_scale
	_time +=_time_delta
	_time_fixed = _time_delta_fixed
