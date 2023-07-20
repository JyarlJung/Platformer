class_name StateJump

extends State

func first_func()->void:
	cha.jump(cha.jump_force)
	cha.on_air=true

func proc()->String:
	if Input.is_key_pressed(KEY_RIGHT):
		var speed = cha.max_speed-cha.move_vec.dot(cha.slide_vector)
		cha.slide(clamp(speed,0.0,cha.accel))
	elif Input.is_key_pressed(KEY_LEFT):
		var speed = cha.max_speed+cha.move_vec.dot(cha.slide_vector)
		cha.slide(-clamp(speed,0.0,cha.accel))
	if cha.on_air == false:
		return "idle"
	return ""
