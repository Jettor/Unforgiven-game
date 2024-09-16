extends Node

var enemy_scene = preload("res://scenes/enemy.tscn")
var rngX = RandomNumberGenerator.new()
var rngY = RandomNumberGenerator.new()

func _ready():
	$finish/shape.disabled = false
	Global.x2 = false
	Global.score_reward = 100
	$fall.play()
	Global.score = 0
	$Timer.start()
	Global.time = 10
	Global.gained_time = 0
	Global.kill_count = 0
	Global.speed_plus = 95
	$Camera2D/AnimationPlayer.play("shake") #NAPRAWIĆ!

func _physics_process(delta):
	$CanvasL/Panel/punkty.text = "SCORE:" + str(Global.score)
	if(!Global.player_alive):
		$finish/shape.disabled = true

func _on_timer_timeout():         #SPAWNING ENEMIES
	for i in range(4):
		var position = Vector2(rngX.randf_range(77, 1843), rngY.randf_range(88, 850))
		
		while position.distance_to($CharacterBody2D.position) < 200:
			position = Vector2(rngX.randf_range(77, 1843), rngY.randf_range(88, 850))
		spawn_enemy(position)
		await get_tree().create_timer(1.5).timeout

func spawn_enemy(position: Vector2):
	var enemy = enemy_scene.instantiate()
	enemy.global_position = position
	add_child(enemy)
	print("Enemy spawned at:", position)
	Global.speed_plus += Global.normal_addition

func _stop() -> void:
	set_process(false)

func _on_finish_area_entered(area):
	_stop()
	get_tree().change_scene_to_file("res://scenes/winner.tscn")
