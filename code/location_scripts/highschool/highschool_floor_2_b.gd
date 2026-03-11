extends Node2D

func _ready():
	RunManager.curr_floor_number = 2
	$CharacterBody2D/Camera2D.limit_right = 1620
	$CharacterBody2D/Camera2D/zoom_animation.play("zoom_corridors")
	$CharacterBody2D/Healthbar.visible = false
	$CharacterBody2D/candle_light.visible = false
	Global.has_gun = false
