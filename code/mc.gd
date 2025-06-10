extends CharacterBody2D

var normal_SPEED = 300.0
const dash_SPEED = 700.0
const dash_length =  0.3
const JUMP_VELOCITY = -500.0
var death_scene = load("res://scenes/death_stuff.tscn")
@onready var dash = $Dash
@onready var walk_sound = $WalkSound
@onready var sprite_bottom = $Sprite_bottom
@onready var sprite_top = $Sprite_top
@onready var marker_2d = $Marker2D
@onready var punch_hurtbox = $punch/punch_hurtbox
@onready var death_stuff = $Death_stuff
@onready var healthbar = $Healthbar
@onready var camera = $"../Camera2D"

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

var shake = false
var SPEED: float
var shake_time = 0
var face_direction = Vector2.RIGHT
var can_fire = true
var can_punch = true
var bullet = load("res://scenes/bullet.tscn")
var jump_max = 2
var enemy_instance
var direction = 1
var jump_count = 0
var healthp: int = Global.healthp
var damage_taken: int
var can_take_damage = true
var is_attacking = false
#Gravity from project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _on_area_2d_area_entered(area): # TAKING DAMAGE
	if area.is_in_group("Wrog") and can_take_damage:
		if area.get_parent().has_method("give_damage"):
			damage_taken = area.get_parent().give_damage()
			if area.get_parent().give_damage() > 0:
				$DamageSound.play()
				$Camera2D/zoom_animation.play("cam_shake")
				if Global.INPUT_SCHEME == Global.INPUT_SCHEMES.GAMEPAD:
					Input.start_joy_vibration(0,0.5,0.2,0.2)
				damagee()
				healthbar.health = healthp
				print("zgon")
				$damage.play("damage")

func damagee():
	if healthp > 0:
		can_take_damage = false
		healthp = healthp - damage_taken
		if healthp <= 0:
			healthbar.hide()
			Global.player_alive = false
			if not Global.player_alive:
				death()
		elif healthp > 0:
			$immortality.start()
			print(healthp)
	
func _ready():
	top_level = true
	healthbar.init_health(healthp)
	punch_hurtbox.disabled = true
	
func death():
	Engine.time_scale = 0.05
	$death_slowmo.start()
	$DeathSound.play()
	sprite_bottom.visible = false
	sprite_top.visible = false
	var instance = death_scene.instantiate()
	instance.play_blood_spill()
	instance.play_death()
	instance.play_drop_gun()
	$player_hitbox.disabled = true
	$Area2D/CollisionShape2D.disabled = true
	get_tree().get_root().add_child(instance)
	instance.position = sprite_bottom.global_position
	instance.position = sprite_top.global_position
	$WaitForLoseScreen.start()
	
