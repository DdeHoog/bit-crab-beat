extends Node

#game variables 
var CRAB_START_POS : Vector2i  
var CAM_START_POS : Vector2i  
const START_SPEED : float = 213.34 * 2 #Starting off speed 
const MAX_SPEED : int = 1000 #Define a max speed, incase we increase speed overtime, added limit.
const SPEED_MODIFIER := 50000 #Needed to divide speed to not go giga fast in 2 sec - temp fix, remove later?
const SCORE_MODIFIER := 1000 #Needed to divide the score to keep numbers reasonable - temp fix, remove later.
var speed : int #allows for playerspeed to vary based on lvl/score/time
var screen_size : Vector2i #prep variable for screensize
var score : int #variable to keep track of score
var game_running : bool #boolean to see if game is running or not
var beat_trigger : bool

func new_game():#called upon each new game start
	#reset variables
	score = 0 #set score back to 0 for the new game
	show_score() #displays score even before game start
	game_running = false #prevent game autostarting
	beat_trigger = false
	CRAB_START_POS = Vector2i((screen_size.x/4), 485) # Set crab start position at 1/4th of the screen x width
	CAM_START_POS = get_window().size/2 #set camera deadcenter of the gamewindow size
	
	#To reset all the nodes back to the start
	$Crab.position = CRAB_START_POS #reset crab to starting position
	$Crab.velocity = Vector2i(0, 0) #Set speed to 0 in both x and y direction.
	$Camera2D.position = CAM_START_POS #reset cam back to start position
	$Ground.position = Vector2i(0, 0) #reset ground to starting position; center of gamewindow
	#Ground.position might need adjustment if we change cam/gamewindow to viewport instead of default window.
	

	
	#reset hud
	$HUD.get_node("StartLabel").show()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size #get the window size, for ground scrolling
	new_game()#init new game


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:#if boolean is true from player input, run game.
		$Crab.position.x = ($Conductor.song_position * START_SPEED) + CRAB_START_POS.x
		$Camera2D.position.x = ($Conductor.song_position * START_SPEED) + CAM_START_POS.x
		#speed = START_SPEED + score / SPEED_MODIFIER #startspeed + score, increases speed overtime
		#if speed > MAX_SPEED: #prevent speed from rising indefinitely
			#speed = MAX_SPEED
		
		
		#Adding speed value to x-axis of camera and crab to move them along, per frame/delta
		#$Crab.position.x += speed * delta #Had to add delta to speed, at 180fps speed would go insane.
		#$Camera2D.position.x += speed * delta
			
		#Updating score
		show_score()
		#Adjust score to take into account destroyed obstacles and time spent running?
			
		#If camera position about to overtake ground, shift ground on x-axis at width of screen.
		#This basically puts the ground node at the right end of the current ground, which just loops it
		#if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			#$Ground.position.x += screen_size.x
	else:
		if Input.is_action_pressed("ui_accept"):#if game not running wait for player input.
				$Conductor.play()
				game_running = true
				$HUD.get_node("StartLabel").hide()
				
	
		
func show_score():
	#Get the scorelabel from the hud scene, 
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
	


func _on_conductor_beat_in_song(position: Variant) -> void:
	score += 1
