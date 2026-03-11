extends Sprite2D

@export var player = Node2D

func _process(_float)->void:
	global_position = player.global_position
