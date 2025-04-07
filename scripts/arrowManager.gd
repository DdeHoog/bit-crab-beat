extends Node

@export var crabObject:Node
@export var arrowArray:Array[Node]
var arrayID:int = 0
var arrayCloseID:int = 0


## --- Called when node enters the scene tree ---
func _ready():
	arrayID = 0;
	
#Called every frame 'delta' is elapsed time since the previous frame.
func _process(delta):
	if (((crabObject.position.x + 500) > arrowArray[arrayID].position.x) && arrayID < arrowArray.size()):
		#print_debug("test");
			arrowArray[arrayID].visible = true;
			arrayID = arrayID+1;
	if (((crabObject.position.x + 1000) > arrowArray[arrayCloseID].position.x) && arrayCloseID < arrowArray.size()):
		#print_debug("test");
			arrowArray[arrayCloseID].visible = false;
			arrayCloseID = arrayCloseID+1;
