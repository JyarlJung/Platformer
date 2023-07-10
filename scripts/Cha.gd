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
		if time_scaled_float(max_speed) > move_vec.dot(slide_vector):
			slide_x(accel)
	if Input.is_key_pressed(KEY_LEFT):
		if time_scaled_float(max_speed) > move_vec.dot(-slide_vector):
			slide_x(-accel)
	if Input.is_key_pressed(KEY_SPACE) and on_air:
		move_vec.y = time_scaled_float(jump_force)
	super(delta)
