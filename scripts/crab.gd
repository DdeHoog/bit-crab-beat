extends CharacterBody2D

const GRAVITY = 6500
const JUMP_VELOCITY = -1750
const DIVE_VELOCITY = 4000
const MAX_JUMP_VELOCITY = -JUMP_VELOCITY # Clamp the max jump velocity
const HOVER_DURATION := 0.6 #time in sec to hover
const APEX_THRESHOLD := 50.0 #Velocity near-zero threshold
var hovering := false
var hover_timer : float
@export var max_health := 3
@onready var current_health := max_health


#Called every frame 'delta' is elapsed tiem since the previous frame.
func _physics_process(delta):
	if not hovering:
			velocity.y += GRAVITY * delta
			
	if velocity.y > -APEX_THRESHOLD && velocity.y < APEX_THRESHOLD && !is_on_floor()&& !hovering:
		start_hover()
		
	#Landing contionals
	if is_on_floor():
		if not get_parent().game_running: #get func from parent node(main.scn) to check if game started.
			$AnimatedSprite2D.play("Idle")
		else: #if game started:
			$RunCol.disabled = false
			if Input.is_action_just_pressed("Jump"):
				velocity.y = JUMP_VELOCITY
				$AnimatedSprite2D.play("Jump")
				$JumpSound.play()
			else:
				
				$AnimatedSprite2D.play("Run")
	#While midair/dive
	elif !is_on_floor():
			$RunCol.disabled = false
			if Input.is_action_just_pressed("Down"):
				velocity.y = DIVE_VELOCITY
				$JumpSound.play()
				end_hover()
					
	else:
		$AnimatedSprite2D.play("Jump")
	move_and_slide()
		
func start_hover():
	hovering = true
	velocity.y = 0  # Freeze vertical movement
	# Use a one-shot timer to end the hover after a duration
	get_tree().create_timer(HOVER_DURATION).timeout.connect(end_hover)
		
func end_hover():
	hovering = false
