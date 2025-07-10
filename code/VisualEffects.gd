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
		player.velocity.y += player.gravity * delta
	var is_moving = abs(player.velocity.x) > 0.1
	var has_gun = Global.has_gun

#Sprite_Bottom handle
	if not player.is_on_floor():
		player.sprite_bottom.play("jumping")
		if Global.has_gun:
			if !player.is_attacking:
				player.sprite_top.play("default")
		else:
			if !player.is_attacking:
				player.sprite_top.play("jumping_no_gun_top")
	elif is_moving:
		if !player.is_attacking:
			player.sprite_bottom.play("walking_bottom")
			if Global.has_gun:
				player.sprite_top.play("walking_top")
			else:
				player.sprite_top.play("walking_no_gun_top")
	else:
		if !player.is_attacking:
			player.sprite_bottom.play("default")
			if Global.has_gun:
				player.sprite_top.play("default")
			else:
				player.sprite_top.play("default_no_gun")
				
func attack_animation_handler(anim_name: String):
	if anim_name == "shoot":
		player.is_attacking = false
		player.sprite_top.play("default")
	if anim_name == "punch1":
		player.is_attacking = false
		player.sprite_top.play("default_no_gun")
	if anim_name == "melee_with_gun":
		player.is_attacking = false
		player.sprite_top.play("default")
