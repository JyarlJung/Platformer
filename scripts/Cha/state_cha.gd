class_name State

extends RefCounted

var cha:Cha

func _init(cha:Cha)->void:
	self.cha=cha
	first_func()
	
func first_func()->void:
	pass
	
func proc()->String:
	return ""
	
func input(event:InputEvent)->void:
	pass

func last_func()->void:
	pass
