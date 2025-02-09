extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")
var penta_scene = preload("res://scenes/pentagram.tscn")
var rngX = RandomNumberGenerator.new()
var rngY = RandomNumberGenerator.new()

func _ready():
	Global.lvl2_playing = true
	Global.time = 100 
	Global.kill_count = 0
	Global.score = 0
	Global.x2 = false
	Global.player_alive = true
	Global.score_reward = 100
	Global.gained_time = 0
	Global.speed_plus = 95
	$CharacterBody2D/Camera2D/zoom_animation.play("zoom_out")
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CanvasL/Panel/punkty.text = "SCORE:" + str(Global.score)

func _on_finish_area_entered(area):
	print("ENTERED!!")
	Global.lvl1_playing = false
	$CharacterBody2D/Camera2D/zoom_animation.play("limit_break")
	$CharacterBody2D.hide()
	$lvl_finished.start()
	
func _on_timer_timeout():
	for i in range(4):
		var position = Vector2(rngX.randf_range(77, 1843), rngY.randf_range(88, 850))
		while position.distance_to($CharacterBody2D.position) < 300:
			position = Vector2(rngX.randf_range(77, 1843), rngY.randf_range(88, 850))
		spawn_enemy(position)
		await get_tree().create_timer(1.5).timeout
	
func spawn_enemy(position: Vector2):
	var pentagram = penta_scene.instantiate()
	var enemy = enemy_scene.instantiate()
	pentagram.global_position = position
	enemy.global_position = position
	add_child(pentagram)
	pentagram.get_node("pentagram_animation").play("handle_penta")
	await get_tree().create_timer(0.8).timeout
	add_child(enemy)
	print("Enemy spawned at:", position)
	await get_tree().create_timer(0.5).timeout
	pentagram.queue_free()
	Global.speed_plus += Global.normal_addition
	
func _stop() -> void: 
	set_process(false)
	
func _on_lvl_finished_timeout():
	_stop()
	get_tree().change_scene_to_file("res://scenes/winner.tscn")
