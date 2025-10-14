class_name PlayerInput

var player: CharacterBody2D

func process_input():
	if Input.is_action_just_pressed("fire") and player.can_fire and player.state == player.PlayerState.IDLE: # SHOOTING -> C
		if Global.has_gun && player.can_fire:
			player.state = player.PlayerState.SHOOTING
			player.punch_push_velocity = 0.0
			player.shoot_timer.start(0.5)
			player.can_fire = false
			player.is_attacking = true
			player.shoot_sound.play()
			player.sprite_top.play("shoot")
			var bullet_instance = player.bullet.instantiate()
			bullet_instance.global_position = player.marker_2d.global_position
			bullet_instance.face_direction = player.face_direction
			player.get_parent().add_child(bullet_instance)
			print("bullet shot")
		else:
			return
	if Input.is_action_just_pressed("_ui_quest_menu"):
		player.quest_manager.toggle_log_visibility()
	if Input.is_action_just_pressed("instant_death"): 
		player.death()
		
	if Input.is_action_just_released("ui_accept") and player.velocity.y < 0:
		player.velocity.y = player.JUMP_VELOCITY /4
		
	if Input.is_action_just_pressed("ui_accept") and player.jump_count < player.jump_max: # Handle jump
		player.velocity.y = player.JUMP_VELOCITY
		player.jump_count += 1

	
	if Input.is_action_just_pressed("kill_game"): # KILL GAME (shift + esc)
		player.get_tree().quit()
		
	# Handle dash input
	if Input.is_action_just_pressed("dash"):
		player.dash.start_dash(player.dash_length)
		player.can_take_damage = false
		await player.get_tree().create_timer(player.dash_length).timeout
		player.can_take_damage = true
	player.move_and_slide()
	
	if Input.is_action_just_pressed("melee") and player.can_punch and player.state == player.PlayerState.IDLE:
		player.state = player.PlayerState.MELEE
		player.punch_push_velocity = 0.0
		player.is_attacking = true
		player.can_fire = false
		player.can_punch = false
		player.punch_queued = false
		
		if Global.has_gun:
			Global.combo_counter = 0
			player.sprite_top.play("melee_with_gun")
			player.punch_hurtbox.disabled = false
			play_punch_sound()
			await player.get_tree().create_timer(0.4).timeout
			player.visual_handler.attack_animation_handler("melee_with_gun")
		else:
			Global.combo_counter = 1
			player.can_take_damage = false
			player.sprite_top.play("punch1")        #FIRST PUNCH
			player.sprite_bottom.play("punch_stance1")
			enable_hurtbox()
			play_punch_sound()
			if player.is_moving:
				temporary_boost(200) 
				find_punch_push_direction()
			player.combo_timer.start(0.5)
			
			await player.get_tree().create_timer(0.1).timeout
			while player.combo_timer.time_left > 0.0:     #wait for queued input
				await player.get_tree().process_frame
				if Input.is_action_just_pressed("melee"):
					#print("queued punch")
					player.punch_queued = true
					break
					
			if player.punch_queued and Global.combo_counter == 1:
				play_punch2()
				await player.get_tree().create_timer(0.1).timeout
				while player.combo_timer.time_left > 0.0:     #wait for queued input
					await player.get_tree().process_frame
					if Input.is_action_just_pressed("melee"):
						#print("queued another punch")
						player.punch_queued = true
						break
						
			if player.punch_queued and Global.combo_counter == 2:
				play_kick1()
			
func play_punch2():
	Global.combo_counter = 2
	player.punch_queued = false
	player.combo_timer.stop()
	player.combo_timer.wait_time = player.combo_timer.time_left + 0.5
	player.combo_timer.start()
	player.sprite_top.play("punch2")
	player.sprite_bottom.play("punch_stance2")
	enable_hurtbox()
	play_punch_sound()
	if player.is_moving:
		temporary_boost(300)
		find_punch_push_direction()
	player.combo_timer.start()
	
func play_kick1():
	Global.combo_counter = 3
	Global.knockback_force += 20
	player.punch_queued = false
	player.combo_timer.stop()
	player.combo_timer.wait_time = player.combo_timer.time_left + 0.5
	player.combo_timer.start()
	player.sprite_top.play("kick1")
	player.sprite_bottom.play("kick_stance1")
	enable_hurtbox()
	play_punch_sound()
	if player.is_moving:
		temporary_boost(300)
		find_punch_push_direction()
	player.combo_timer.start()
	#print("State: ",player.state)
	
func enable_hurtbox():
	player.punch_hurtbox.disabled = false
	await player.get_tree().create_timer(0.1).timeout
	player.punch_hurtbox.disabled = true

func temporary_boost(boost):
	player.normal_SPEED += boost
	await player.get_tree().create_timer(0.1).timeout
	player.normal_SPEED = move_toward(player.normal_SPEED, 0, 400)
	
func play_punch_sound():
	player.get_node("Audio/PunchSound").pitch_scale = randf_range(0.8, 1.2)
	player.get_node("Audio/PunchSound").play()
	
func find_punch_push_direction():
	if player.face_direction == Vector2.LEFT:
		player.punch_push_velocity = -player.punch_push_force
	else:
		player.punch_push_velocity = player.punch_push_force
