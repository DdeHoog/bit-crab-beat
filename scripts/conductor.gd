extends AudioStreamPlayer

@export var bpm := 100
@export var beats_in_measure := 4

#tracking the beat and song position
var song_position = 0.0
var song_position_in_beats = 0
var sec_per_beat = 60.0 / bpm
var last_reported_beat = -1 # Initialize to -1 to ensure first beat is reported.
var beats_before_start = 0
var current_beat_in_measure = 1
var first_beat_reported = false # New flag

var song_duration
var beats_per_sec
var total_beats

#determining how close the event is to the beat
var closest = 0
var time_off_beat = 0.0

signal beat_in_song(position)
signal beat_in_measure(position)

func _ready():
	#calculating beats
	sec_per_beat = 60.0 / bpm
	song_duration = stream.get_length()
	beats_per_sec = bpm / 60.0
	total_beats = beats_per_sec * song_duration

func _physics_process(_delta):
	#calculate in beats where player is in song
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position / sec_per_beat))
		_report_beat()

func _report_beat():
	if last_reported_beat < song_position_in_beats:
		if not first_beat_reported: #check if first beat has been reported.
			emit_signal("beat_in_song", song_position_in_beats)
			emit_signal("beat_in_measure", current_beat_in_measure)
			first_beat_reported = true #set flag to true.
		else:
			#check what the current beat is in measure and update accordingly
			if current_beat_in_measure > beats_in_measure:
				current_beat_in_measure = 1
			emit_signal("beat_in_song", song_position_in_beats)
			#print_debug(song_position_in_beats)
			emit_signal("beat_in_measure", current_beat_in_measure)
		#print(current_beat_in_measure)
		last_reported_beat = song_position_in_beats
		current_beat_in_measure += 1

#starts song but adds an offset if needed to spawn stuff, prob not needed for our game
func play_with_beat_offset(num):
	beats_before_start = num
	$StartTimer.wait_time = sec_per_beat
	$StartTimer.start()

func closest_beat(nth):
	closest = int(round((song_position / sec_per_beat) / nth) * nth)
	time_off_beat = abs(closest * sec_per_beat - song_position)
	return Vector2(closest, time_off_beat)

func play_from_beat(beat):
	play()
	seek(beat * sec_per_beat)

func _on_StartTimer_timeout():
	song_position_in_beats += 1
	if song_position_in_beats < beats_before_start - 1:
		$StartTimer.start()
	elif song_position_in_beats == beats_before_start - 1:
		$StartTimer.wait_time = $StartTimer.wait_time - (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency())
		$StartTimer.start()
	else:
		play()
		$StartTimer.stop()
	_report_beat()
	
	# --- Add this function inside Conductor.gd ---
func reset():
	# Stop playback if it's somehow still going
	stop()

	# Reset all the state tracking variables to their initial values
	song_position = 0.0
	song_position_in_beats = 0
	last_reported_beat = -1 # Reset to -1 to ensure beat 0 is reported
	current_beat_in_measure = 1
	first_beat_reported = false # Reset the flag for the first beat special case

	# Optional: Reset offset timer stuff if you use play_with_beat_offset
	beats_before_start = 0
	if has_node("StartTimer"): # Check if the optional StartTimer node exists
		$StartTimer.stop()

	print_debug("Conductor state reset") # Optional debug message
