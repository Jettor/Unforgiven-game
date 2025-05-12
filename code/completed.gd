extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	print(">>WIN<<")
	Global.load_data()
	$Panel2/Next.grab_focus()
	$WinSound2.play()
	$ColorRect2/black_screen.play("fade out")
	
	# Display current match stats
	$Panel2/current_stats/score.text = "Score: " + str(Global.score)
	$Panel2/current_stats/czas.text = "Gained time: " + str(Global.gained_time) + " sec"
	$Panel2/current_stats/kill_count.text = "Kill count: " + str(Global.kill_count)
	var new_best = false
	
	if Global.score > Global.best_score:
		Global.best_score = Global.score
		new_best = true
	
	if Global.gained_time > Global.best_gained_time:
		Global.best_gained_time = Global.gained_time
		new_best = true
	
	if Global.kill_count > Global.best_kill_count:
		Global.best_kill_count = Global.kill_count
		new_best = true
	
	# Save the new best stats if any were updated
	if new_best:
		Global.save()
		Global.load_data()  # Reload the saved data to make sure it's updated
	
	# Display best stats
	$Panel2/best_stats/score.text = "Score: " + str(Global.best_score)
	$Panel2/best_stats/czas.text = "Gained time: " + str(Global.best_gained_time) + " sec"
	$Panel2/best_stats/kill_count.text = "Kill count: " + str(Global.best_kill_count)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("kill_game"):
		get_tree().quit()

func _on_button_pressed(): #MENU
	$press.play()
	await $press.finished
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	#get_tree().reload_current_scene()

func _on_restart_pressed(): #RESTART
	$press.play()
	await $press.finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_next_pressed(): #CREDITS
	$press.play()
	await $press.finished
	get_tree().change_scene_to_file("res://scenes/creators.tscn")

func _on_button_mouse_entered():
	$hover.play()
func _on_restart_mouse_entered():
	$hover.play()
func _on_button_focus_entered():
	$hover.play()
func _on_restart_focus_entered():
	$hover.play()
func _on_next_focus_entered():
	$hover.play()
func _on_next_mouse_entered():
	$hover.play()
