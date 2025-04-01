extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func game_over():
	#$deathsound.play()
	#$music.stop()
	#$hud.show_game_over()
	#hide background and gamestuff then show menu
	#$Menu.show()
	pass
	
func new_game():
	pass
	#$Menu.hide()
	#spawn background en lvls + player
	#score = 0
	#$Player.start($StartPosition.position)
	#$StartTimer.start()
	#$HUD.update_score(score)
	#$HUD.show_message("Get Ready")
	
#func _on_start_time_timeout():
	#start music + level animations?d
