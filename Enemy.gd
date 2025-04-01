extends Area2D

func _on_body_entered(body: Node2D) -> void:
	#Allows for destruction of enemy by jumping on em
	if body.velocity.y > 0 and body.global_position.y < global_position.y:
			body.velocity.y = -500
			queue_free()
			return
	get_tree().quit()
