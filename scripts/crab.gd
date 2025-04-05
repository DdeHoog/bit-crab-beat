extends CharacterBody2D

const GRAVITY = 4100
const JUMP_VELOCITY = -1750
@export var max_health := 3
@onready var current_health := max_health


#Called every frame 'delta' is elapsed tiem since the previous frame.
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running: #get func from parent node(main.scn) to check if game started.
			$AnimatedSprite2D.play("Idle")
		else: #if game started:
			$RunCol.disabled = false
			if Input.is_action_pressed("Jump"):
				velocity.y = JUMP_VELOCITY
				$JumpSound.play()
			#elif Input.is_action_pressed("Down"):
			#	$AnimatedSprite2D.play("Duck")
			#	$RunCol.disabled = true
			else:
				$AnimatedSprite2D.play("Run")
	else:
		$AnimatedSprite2D.play("Jump")
	#Moves the body based on velocity. If the body collides with another, 
	#it will slide along the other body (by default only on floor) rather than stop immediately.	
	move_and_slide()
