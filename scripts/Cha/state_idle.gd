class_name StateIdle

extends State

func proc()->String:
	if Input.is_key_pressed(KEY_RIGHT):
		return "move"
	if Input.is_key_pressed(KEY_LEFT):
		return "move"
	if Input.is_key_pressed(KEY_SPACE):
		return 'jump'
	if cha.on_air:
		return "fall"
	return ""
