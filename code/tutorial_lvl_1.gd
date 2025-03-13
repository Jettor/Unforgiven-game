extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("layer_holder/ground/CharacterBody2D")
	var healthbar = get_node("layer_holder/ground/CharacterBody2D/Healthbar")
	player.set_jump(1)
	player.set_normalSpeed(230)
	healthbar.hide()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
