class_name StateMove

extends State

func proc()->String:
	if Input.is_key_pressed(KEY_RIGHT):
		var speed = cha.max_speed-cha.move_vec.dot(cha.slide_vector)
		cha.slide(clamp(speed,0.0,cha.accel))
	elif Input.is_key_pressed(KEY_LEFT):
		var speed = cha.max_speed+cha.move_vec.dot(cha.slide_vector)
		cha.slide(-clamp(speed,0.0,cha.accel))
	elif cha.move_vec.x==0.0:
		return "idle"
	if cha.on_air:
		return "fall"
	return ""
