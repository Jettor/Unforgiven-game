extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	print(">>LOST<<")
	Global.load_data()
	$Panel/Button.grab_focus()
	$LoseSound.play()
	$ColorRect/black_screen.play("fade out")
	
	# Display current match stats
	$Panel/current_stats/score.text = "Score: " + str(Global.score)
	$Panel/current_stats/czas.text = "Saved time: " + str(Global.gained_time) + " sec"
	$Panel/current_stats/kill_count.text = "Kill count: " + str(Global.kill_count)
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
	$Panel/best_stats/score.text = "Score: " + str(Global.best_score)
	$Panel/best_stats/czas.text = "Saved time: " + str(Global.best_gained_time) + " sec"
	$Panel/best_stats/kill_count.text = "Kill count: " + str(Global.best_kill_count)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("kill_game"):
		get_tree().quit()

func _on_button_pressed():
	$press.play()
	await $press.finished
	get_tree().change_scene_to_file("res://scenes/UI_scenes/menu.tscn")

func _on_restart_pressed():
	$press.play()
	await $press.finished
	get_tree().change_scene_to_file("res://scenes/Locations/main.tscn")

func _on_button_mouse_entered():
	$hover.play()
func _on_restart_mouse_entered():
	$hover.play()
func _on_button_focus_entered():
	$hover.play()
func _on_restart_focus_entered():
	$hover.play()
#When I win the game, then loose and try to win again, WIN collision shape doesn't work
