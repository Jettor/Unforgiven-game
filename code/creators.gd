extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$song.play()
	$moveClouds.play("move_clouds")
	$Opener.play("opening")
	$Title/AnimationPlayer.play("up")
	$BoxContainer/AnimatedSprite2D.play("new_animation")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("kill_game"):
		get_tree().quit()

func _on_button_pressed():
	$press.play()
	await $press.finished
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_button_mouse_entered():
	$hover.play()
func _on_button_focus_entered():
	$hover.play()


func _on_cutscene_end_timeout():
	$Title/AnimationPlayer.play("hide_panel")
	$Button/Button_animation.play("show_btn")
	$Title/AnimationPlayer.play("hide_pic")
func _on_button_animation_animation_finished(anim_name):
	$Button.grab_focus()
