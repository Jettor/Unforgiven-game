extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.grab_focus()
	$LoseSound.play()
	$Panel/score.text = "Your score: "+str(Global.score)
	$Panel/czas.text = "Collected time:"+str(Global.gained_time)+" seconds"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("kill_game"):
		get_tree().quit()

func _on_button_pressed():
	$press.play()
	await $press.finished
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_restart_pressed():
	$press.play()
	await $press.finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_button_mouse_entered():
	$hover.play()
func _on_restart_mouse_entered():
	$hover.play()
func _on_button_focus_entered():
	$hover.play()
func _on_restart_focus_entered():
	$hover.play()
