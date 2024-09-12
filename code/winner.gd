extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect/black_screen.play("fade out")
	$do_menu.grab_focus()
	Global.player_alive = false
	$WinSound.play()
	$Panel/score.text = "Your score: "+str(Global.score)
	$Panel/czas.text = "Collected time:"+str(Global.gained_time)+" seconds"
	
	if Input.is_action_just_pressed("kill_game"):
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_do_menu_pressed():
	$press.play()
	await $press.finished
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	#get_tree().reload_current_scene()

func _on_restart_pressed():
	$press.play()
	await $press.finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_do_menu_mouse_entered():
	$hover.play()
func _on_restart_mouse_entered():
	$hover.play()
func _on_do_menu_focus_entered():
	$hover.play()
func _on_restart_focus_entered():
	$hover.play()
