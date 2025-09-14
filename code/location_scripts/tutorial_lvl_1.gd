extends Node2D

var check = false
@onready var hint = $hint_message

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("layer_holder/ground/CharacterBody2D")
	var healthbar = get_node("layer_holder/ground/CharacterBody2D/Healthbar")
	player.set_jump(1)
	player.set_normalSpeed(230)
	healthbar.hide()
	$CanvasLayer/fader.play("fade_out")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_area_entered(area):
	if(!check):
		$layer_holder/crow_anim/crow.play("default")
		$layer_holder/crow_anim/AnimationPlayer.play("fly")
		$the_crow.play()
		$layer_holder/crow_leaves.emitting = true
		check = true

func _on_first_hint_timeout():
	$layer_holder/ground/CharacterBody2D/Hint_message.give_hint("Use arrows or\nW A D to move")
