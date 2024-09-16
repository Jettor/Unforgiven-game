extends Node

const path = "user://stats.save"

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

var best_score = 0
var best_kill_count = 0
var best_gained_time = 0

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