func _physics_process(delta):
	if Global.has_gun == false:
		can_fire = false
		#can_punch = true
		
	if Input.is_action_just_pressed("kill_game"): # KILL GAME
		get_tree().quit()
		
	# Handle animations + gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	var is_moving = abs(velocity.x) > 0.1
	var has_gun = Global.has_gun
	
	#Sprite_Bottom handle
	if not is_on_floor(): #JUMPING
		sprite_bottom.play("jumping")
		if has_gun:
			if !is_attacking:
				sprite_top.play("default")
		else:
			if !is_attacking:
				sprite_top.play("default_no_gun")
	elif is_moving: #RUNNING
		sprite_bottom.play("walking_bottom")
		if has_gun:
			if !is_attacking:
				sprite_top.play("walking_top")
		else:
			if !is_attacking:
				sprite_top.play("walking_no_gun_top")
	else: #STAND IN PLACE
		sprite_bottom.play("default")
		if has_gun:
			if !is_attacking:
				sprite_top.play("default")
		else:
			if !is_attacking:
				sprite_top.play("default_no_gun")
				
				
	# Handle dash input
	if Input.is_action_just_pressed("dash"):
		dash.start_dash(dash_length)
		can_take_damage = false
		await get_tree().create_timer(dash_length).timeout
		can_take_damage = true
	move_and_slide()
	
	if Input.is_action_just_pressed("melee") and can_punch: # MELLEE -> X
		if has_gun && can_punch:
			is_attacking = true
			can_fire = false
			sprite_top.play("melee_with_gun")
			punch_hurtbox.disabled = false
			$PunchSound.pitch_scale = randf_range(0.8, 1.2)
			$PunchSound.play()
			# Turn off hurtbox after short duration (e.g. 0.2 seconds)
			await get_tree().create_timer(0.2).timeout
			punch_hurtbox.disabled = true
			# Wait for cooldown to allow next punch
			await get_tree().create_timer(0.4).timeout  # 0.2s hurtbox + 0.4s cooldown = 0.6s total
			can_punch = true
			can_fire = true
		elif !has_gun && can_punch:
			is_attacking = true
			can_fire = false
			sprite_top.play("punch1")
			punch_hurtbox.disabled = false
			$PunchSound.pitch_scale = randf_range(0.8, 1.2)
			$PunchSound.play()
			await get_tree().create_timer(0.2).timeout
			punch_hurtbox.disabled = true
			await get_tree().create_timer(0.4).timeout  # 0.2s hurtbox + 0.4s cooldown = 0.6s total
			can_punch = true
			
	if Input.is_action_just_pressed("fire") and can_fire: # SHOOTING -> C
		if has_gun && can_fire:
			is_attacking = true
			$ShootSound.play()
			sprite_top.play("shoot")
			var bullet_instance = bullet.instantiate()
			bullet_instance.global_position = $Marker2D.global_position
			bullet_instance.face_direction = face_direction
			get_parent().add_child(bullet_instance)
			can_fire = false
			await get_tree().create_timer(0.4).timeout
			can_fire = true
		else:
			pass
		# Screen shake
	if shake == true:
		shake_time += 1
		var final_pos = Vector2(sin(shake_time) * 10, sin(shake_time) * 10)
		camera.offset = lerp(camera. offset, final_pos, 0.2)
	elif shake_time:
		shake_time = 0

	var dir = Input.get_axis("ui_left", "ui_right")
	if dash.is_dashing():
		SPEED = dash_SPEED
	else:
		SPEED = normal_SPEED
	# Handle horizontal movement
	if dir != 0:
		velocity.x = dir * SPEED
		var is_facing_left = dir < 0
		if is_facing_left:
			face_direction = Vector2.LEFT
			sprite_bottom.flip_h = true
			sprite_top.flip_h = true
			$Marker2D.position = Vector2(-31, 5)
			punch_hurtbox.position.x = -62
		else:
			face_direction = Vector2.RIGHT
			sprite_bottom.flip_h = false
			sprite_top.flip_h = false
			$Marker2D.position = Vector2(31, 5)
			punch_hurtbox.position.x = 0
	else:
		# Smooth deceleration to zero when no input
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if is_on_floor(): # Reset jump
		jump_count = 0
		
	if is_on_floor() and is_moving(): # walk sound
		if $walk_timer.time_left <= 0:
			walk_sound.pitch_scale = randf_range(0.8, 1.2)
			walk_sound.play()
			$walk_timer.start()
		
	if Input.is_action_just_pressed("instant_death"): 
		death()
		
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY /4
		
	if Input.is_action_just_pressed("ui_accept") and jump_count < jump_max: # Handle jump
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		
func _on_wait_for_lose_screen_timeout():
	get_tree().change_scene_to_file("res://scenes/loser.tscn")

func _on_immortality_timeout():
	can_take_damage = true

func is_moving() -> bool:
	return velocity.length() > 0

func set_jump(value):	#Change max jumps if needed
	jump_max = value
func set_normalSpeed(value): #Change player walk speed
	normal_SPEED = value

func _on_sprite_top_animation_finished():
	if sprite_top.animation == "shoot":
		is_attacking = false
		sprite_top.play("default")
	if sprite_top.animation == "punch1":
		is_attacking = false
		sprite_top.play("default_no_gun")
	if sprite_top.animation == "melee_with_gun":
		is_attacking = false
		sprite_top.play("default")
		
func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction.normalized() * force
	knockback_timer = knockback_duration
	print("knocked")

func _on_death_slowmo_timeout():
	Engine.time_scale = 1.0
