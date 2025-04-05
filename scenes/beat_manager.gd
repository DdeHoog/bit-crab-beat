extends Node

@onready var beat_left: Sprite2D = $Beat_Left
@onready var beat_right: Sprite2D = $Beat_Right

var screen_center_x: float
var distance_per_beat: float
var beats_to_center := 1 #adjust this for number of steps to center/reset
var beats_moved := 0
var is_moving := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_center_x = get_window().size.x / 2
	var start_offset = get_window().size.x / 4
	distance_per_beat = get_window().size.x / 2.2
	reset_arrow_positions()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func reset_arrow_positions():
	beat_left.position.x = screen_center_x - get_window().size.x / 2.2
	beat_right.position.x = screen_center_x + get_window().size.x / 2.2
	is_moving = false
	beats_moved = 0
	beat_left.show()
	beat_right.show()
	
	
func move_arrows_one_beat():
	if not is_moving:
		is_moving = true
		var tween_left = create_tween()#using tween for smooth animation handling, check docs
		tween_left.tween_property(beat_left, "position:x", beat_left.position.x + distance_per_beat, 0.15) #dajust duration as needed
		#tween_property(object: Object, property: NodePath, final_val: Variant, duration: float)

		var tween_right = create_tween()
		tween_right.tween_property(beat_right, "position:x", beat_right.position.x - distance_per_beat, 0.15) 

		tween_right.parallel().tween_callback(self.on_arrows_moved) #after animation finished, calls completed move func
	
	
func on_arrows_moved():
		is_moving = false # Allows moving for the next beat, preps arrows for next move
	
	
#func _on_conductor_beat_in_song(position):
	#if beats_moved < beats_to_center:
		#move_arrows_one_beat()
		#beats_moved += 1
		#if beats_moved >= beats_to_center:#reset arrows after predetermined hops to center.
			#reset_arrow_positions()#could not get them to line up nicely to reset based on pos.x :/
	#move_arrows_one_beat()
