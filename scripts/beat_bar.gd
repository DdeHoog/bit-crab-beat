extends TextureProgressBar

const total_beats = 128
var max_steps : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_steps = total_beats
	max_value = max_steps

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_conductor_beat_in_song(position):
	if value < max_value:
		value += step
	#print("test") 
