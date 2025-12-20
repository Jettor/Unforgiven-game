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

var knockback_force = 260

var lvl1_playing = false
var lvl2_playing = false
var lvl3_playing = false

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

func _calc_actor_height(body_parts: Array[AnimatedSprite2D]):
	var height: int = 0
	for part in body_parts:
		var frame_texture_name: StringName = part.animation
		var frame_texture_idx: int = part.frame 
		var frame_texture: Texture2D = part.sprite_frames.get_frame_texture(frame_texture_name, frame_texture_idx)
		height += frame_texture.get_size().y
	return height

func _calc_actor_width(body_parts: Array[AnimatedSprite2D]):
	var width: int = 0
	for part in body_parts:
		var frame_texture_name: StringName = part.animation
		var frame_texture_idx: int = part.frame 
		var frame_texture: Texture2D = part.sprite_frames.get_frame_texture(frame_texture_name, frame_texture_idx)
		if frame_texture.get_size().x > width:
			width = frame_texture.get_size().x
	return width

func radtodeg(angle: float) -> float:
	return angle * (180 / PI);

func normalize_movement_direction(dir: Vector2):
	return Vector2(0 if dir.x == 0 else 1 if dir.x > 0 else -1, 0 if dir.y == 0 else 1 if dir.y > 0 else -1)

func abs_angle(angle: float) -> float:
	return abs(angle)

func obtuse_angle(angle: float) -> bool:
	return PI > angle and angle > PI / 2 

func acute_angle(angle: float) -> bool:
	return angle <= PI / 2

func give_up_trigger_angle(angle: float) -> bool:
	var degrees: float = round(radtodeg(angle))
	return degrees >= 45 and degrees <= 90

func node_is_in_groups(node: Node2D, groups: Array[StringName]) -> bool:
	var node_groups = node.get_groups()
	print(node_groups)
	print(groups)
	for group in groups:
		if node_groups.count(group) >= 1:
			return true
	return false
