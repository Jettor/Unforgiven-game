extends Node2D

func _ready():
	RunManager.curr_floor_number = 1
	if RunManager.curr_staircase_side == "left":
		$CharacterBody2D.global_position = Vector2(98, 231)
		RunManager.curr_staircase_side = ""
	elif RunManager.curr_staircase_side == "right":
		$CharacterBody2D.global_position = Vector2(1500, 231)
		RunManager.curr_staircase_side = ""
	else:
		print("ERROR! Unable to track staircase side!")
		$CharacterBody2D.global_position = Vector2(98, 10) #FOR DEBUGGING PURPOSES
	
	$CharacterBody2D/Camera2D.limit_right = 1620
	$CharacterBody2D/Camera2D/zoom_animation.play("zoom_corridors")
	$CharacterBody2D/Healthbar.visible = false
	$CharacterBody2D/candle_light.visible = false
	Global.has_gun = false

func _on_right_stairs_area_entered(area: Area2D) -> void:
	RunManager.curr_staircase_side = "right"
	if area.name == "Area2D":
		print("entered stairs on the right")

func _on_left_stairs_area_entered(area: Area2D) -> void:
	RunManager.curr_staircase_side = "left"
	if area.name == "Area2D":
		print("entered stairs on the left")

func _on_left_stairs_area_exited(area: Area2D) -> void:
	if area.name == "Area2D":
		print("on the corridor")

func _on_right_stairs_area_exited(area: Area2D) -> void:
	if area.name == "Area2D":
		print("on the corridor")
