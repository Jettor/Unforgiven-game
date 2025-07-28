extends Node2D

func _ready():
	$CharacterBody2D/Camera2D.limit_right = 3000
	Global.has_gun = false
	
