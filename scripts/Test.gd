extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(Vector3.RIGHT*delta)
	var coll:Collider = get_child(0) as Collider
	for hit in coll.hit_test_all():
		print(hit.index)
	pass
