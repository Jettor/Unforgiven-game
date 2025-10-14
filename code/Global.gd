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
var healthp: int = 100 #player hp
var player_alive = true;
var enemy_dead = false
var death_sound: AudioStreamPlayer
var best_score = 0
var bullet_name = ""
var combo_counter = 0

var bullet_damage = 10
var melee_damage = 2

#var gun_melee_damage = 5
var best_kill_count = 0
var best_gained_time = 0
var lvl_id = 0
var has_gun = true
var can_move = true

var knockback_force = 260

var lvl1_playing = false
var lvl2_playing = false
var lvl3_playing = false

### DIALOGUE & QUEST ###
var player: Node = null

var npc_trust_lvl: Dictionary = {
	"npc_1":0 #yaegashi
}

func _ready():
	death_sound = AudioStreamPlayer.new()
	add_child(death_sound)
	death_sound.stream = preload("res://music/SFX/enemy_damage.mp3")

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
		
func add_trust(npc_id: String, amount: int) -> void:
	print(npc_id," TRUST LEVEL BEFORE: ",npc_trust_lvl[npc_id])
	if npc_id in  npc_trust_lvl:
		npc_trust_lvl[npc_id] += amount
	else:
		npc_trust_lvl[npc_id] = amount
	print(npc_id," TRUST LEVEL AFTER: ",npc_trust_lvl[npc_id])
