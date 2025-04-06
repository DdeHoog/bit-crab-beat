extends Node

#game variables 
const START_SPEED : float = 213.34 * 2 #Starting off speed 
const MAX_SPEED : int = 1000 #Define a max speed, incase we increase speed overtime, added limit.
const SPEED_MODIFIER := 50000 #Needed to divide speed to not go giga fast in 2 sec - temp fix, remove later?
const SCORE_MODIFIER := 1000 #Needed to divide the score to keep numbers reasonable - temp fix, remove later.
var CRAB_START_POS : Vector2i  
var CAM_START_POS : Vector2i  
var high_score : int
var speed : int #allows for playerspeed to vary based on lvl/score/time
var screen_size : Vector2i #prep variable for screensize
var score : int #variable to keep track of score
var game_running : bool #boolean to see if game is running or not
var beat_trigger : bool
var inside_good_hitbox := false #Vars to check which hitbox the player box is inside of
var inside_perfect_hitbox := false
var can_score_good := true
var can_score_perfect := true

# Beat timing variables
var last_beat_position : float = 0.0
var time_since_last_beat : float = 0.0
const BEAT_WINDOW : float = 0.15 # 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size #get the window size, for ground scrolling
	$GameOver.get_node("RestartButton").pressed.connect(new_game)#when button pressed, new game trigger
	new_game()#init new game
	
	
func new_game():#called upon each new game start
	#reset variables
	score = 0 #set score back to 0 for the new game
	show_score() #displays score even before game start
	can_score_good = true # Reset flag
	can_score_perfect = true # Reset flag
	game_running = false #prevent game autostarting
	get_tree().paused = false #unpauses game after gameover
	beat_trigger = false
	CRAB_START_POS = Vector2i((screen_size.x/4), 485) # Set crab start position at 1/4th of the screen x width
	CAM_START_POS = get_window().size/2 #set camera deadcenter of the gamewindow size
	
	#To reset all the nodes back to the start
	$Crab.position = CRAB_START_POS #reset crab to starting position
	#$Crab.velocity = Vector2i(0, 0) #Set speed to 0 in both x and y direction.
	$Camera2D.position = CAM_START_POS #reset cam back to start position
	#$Ground.position = Vector2i(0, 0) #reset ground to starting position; center of gamewindow
	#Ground.position might need adjustment if we change cam/gamewindow to viewport instead of default window.
	
	#reset hud
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()
	$HUD.get_node("BonusScoreLabel").hide()
	$HUD.get_node("GoodHitboxLabel").hide()
	$HUD.get_node("PerfectHitboxLabel").hide()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:#if boolean is true from player input, run game.
		$Crab.position.x = ($Conductor.song_position * START_SPEED) + CRAB_START_POS.x
		$Camera2D.position.x = ($Conductor.song_position * START_SPEED) + CAM_START_POS.x
			
		#Display updated score, its updated based on beat in _on
		show_score()
	else:
		if Input.is_action_pressed("Start"):#if game not running wait for player input.
				$Conductor.play()
				game_running = true
				$HUD.get_node("StartLabel").hide()
				
				
	#Check to see in which hitbox we are and add score accordingly
	if inside_good_hitbox && !inside_perfect_hitbox: 
			if Input.is_action_pressed("Jump") && can_score_good:
				can_score_good = false #prevents multiscoring on frames
				can_score_perfect = false #prevents multiscoring on frames
				temporary_label($HUD.get_node("GoodHitboxLabel"), 1.5)
				good_score()
	elif inside_good_hitbox && !inside_perfect_hitbox:
			if Input.is_action_pressed("Down") && can_score_good:
				can_score_good = false #prevents multiscoring on frames
				can_score_perfect = false #prevents multiscoring on frames
				temporary_label($HUD.get_node("GoodHitboxLabel"), 1.5)
				good_score()
	elif inside_perfect_hitbox:
			if Input.is_action_pressed("Jump") && can_score_perfect:
				can_score_perfect = false #prevents multiscoring on frames
				can_score_good = false #prevents multiscoring on frames
				temporary_label($HUD.get_node("PerfectHitboxLabel"), 1.5)
				perfect_score()
	elif inside_perfect_hitbox:
		if Input.is_action_pressed("Down") && can_score_perfect:
				can_score_perfect = false #prevents multiscoring on frames
				can_score_good = false #prevents multiscoring on frames
				temporary_label($HUD.get_node("PerfectHitboxLabel"), 1.5)
				perfect_score()
			
			
func show_score():
	#Get the scorelabel from the hud scene, 
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
	
	
func check_high_score():
	if score > high_score:
		high_score == score
		$HUD.get_node("HighscoreLabel").text = "SCORE: " + str(high_score)
	
func temporary_label(label_node, duration: float):
	label_node.show()
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(label_node.hide.bind())
	
func _on_conductor_beat_in_song(position):
	if Input.is_action_pressed("Jump") || Input.is_action_pressed("Down") && position!=0:#so you cant get bonus on starting game with spacebar
			score +=10
			$HUD.get_node("BonusScoreLabel").show()
			await get_tree().create_timer(1.0).timeout
			$HUD.get_node("BonusScoreLabel").hide()
	score += 1

func game_over():#setup for gameover condition, need collision and player hp to use this
	check_high_score()#puts new highscore on the screen
	get_tree().paused = true
	game_running = false
	$GameOver.show()
	
	
func good_score():
	score += 30
	print_debug(score)
	
func perfect_score():
	score += 50
	print_debug(score)
	
#Functions to check inside which hitbox we are, the hitboxes are split over 2 area shapes.
func _on_arrow_up_good_body_entered(body):
	inside_good_hitbox = true
func _on_arrow_up_good_body_exited(body):
	inside_good_hitbox = false
	can_score_good = true
func _on_arrow_up_perfect_body_entered(body):
	inside_perfect_hitbox = true
func _on_arrow_up_perfect_body_exited(body):
	inside_perfect_hitbox = false
	can_score_perfect = true
func _on_arrow_down_good_body_entered(body):
	inside_good_hitbox = true
func _on_arrow_down_good_body_exited(body):
	inside_good_hitbox = false
	can_score_good = true
func _on_arrow_down_perfect_body_entered(body):
	inside_perfect_hitbox = true
func _on_arrow_down_perfect_body_exited(body):
	inside_perfect_hitbox = false
	can_score_perfect = true
	


func _on_arrow_up_group_1__duplicate_this_for_more_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
