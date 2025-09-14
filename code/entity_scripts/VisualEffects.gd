extends Node
class_name VisualEffects

var player: CharacterBody2D

func visual_manager(delta):
	# Screen shake
	if player.shake == true:
		player.shake_time += 1
		var final_pos = Vector2(sin(player.shake_time) * 10, sin(player.shake_time) * 10)
		player.camera.offset = lerp(player.camera.offset, player.final_pos, 0.2)
	elif player.shake_time:
		player.shake_time = 0
		
	if not player.is_on_floor():
		if player.state == player.PlayerState.MELEE:
			player.velocity.y += (player.gravity * 0.01)
		else:
			player.velocity.y += player.gravity * delta
	var is_moving = abs(player.velocity.x) > 0.1

	if not player.is_on_floor():    #JUMP
		if !player.is_attacking:
			player.sprite_bottom.play("jumping")
		if Global.has_gun:
			if player.state == player.PlayerState.IDLE and !player.is_attacking:
				player.sprite_top.play("default")
		else: 
			if player.state == player.PlayerState.IDLE and !player.is_attacking:
				player.sprite_top.play("jumping_no_gun_top")
				
	elif is_moving:                 #WALK
		if player.state == player.PlayerState.IDLE and !player.is_attacking:
			player.sprite_bottom.play("walking_bottom")
			if Global.has_gun:
				player.sprite_top.play("walking_top")
			else:
				player.sprite_top.play("walking_no_gun_top")
				
	else:                           #STAND
		if player.state == player.PlayerState.IDLE and !player.is_attacking:
			player.sprite_bottom.play("default")
			if Global.has_gun:
				player.sprite_top.play("default")
			else:
				player.sprite_top.play("default_no_gun")
				
func attack_animation_handler(anim_name: String): #ENDS ANIMATION
	print("attack_animation_handler")
	if anim_name == "shoot" and player.state == player.PlayerState.SHOOTING:
		player.is_attacking = false
		player.sprite_top.play("default")
		player.state = player.PlayerState.IDLE
	if anim_name == "punch1":
		player.is_attacking = false
		player.sprite_top.play("default_no_gun")
	if anim_name == "melee_with_gun" and player.state == player.PlayerState.MELEE:
		player.is_attacking = false
		player.punch_hurtbox.disabled = true
		player.can_punch = true
		player.can_fire = true
		player.sprite_top.play("default")
		player.state = player.PlayerState.IDLE
		
