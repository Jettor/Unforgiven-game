extends Node2D

func _ready():
	
	$CharacterBody2D/Camera2D.limit_right = 3000
	$CharacterBody2D/Camera2D/zoom_animation.play("zoom_corridors")
	$CharacterBody2D/Healthbar.visible = false
	Global.has_gun = false
	
	
	
