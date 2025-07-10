class_name PlayerInput

var player: CharacterBody2D

	
func process_input():
	if Input.is_action_just_pressed("fire") and player.can_fire: # SHOOTING -> C
		if Global.has_gun && player.can_fire:
			player.is_attacking = true
			player.shoot_sound.play()
			player.sprite_top.play("shoot")
			var bullet_instance = player.bullet.instantiate()
			bullet_instance.global_position = player.marker_2d.global_position
			bullet_instance.face_direction = player.face_direction
			player.get_parent().add_child(bullet_instance)
			player.can_fire = false
			await player.get_tree().create_timer(0.4).timeout
			player.can_fire = true
		else:
			pass
	
	if Input.is_action_just_pressed("kill_game"): # KILL GAME (shift + esc)
		player.get_tree().quit()
		
	# Handle dash input
	if Input.is_action_just_pressed("dash"):
		player.dash.start_dash(player.dash_length)
		player.can_take_damage = false
		await player.get_tree().create_timer(player.dash_length).timeout
		player.can_take_damage = true
	player.move_and_slide()
	
	if Input.is_action_just_pressed("melee") and player.can_punch:
		if Global.has_gun:
			player.is_attacking = true
			player.can_fire = false
			player.can_punch = false
			player.sprite_top.play("melee_with_gun")
			player.punch_hurtbox.disabled = false
			player.get_node("PunchSound").pitch_scale = randf_range(0.8, 1.2)
			player.get_node("PunchSound").play()
			await player.get_tree().create_timer(0.2).timeout
			player.punch_hurtbox.disabled = true
			await player.get_tree().create_timer(0.4).timeout  # cooldown
			player.is_attacking = false
			player.can_fire = true
			player.can_punch = true
		else:
			player.is_attacking = true
			player.can_fire = false
			player.can_punch = false
			player.sprite_top.play("punch1")
			player.sprite_bottom.play("punch_stance1")  # <- Play punch stance here
			player.punch_hurtbox.disabled = false
			player.get_node("PunchSound").pitch_scale = randf_range(0.8, 1.2)
			player.get_node("PunchSound").play()
			if player.face_direction == Vector2.LEFT:
				player.punch_push_velocity = -player.punch_push_force
			else:
				player.punch_push_velocity = player.punch_push_force
		await player.get_tree().create_timer(0.2).timeout
		player.punch_hurtbox.disabled = true
		player.punch_push_velocity = 0.0
		await player.get_tree().create_timer(0.4).timeout
		player.is_attacking = false
		player.can_punch = true
		player.can_fire = true
		
	if Input.is_action_just_pressed("instant_death"): 
		player.death()
		
	if Input.is_action_just_released("ui_accept") and player.velocity.y < 0:
		player.velocity.y = player.JUMP_VELOCITY /4
		
	if Input.is_action_just_pressed("ui_accept") and player.jump_count < player.jump_max: # Handle jump
		player.velocity.y = player.JUMP_VELOCITY
		player.jump_count += 1
