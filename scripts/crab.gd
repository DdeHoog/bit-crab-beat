extends CharacterBody2D

const GRAVITY = 10000
const JUMP_VELOCITY = -1750
const DOUBLE_JUMP_VELOCITY = -1000 # Kept for reference
const DIVE_VELOCITY = 4000
const MAX_JUMP_VELOCITY = -JUMP_VELOCITY
const HOVER_DURATION := 0.6
const APEX_THRESHOLD := 100.0
var hovering := false
# var hover_timer : float # Kept for reference
var can_double_jump = true
@export var max_health := 3
@onready var current_health := max_health

# --- Beat Sync ---
@export var conductor_node_path: NodePath = NodePath("../Conductor")
var conductor: AudioStreamPlayer # Will hold the actual conductor node reference
const RUN_ANIMATION = "Run" # Make sure this matches your animation name

# --- ADD THE _ready() FUNCTION ---
func _ready():
	# Get the actual Conductor node from the path
	if conductor_node_path.is_empty() or not has_node(conductor_node_path):
		printerr("Character Error: Conductor node path ('", conductor_node_path, "') is not set correctly or node not found!")
		# Decide how to handle: maybe disable beat sync features or stop game?
		# For now, conductor will remain null.
	else:
		conductor = get_node(conductor_node_path)
		# IMPORTANT: Check if conductor was successfully retrieved before connecting
		if conductor:
			# Connect the beat signal from the conductor to our handler function
			if conductor.has_signal("beat_in_measure"): # Good practice to check
				conductor.beat_in_measure.connect(_on_conductor_beat_in_measure)
				print("Character: Successfully connected to Conductor's beat_in_measure signal.")
			else:
				printerr("Character Error: Conductor node does NOT have the 'beat_in_measure' signal.")
		else:
			 # This case might happen if get_node fails silently for some reason, though unlikely if has_node passed.
			printerr("Character Error: Failed to get Conductor node even though path seemed valid.")

	# You might want to set an initial animation state here too
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("Idle")
		 #else:
			  # Consider setting initial run frame here? Or let _physics_process handle it.
			  # $AnimatedSprite2D.animation = RUN_ANIMATION
			  # $AnimatedSprite2D.frame = 0 # Start on first frame
			  # $AnimatedSprite2D.stop()
	else:
		# Set initial air animation?
		pass


# --- Physics Process ---
# --- Physics Update ---
func _physics_process(delta):
	# ... (Gravity, Hover logic) ...

	# --- State Logic & Animations ---
	var game_is_running = get_parent().game_running # Cache the check

	# -- On Floor --
	if is_on_floor():
		can_double_jump = true
		if not game_is_running:
			# Only play if not already idle
			if $AnimatedSprite2D.animation != "Idle":
				$AnimatedSprite2D.play("Idle")
		else: # Game running & on floor
			$RunCol.disabled = false
			if Input.is_action_just_pressed("Jump"):
				velocity.y = JUMP_VELOCITY
				# When jumping, ensure the normal Jump animation plays
				$AnimatedSprite2D.play("Jump")
				$JumpSFX.play()
			else:
				# --- REVISED RUNNING LOGIC ---
				# Check if we are NOT already in the Run animation state properly configured
				if $AnimatedSprite2D.animation != RUN_ANIMATION:
					# Switch TO the Run animation
					$AnimatedSprite2D.animation = RUN_ANIMATION
					# Stop playback ONCE when switching TO Run.
					# The frame will be set by the beat handler shortly.
					$AnimatedSprite2D.stop()
				# --- REMOVED THE REPEATED stop() CALL ---
				# If we are already in the RUN_ANIMATION, we *don't* want to call stop() again here,
				# otherwise it resets the frame set by the beat handler.
				# The beat handler _on_conductor_beat_in_measure will now correctly
				# update the frame, and it won't be reset immediately by _physics_process.

	# -- Mid-Air --
	elif not is_on_floor():
		# ... (rest of mid-air logic: Jump, Dive, etc.) ...
		# Ensure that when landing, the logic correctly transitions back to the
		# floor state which will set the Run animation and stop it once.
		pass # Placeholder if no specific mid-air default animation needed here

	# Apply movement
	move_and_slide()


# --- Hover Functions ---
func start_hover():
	hovering = true
	velocity.y = 0
	get_tree().create_timer(HOVER_DURATION).timeout.connect(end_hover)

func end_hover():
	hovering = false


# --- Beat Signal Handler ---
func _on_conductor_beat_in_measure(beat_number: int):
	# Added a print to confirm signal reception
	# print("Beat signal received: ", beat_number)

	# Check conditions for applying beat sync
	if is_on_floor() and get_parent().game_running and $AnimatedSprite2D.animation == RUN_ANIMATION:
		var target_frame = beat_number - 1

		# Check frame validity
		var frame_count = $AnimatedSprite2D.sprite_frames.get_frame_count(RUN_ANIMATION)
		if target_frame >= 0 and target_frame < frame_count:
			$AnimatedSprite2D.frame = target_frame
			# Uncomment for detailed debugging:
			# print("Beat: ", beat_number, " Setting frame: ", target_frame)
		else:
			# This warning is important if it appears often
			print("Warning: Beat ", beat_number, " -> Target frame ", target_frame, " is out of bounds for '", RUN_ANIMATION, "' animation (Frame count: ", frame_count, ").")
	# else: # Optional: Debug why the condition isn't met
		# print("Beat sync condition not met: is_on_floor=", is_on_floor(), " game_running=", get_parent().game_running, " current_anim=", $AnimatedSprite2D.animation)


# --- Cleanup ---
func _exit_tree():
	# Check if conductor exists *before* trying to access its methods
	if conductor and conductor.is_connected("beat_in_measure", _on_conductor_beat_in_measure):
		conductor.beat_in_measure.disconnect(_on_conductor_beat_in_measure)
		print("Character: Disconnected from Conductor beat signal.")
