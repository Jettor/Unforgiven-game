extends Node

var enemy_scene = preload("res://scenes/Entities/enemy.tscn")
var fsm_enemy_scene = preload("res://scenes/Entities/fsm_enemy.tscn")
var penta_scene = preload("res://scenes/pentagram.tscn")
var rngX = RandomNumberGenerator.new()
var rngY = RandomNumberGenerator.new()

@onready var spawners = [ $EntitySpawners/spawn1, $EntitySpawners/spawn2, $EntitySpawners/spawn3, $EntitySpawners/spawn4, $EntitySpawners/spawn5, $EntitySpawners/spawn6 ]

func _ready():
	Global.lvl1_playing = true
	Global.x2 = false
	Global.score_reward = 100
	$fall.play()
	Global.player_alive = true
	$CharacterBody2D/Camera2D/zoom_animation.play("zoom_out")
	Global.score = 0
	$Timer.start()
	Global.lvl_id = 1
	Global.time = 180
	Global.kill_count = 0
	Global.gained_time = 0
	Global.speed_plus = 95
	var position = Vector2(rngX.randf_range(77, 1843), rngY.randf_range(88, 850))
	while position.distance_to($CharacterBody2D.position) < 300:
		position = Vector2(rngX.randf_range(77, 1843), rngY.randf_range(88, 850))
	spawn_enemy(position)

func _physics_process(_delta):
	$CanvasL/Panel/punkty.text = "SCORE:" + str(Global.score)
	if Global.player_alive == false:
		$finish/shape.disabled = true
	if !Global.player_alive:
		$theme.stop()

func _on_timer_timeout():         #SPAWNING ENEMIES IS DISABLED HERE
	pass


func spawn_enemy(position: Vector2):
	print("len(spawners) = ", len(spawners))
	var spawner_id: int = randi_range(0, len(spawners) - 1)
	print("use spawner ", spawner_id)
	var new_entity = await spawners[spawner_id].spawn(fsm_enemy_scene, penta_scene, "pentagram_animation", "handle_penta")
	add_child(new_entity)

func _stop() -> void: 
	set_process(false)

func _on_finish_area_entered(area):
	print("ENTERED!!")
	Global.lvl1_playing = false
	$CharacterBody2D/Camera2D/zoom_animation.play("limit_break")
	$CharacterBody2D.hide()
	$lvl_finished.start()

func _on_lvl_finished_timeout():
	_stop()
	get_tree().change_scene_to_file("res://scenes/UI_scenes/winner.tscn")
