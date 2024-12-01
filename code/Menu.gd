extends Control

func _ready():
	$CanvasLayer/moving/Control/GRAJ.grab_focus()
	$logo_wave.play("title_animation");
	$CanvasLayer/transition.play("fade_in");
	$CanvasLayer/moving.play("UI_appear")
	
func _physics_process(delta):
	if Input.is_action_just_pressed("kill_game"):
		get_tree().quit()

func _on_graj_pressed():
	Engine.time_scale = 1
	$press.play()
	await $press.finished
	get_tree().change_scene_to_file("res://scenes/controls_pop_up.tscn")
	

func _on_wyjdz_pressed():
	$press.play()
	await $press.finished
	get_tree().quit()
	
func _on_tworcy_pressed():
	$press.play()
	await $press.finished
	get_tree().change_scene_to_file("res://scenes/creators.tscn")

func _on_graj_mouse_entered():
	$hover.play()
func _on_tworcy_mouse_entered():
	$hover.play()
func _on_wyjdz_mouse_entered():
	$hover.play()
	
func _on_graj_focus_entered():
	$hover.play()
func _on_tworcy_focus_entered():
	$hover.play()
func _on_wyjdz_focus_entered():
	$hover.play()
