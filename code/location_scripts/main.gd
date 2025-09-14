extends Node

var enemy_scene = preload("res://scenes/Entities/enemy.tscn")
var penta_scene = preload("res://scenes/Visual_effects/pentagram.tscn")
var rngX = RandomNumberGenerator.new()
var rngY = RandomNumberGenerator.new()
@onready var player = $CharacterBody2D
@onready var zoom_animation = $CharacterBody2D/Camera2D/zoom_animation

func _ready():
	#player.position = Vector2(904, -78) #ERROR
	#print(player.global_position)
	Engine.time_scale = 1.0
	Global.lvl1_playing = true
	Global.x2 = false
	Global.score_reward = 100
	$fall.play()
	Global.player_alive = true
	zoom_animation.play("zoom_out")
	Global.score = 0
	$Timer.start()
	Global.lvl_id = 1
	Global.time = 180
	Global.kill_count = 0
	Global.gained_time = 0
	Global.speed_plus = 95
	await get_tree().create_timer(3).timeout
	player.hint.give_hint("Use double jump")
	
	#await get_tree().create_timer(0.1).timeout
	#print(player.global_position)    FOR SOME REASON SPAWNS AT (1006.924, -70.37778)

func _physics_process(_delta):
	$CanvasL/Panel/punkty.text = "SCORE:" + str(Global.score)
	if Global.player_alive == false:
		$finish/shape.disabled = true
	if !Global.player_alive:
		$theme.stop()

func _on_timer_timeout():         #SPAWNING ENEMIES
	for i in range(4):
		var position = Vector2(rngX.randf_range(77, 1843), rngY.randf_range(88, 850))
		while position.distance_to(player.position) < 300:
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

func _on_finish_area_entered(area):
	print("ENTERED!!")
	Global.lvl1_playing = false
	zoom_animation.play("limit_break")
	player.hide()
	$lvl_finished.start()

func _on_lvl_finished_timeout():
	_stop()
	get_tree().change_scene_to_file("res://scenes/UI_scenes/winner.tscn")
