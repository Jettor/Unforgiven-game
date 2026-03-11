extends Node2D

func _on_area_2d_area_entered(_area: Area2D) -> void:
	print("area entered")
	$StaticBody_stairs.collision_layer = 0

func _on_area_2d_area_exited(_area: Area2D) -> void:
	print("area exited")
	$StaticBody_stairs.collision_layer = 1

func process():
	pass
