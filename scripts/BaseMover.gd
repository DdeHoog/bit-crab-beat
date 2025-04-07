extends Node2D

const MOVE_VELOCITY = 500
var startPos : int
var maxMove : int = 500
var goalPos : int
var modifier : int = -1

@export_group("Settings")
@export var reverse:bool = false
#@export var my_var: int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startPos = position.x
	if(reverse):
		goalPos = startPos+maxMove * -1;
	else:
		goalPos = startPos+maxMove;

#Called every frame 'delta' is elapsed time since the previous frame.
func _process(delta):
		if (reverse):
			if (position.x <= goalPos):
				position.x = startPos
			else:
				position.x += MOVE_VELOCITY * delta *-1
		else:
			if (position.x >= goalPos):
				position.x = startPos
			else:
				position.x += MOVE_VELOCITY * delta
