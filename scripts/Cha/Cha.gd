class_name Cha

extends Entity

@export_range(0.0,2.0,0.01) var accel:float = 0.5
@export var max_speed:float = 3.0
@export var jump_force:float = 5.0
@export var state_text:Label3D

var state:State = null
var state_name:String
var state_dic:Dictionary={
	"idle":StateIdle,
	"move":StateMove,
	"jump":StateJump,
	"fall":StateFall,
}

func _ready():
	transition("idle")
	super()


func _process(delta):
	if state != null:
		var trans:String = state.proc()
		while trans != "":
			transition(trans)
			trans = state.proc()
	super(delta)

func _input(event:InputEvent):
	state.input(event)

func transition(name:String)->void:
	if name == "" or state_dic.get(name) == null: return
	if state != null: state.call_deferred("free")
	state=state_dic[name].new(self)
	state_name = name
	state_text.text = state_name
