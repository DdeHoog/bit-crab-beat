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

# --- Called when node enters the scene tree ---
func _ready():
	# Get the actual Conductor node from the path
	if conductor_node_path.is_empty() or not has_node(conductor_node_path):
		printerr("Character Error: Conductor node path ('", conductor_node_path, "') is not set correctly or node not found!")
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
			printerr("Character Error: Failed to get Conductor node even though path seemed valid.")

	# Initial animation state
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("Idle")
	else:
		pass


# --- Physics Update ---
func _physics_process(delta):
	# --- Gravity ---
	if not hovering:
		velocity.y += GRAVITY * delta

	# --- Hover Logic ---
	if velocity.y > -APEX_THRESHOLD and velocity.y < APEX_THRESHOLD and not is_on_floor() and not hovering:
		start_hover()

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
		$RunCol.disabled = false # Check if this is correct

		if Input.is_action_just_pressed("Jump") and can_double_jump:
			velocity.y = JUMP_VELOCITY
			$AnimatedSprite2D.play("Jump")
			$JumpSFX.play()
			end_hover()
			can_double_jump = false

		elif Input.is_action_just_pressed("Down"): # Use elif
			velocity.y = DIVE_VELOCITY
			$DiveSFX.play()
			end_hover()
			# Optional: $AnimatedSprite2D.play("Dive")

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
	# print("Beat signal received: ", beat_number) # Debug print

	# Check conditions for applying beat sync
	if is_on_floor() and get_parent().game_running and $AnimatedSprite2D.animation == RUN_ANIMATION:
		var target_frame = beat_number - 1

		# Check frame validity
		var frame_count = $AnimatedSprite2D.sprite_frames.get_frame_count(RUN_ANIMATION)
		if target_frame >= 0 and target_frame < frame_count:
			$AnimatedSprite2D.frame = target_frame
			# print("Beat: ", beat_number, " Setting frame: ", target_frame) # Debug print
		else:
			print("Warning: Beat ", beat_number, " -> Target frame ", target_frame, " is out of bounds for '", RUN_ANIMATION, "' animation (Frame count: ", frame_count, ").")
	# else: # Debug print
		# print("Beat sync condition not met: is_on_floor=", is_on_floor(), " game_running=", get_parent().game_running, " current_anim=", $AnimatedSprite2D.animation)


# --- Cleanup ---
func _exit_tree():
	# Check if conductor exists before trying to disconnect
	if conductor and conductor.is_connected("beat_in_measure", _on_conductor_beat_in_measure):
		conductor.beat_in_measure.disconnect(_on_conductor_beat_in_measure)
		print("Character: Disconnected from Conductor beat signal.")
