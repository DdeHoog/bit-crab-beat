extends CharacterBody2D


const GRAVITY = 4100
const JUMP_VELOCITY = -1750

#Called every frame 'delta' is elapsed tiem since the previous frame.
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		$RunCol.disabled = false
		if Input.is_action_pressed("Jump"):
			velocity.y = JUMP_VELOCITY
			$JumpSound.play()
		elif Input.is_action_pressed("Down"):
			$AnimatedSprite2D.play("Duck")
			$RunCol.disabled = true
		else:
			$AnimatedSprite2D.play("Run")
	else:
		$AnimatedSprite2D.play("Jump")
	#Moves the body based on velocity. If the body collides with another, 
	#it will slide along the other body (by default only on floor) rather than stop immediately.	
	move_and_slide()
