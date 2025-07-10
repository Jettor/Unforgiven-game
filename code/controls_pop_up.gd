extends Control
# Called when the node enters the scene tree for the first time.
func _ready():
	$fader.play("fade out")
	$bg_music.play()
	$no_image_text/Writer.play("text show")
	$start_text_timer.start()
	$subtimer1.start()
	
func _on_subtimer_1_timeout():
	$fader.play("fade in")
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/Locations/main.tscn")
	if Input.is_action_just_pressed("kill_game"):
		get_tree().quit()
	
func _on_start_text_timer_timeout(): # First text timer
	$no_image_text.hide()
	$fader.play("fade out")
	
	$cutscene0.show()
	$cutscene0.play("play_cutscene0")
	$text0.show()
	$text0/Writer.play("text show")
	$cutscene0_timer.start()
	$subtimer1.start()
	
func _on_cutscene_0_timer_timeout():  # Cutscene0 timer
	$fader.play("fade out")
	$cutscene0.hide()
	$text0.hide()
	
	$cutscene1.show()
	$text1.show()
	$cutscene1.play("play_cutscene1")
	$text1/Writer.play("text show")
	$cutscene1_timer.start()
	$subtimer1.start()
	
func _on_end_timer_timeout(): # Cutscene1 timer
	$fader.play("fade out")
	$cutscene1.hide()
	$text1.hide()
	
	$cutscene2.show()
	$text2.show()
	$cutscene2.play("play_cutscene2")
	$text2/Writer.play("text show")
	$cutscene2_timer.start()
	$subtimer1.start()

func _on_cutscene_2_timer_timeout(): # Cutscene2 timer
	$fader.play("fade out")
	$cutscene2.hide()
	$text2.hide()
	
	$cutscene3.show()
	$cutscene3.play("play_cutscene3")
	$text3.show()
	$text3/Writer.play("text show")
	$cutscene3_timer.start()
	$subtimer1.start()

func _on_cutscene_3_timer_timeout(): # Cutscene3 timer
	$fader.play("fade out")
	$cutscene3.hide()
	$text3.hide()
	
	$cutscene4.show()
	$cutscene4.play("play_cutscene4")
	$text4.show()
	$text4/Writer.play("text show")
	$cutscene4_timer.start()
	$subtimer1.start()

func _on_cutscene_4_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/Locations/main.tscn")
