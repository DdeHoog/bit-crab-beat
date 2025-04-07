extends Node2D

# --- Essential Setup ---
# Preload the Arrow scene
const TimeStickScene = preload("res://scenes/time_stick.tscn")

# Textures for the arrows (assign in Inspector)
@export var left_timestick_texture: Texture
@export var right_timestick_texture: Texture

# How many beats should it take for an arrow to travel from spawn to center?
# This controls the pace/speed. Adjust in Inspector.
@export var travel_beats: int = 4

# Reference to your Conductor node (IMPORTANT: Adjust the path!)
# Example paths: "../Conductor", "/root/Game/ConductorNode"
@onready var conductor: AudioStreamPlayer = get_node("/root/Main/Conductor") # ADJUST PATH

#for timing animation to the beat
@onready var beat_bar: AnimatedSprite2D = get_node("/root/Main/HUD/BeatIndicator")

# --- Internal Variables ---
var screen_center_x: float
var spawn_distance_from_center: float
var timestick_speed: float = 200.0 # Default speed, will be calculated

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get screen info
	var screen_width = get_window().size.x
	screen_center_x = screen_width / 2

	# Set spawn distance (e.g., spawn at screen edges)
	spawn_distance_from_center = screen_width / 1

	# --- Calculate Speed based on Conductor's BPM ---
	if conductor and conductor.sec_per_beat > 0 and travel_beats > 0:
		var travel_time_seconds = travel_beats * conductor.sec_per_beat
		timestick_speed = spawn_distance_from_center / travel_time_seconds
		print("Calculated stick speed based on %d beats: %f" % [travel_beats, timestick_speed])
	else:
		print("Warning: Could not calculate speed from Conductor. Using default: %f" % timestick_speed)
		# Optionally, fall back to spawning further out if speed is default
		spawn_distance_from_center = timestick_speed * (travel_beats * (60.0 / 100.0)) # Estimate based on 100bpm

	# --- Remove Old Arrow References ---
	# Delete or comment out the old @onready vars if they exist:
	# @onready var beat_left: Sprite2D = $Beat_Left
	# @onready var beat_right: Sprite2D = $Beat_Right
	# And hide/remove the original Beat_Left/Beat_Right nodes from your scene tree
	# if they are separate nodes.


# Connected to the Conductor's signal
func _on_conductor_beat_in_song(position): # position is the beat number
	#print("DEBUG: Beat signal received! Beat:", position) # <-- ADD THIS LINE
	if position % 2 == 0:
			beat_bar.play("Beat0")
	elif position % 2 == 1:
			beat_bar.play("Beat1")
	
	spawn_arrow_pair()


func spawn_arrow_pair():
	# --- Spawn Left Arrow (Starts Left, Moves Right) ---
	var left_timestick = TimeStickScene.instantiate() as Node2D
	var left_spawn_pos = Vector2(screen_center_x - spawn_distance_from_center, get_window().size.y / 2) # Adjust Y?
	add_child(left_timestick)
	left_timestick.setup(left_spawn_pos, screen_center_x, 1, timestick_speed, left_timestick_texture)

	# --- Spawn Right Arrow (Starts Right, Moves Left) ---
	var right_timestick = TimeStickScene.instantiate() as Node2D
	var right_spawn_pos = Vector2(screen_center_x + spawn_distance_from_center, get_window().size.y / 2) # Adjust Y?
	add_child(right_timestick)
	right_timestick.setup(right_spawn_pos, screen_center_x, -1, timestick_speed, right_timestick_texture)


# --- Remove Old Functions ---
# Delete or comment out these functions as they are replaced by the new system:
# func reset_arrow_positions(): ...
# func move_arrows_one_beat(): ...
# func on_arrows_moved(): ...

# _process is likely not needed here unless you have other logic
func _process(delta: float) -> void:
	pass

# --- Add this function ---
func reset():
	# Iterate through all direct children of this spawner node
	for child in get_children():
		# Optional but safer: Check if the child is actually a time stick
		# This assumes your TimeStickScene's root node has a script attached
		# or you can identify it by class name if it's a custom class.
		# If TimeStickScene root is just Node2D, checking script is better.
		if child.get_script() == TimeStickScene.get_script(): # Example check
			child.queue_free()
		# Or, if you don't need the check (assuming ONLY time sticks are children):
		# child.queue_free()
	print("TimeStickSpawner: Cleared existing time sticks.")
