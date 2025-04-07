extends Node


#game variables 
const START_SPEED : float = 213.34 * 2 #Starting off speed 
const MAX_SPEED : int = 1000 #Define a max speed, incase we increase speed overtime, added limit.
const SPEED_MODIFIER : int = 50000 #Needed to divide speed to not go giga fast in 2 sec - temp fix, remove later?
const SCORE_MODIFIER : int = 1000 #Needed to divide the score to keep numbers reasonable - temp fix, remove later.
var CRAB_START_POS : Vector2i  
var CAM_START_POS : Vector2i  
var high_score : int
var height : int = 1152
var width : int = 832
var speed : int #allows for playerspeed to vary based on lvl/score/time
var screen_size : Vector2i#prep variable for screensize
var score : int #variable to keep track of score
var game_running : bool #boolean to see if game is running or not
var inside_good_hitbox : bool = false #Vars to check which hitbox the player box is inside of
var inside_perfect_hitbox : bool = false
var can_score_good : bool = true
var can_score_perfect : bool = true
var frames : int = 0
var total_beat : int= 1
var max_beat : int = 130

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size.x = height #get the window size
	#frames = get_monitor(Performance.TIME_FPS)
	main_menu()
	
func main_menu():
	$HUD.hide()
	$Crab.hide()
	$GameOver.hide()
	$HUD/StartLabel.hide()
	$HUD/BeatIndicator.hide()
	$Bg.hide()
	$Ground.hide()
	check_high_score()
	get_tree().paused = true
	game_running = false
	$MainMenu.show()
	$MainMenu.get_node("StartButton").pressed.connect(new_game)#Start game
	
	
func game_over():
	check_high_score()#puts new highscore on the screen
	get_tree().paused = true
	game_running = false
	$Conductor.stop()
	$HUD/BeatIndicator.hide()
	$GameOver.show()
	total_beat = 1
	$GameOver.get_node("MenuButton").pressed.connect(main_menu)#Menu trigger
	
func new_game():
	#Reset variables
	score = 0 #set score back to 0 for the new game
	show_score() #displays score even before game start
	can_score_good = true # Reset flag
	can_score_perfect = true # Reset flag
	game_running = false #prevent game autostarting
	get_tree().paused = false #unpauses game after gameover or gamestart
	
	# --- Call the Conductor's reset function ---
	if $Conductor: # Good practice to check if node exists
		$Conductor.reset()
	else:
		printerr("Main: Conductor node not found during new_game!")
		
	if $TimestickManager: # Replace with actual node path/name
		$TimeStickManager.reset()
	
	#To reset player & camera
	CRAB_START_POS = Vector2i((screen_size.x/4), 485) # Set crab start position at 1/4th of the screen x width
	CAM_START_POS = Vector2i(height, width)/2 #set camera deadcenter of the gamewindow size
	$Crab.position = CRAB_START_POS #reset crab to starting position
	$Camera2D.position = CAM_START_POS #reset cam back to start position
	
	#reset hud
	$MainMenu.hide()
	$GameOver.hide()
	$Bg.show()
	$Ground.show()
	$HUD.show()
	$HUD.get_node("StartLabel").show()
	$Crab.show()
	$HUD.get_node("BonusScoreLabel").hide()
	$HUD.get_node("GoodHitboxLabel").hide()
	$HUD.get_node("PerfectHitboxLabel").hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:#if boolean is true from player input, run game.
		$Crab.position.x = ($Conductor.song_position * START_SPEED) + CRAB_START_POS.x
		$Camera2D.position.x = ($Conductor.song_position * START_SPEED) + CAM_START_POS.x	
		show_score()
	else:
		if Input.is_action_pressed("Start"):#if game not running wait for player input.
				$HUD/BeatIndicator.show()
				$Conductor.play_from_beat(95)
				#$HUD.get_node("BeatIndicator").play("Beat")
				#$HUD.get_node("BeatIndicator").SetAnimationSpeed("Beat", 1.76)
				game_running = true
				$HUD.get_node("StartLabel").hide()	
	
	#Check to see in which hitbox we are and add score accordingly
	if inside_good_hitbox && !inside_perfect_hitbox: 
			if Input.is_action_pressed("Jump") && can_score_good:
				can_score_good = false #prevents multiscoring on frames
				can_score_perfect = false #prevents multiscoring on frames
				temporary_label($HUD.get_node("GoodHitboxLabel"), 1.0)
				good_score()
	elif inside_good_hitbox && !inside_perfect_hitbox:
			if Input.is_action_pressed("Down") && can_score_good:
				can_score_good = false #prevents multiscoring on frames
				can_score_perfect = false #prevents multiscoring on frames
				temporary_label($HUD.get_node("GoodHitboxLabel"), 1.0)
				good_score()
	elif inside_perfect_hitbox:
			if Input.is_action_pressed("Jump") && can_score_perfect:
				can_score_perfect = false #prevents multiscoring on frames
				can_score_good = false #prevents multiscoring on frames
				temporary_label($HUD.get_node("PerfectHitboxLabel"), 1.0)
				perfect_score()
	elif inside_perfect_hitbox:
		if Input.is_action_pressed("Down") && can_score_perfect:
				can_score_perfect = false #prevents multiscoring on frames
				can_score_good = false #prevents multiscoring on frames
				temporary_label($HUD.get_node("PerfectHitboxLabel"), 1.0)
				perfect_score()
	
	if total_beat >= max_beat:
		game_over()
	
func show_score():
	#Get the scorelabel from the hud scene, 
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
	
func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighscoreLabel").text = "SCORE: " + str(high_score)
		
func good_score():
	score += 30
	#print_debug(score)
	
func perfect_score():
	score += 50
	#print_debug(score)
	
func temporary_label(label_node, duration: float):
	label_node.show()
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(label_node.hide.bind())
	
func _on_conductor_beat_in_song(position):
	if Input.is_action_pressed("Jump") || Input.is_action_pressed("Down") && position!=0:#so you cant get bonus on starting game with spacebar
			score +=10
			temporary_label($HUD.get_node("BonusScoreLabel"), 1.5)
	score += 1
	total_beat += 1
	
	
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
