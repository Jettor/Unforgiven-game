extends Node2D
@onready var mc = $CharacterBody2D

func _ready():
	mc.zoom_animator.play("zoom_staircase")
	mc.healthbar.hide()
	print("current staircase side: ",RunManager.curr_staircase_side)
	if RunManager.curr_floor_number == 1:   #CHECK WHICH FLOOR PLAYER WAS ON BEFORE SPAWNING THEM ON CORRECT ONE
		RunManager.curr_floor_number = null
		mc.global_position = Vector2(128, 380)
	elif RunManager.curr_floor_number == 2:
		RunManager.curr_floor_number = null
		mc.global_position = Vector2(128, 223)
	elif RunManager.curr_floor_number == 3:
		RunManager.curr_floor_number = null
		mc.global_position = Vector2(218, 64)
