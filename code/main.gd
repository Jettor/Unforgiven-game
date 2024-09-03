extends Node

var enemy_scene = preload("res://scenes/enemy.tscn")

func _ready():
	$fall.play()
	Global.score = 0
	$Timer.start()
	Global.time = 100
	Global.gained_time = 0
	Global.speed_plus = 95
	$Camera2D/AnimationPlayer.play("shake")

func _physics_process(delta):
	$CanvasL/Panel/punkty.text = "SCORE:" + str(Global.score)
	
func _on_timer_timeout():
	var position1 = Vector2(124, 842)
	var position2 = Vector2(1550, 850)
	var position3 = Vector2(1567, 236)
	var position4 = Vector2(156, 155)
	
	spawn_enemies(position1)
	await get_tree().create_timer(1.5).timeout
	spawn_enemies2(position2)
	await get_tree().create_timer(3).timeout
	spawn_enemies3(position3)
	await get_tree().create_timer(2.5).timeout
	spawn_enemies4(position4)

func spawn_enemies(position1: Vector2):
	var enemy = enemy_scene.instantiate()
	enemy.global_position = position1
	add_child(enemy)
	print("Enemy spawned at:", position1)
	Global.speed_plus += Global.normal_addition
	
func spawn_enemies2(position2: Vector2):
	var enemy2 = enemy_scene.instantiate()
	enemy2.global_position = position2
	add_child(enemy2)
	print("Enemy spawned at:", position2)
	Global.speed_plus += Global.normal_addition
	
func spawn_enemies3(position3: Vector2):
	var enemy3 = enemy_scene.instantiate()
	enemy3.global_position = position3
	add_child(enemy3)
	print("Enemy spawned at:", position3)
	Global.speed_plus += Global.normal_addition
	
func spawn_enemies4(position4: Vector2):
	var enemy4 = enemy_scene.instantiate()
	enemy4.global_position = position4
	add_child(enemy4)
	print("Enemy spawned at:", position4)
	Global.speed_plus += Global.normal_addition

func _stop() -> void:
	set_process(false)

func _on_finish_area_entered(area):
	_stop()
	get_tree().change_scene_to_file("res://scenes/winner.tscn")
