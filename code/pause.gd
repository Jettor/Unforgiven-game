extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	testPAUSE()

func resume():
	$".".hide()
	get_tree().paused = false
func pause():
	$".".show()
	get_tree().paused = true
	$resume.grab_focus()
	
func testPAUSE():
	if (Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("ui_cancel")) and get_tree().paused == false:
		pause()
	elif (Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("ui_cancel")) and get_tree().paused == true:
		resume()

func _on_resume_pressed():
	$press.play()
	await $press.finished
	resume()

func _on_menu_pressed():
	$press.play()
	await $press.finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_restart_pressed():
	$press.play()
	await $press.finished
	resume()
	get_tree().reload_current_scene()
	
func _on_restart_mouse_entered():
	$hover.play()
func _on_menu_mouse_entered():
	$hover.play()
func _on_resume_mouse_entered():
	$hover.play()
func _on_restart_focus_entered():
	$hover.play()
func _on_menu_focus_entered():
	$hover.play()
func _on_resume_focus_entered():
	$hover.play()
