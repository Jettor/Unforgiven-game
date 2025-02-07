extends Node

const path = "user://stats.save"

enum INPUT_SCHEMES {KEYBOARD, GAMEPAD, TOUCHSCREEN}
static var INPUT_SCHEME: INPUT_SCHEMES = INPUT_SCHEMES.GAMEPAD #Controller support doesn't work

var kill_count = 0
var gained_time = 0
var time: float = 0
var score = 0
var x2
var score_reward = 100
var normal_addition = 1.2
var speed_plus = 180
var healthp = 100
var player_alive = true;
var enemy_dead = false
var death_sound: AudioStreamPlayer
var best_score = 0
var best_kill_count = 0
var best_gained_time = 0

func _ready():
	death_sound = AudioStreamPlayer.new()
	add_child(death_sound)
	death_sound.stream = preload("res://music/enemy_damage.mp3")

func save():
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(score)
	file.store_var(kill_count)
	file.store_var(gained_time)
	print("DATA SAVED!")
	
func load_data():
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		best_score = file.get_var(score)
		best_kill_count = file.get_var(kill_count)
		best_gained_time = file.get_var(gained_time)
		print("DATA LOADED!")
	else:
		print("ERROR! No data saved!")
	
func _on_enemy_died():
	kill_count += 1 
	print("kills: "+str(kill_count))
	if death_sound:
		death_sound.pitch_scale = randf_range(0.8, 1.2)
		death_sound.play()
