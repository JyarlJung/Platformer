class_name Cha

extends Entity

@export_range(0.0,2.0,0.01) var accel:float = 0.5
@export var max_speed:float = 3.0
@export var jump_force:float = 5.0



# Called when the node enters the scene tree for the first time.
func _ready():
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_RIGHT):
		var speed = max_speed-move_vec.dot(slide_vector)
		slide(clamp(speed,0.0,accel))
	if Input.is_key_pressed(KEY_LEFT):
		var speed = max_speed+move_vec.dot(slide_vector)
		slide(-clamp(speed,0.0,accel))
	if Input.is_key_pressed(KEY_SPACE) and on_air==false:
		jump(jump_force)
		var camera:Camera = Global.camera as Camera
		camera.shake(Vector3.DOWN * 0.05)
	if Input.is_key_pressed(KEY_SHIFT):
		Global.set_time_scale(max(0.2,get_time_scale()-0.1))
	else:
		Global.set_time_scale(min(1.0,get_time_scale()+0.05))
	super(delta)
