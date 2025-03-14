extends CharacterBody2D

signal knockback

var normal_SPEED = 300.0
const dash_SPEED = 700.0
const dash_length =  0.3
const JUMP_VELOCITY = -500.0
var death_scene = load("res://scenes/death_stuff.tscn")
@onready var dash = $Dash
@onready var walk_sound = $WalkSound
@onready var sprite_2d = $Sprite2D
@onready var marker_2d = $Marker2D
@onready var death_stuff = $Death_stuff
@onready var healthbar = $Healthbar
@onready var camera = $"../Camera2D"
var knockback_dir = Vector2()
var knockback_wait = 10
var shake = false
var shake_time = 0
var face_direction = Vector2.RIGHT
var can_fire = true
var bullet = load("res://scenes/bullet.tscn")
var jump_max = 2
var enemy_instance
var direction = 1
var jump_count = 0
var healthp = Global.healthp
var damage_takenp = 20;
var can_take_damage = true

#Gravity from project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func damagee():
	if can_take_damage:
		if healthp > 0:
			can_take_damage = false
			healthp = healthp - damage_takenp
			if healthp <= 0:
				Global.player_alive = false
				if not Global.player_alive:
					death()
			elif healthp > 0:
				$immortality.start()
				print(healthp)
	
func _ready():
	top_level = true
	healthbar.init_health(healthp)
	
func death():
	$DeathSound.play()
	$Sprite2D.visible = false
	var instance = death_scene.instantiate()
	instance.play_death()
	$LightOccluder2D.hide()
	$player_hitbox.disabled = true
	$Area2D/CollisionShape2D.disabled = true
	get_tree().get_root().add_child(instance)
	instance.position = $Sprite2D.global_position
	$WaitForLoseScreen.start()
	
func _physics_process(delta):
	
	if Input.is_action_just_pressed("kill_game"): # KILL GAME
		get_tree().quit()
		
	# Animations
	if (velocity.x > 1 || velocity.x < -1):
		sprite_2d.animation = "walking"
	else:
		sprite_2d.animation = "default"
		# Screen shake
	if shake == true:
		shake_time += 1
		var final_pos = Vector2(sin(shake_time) * 10, sin(shake_time) * 10)
		camera.offset = lerp(camera. offset, final_pos, 0.2)
	elif shake_time:
		shake_time = 0
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		sprite_2d.animation = "jumping"
		
	if Input.is_action_pressed('ui_left'): # FLIP
		face_direction = Vector2.LEFT
		direction = 1
	elif Input.is_action_pressed('ui_right'):
		face_direction = Vector2.RIGHT
		direction = -1
	if Input.is_action_just_pressed("dash"): # Dash
		dash.start_dash(dash_length)
		can_take_damage = false
		await get_tree().create_timer(dash_length).timeout
		can_take_damage = true
		
	var SPEED = dash_SPEED if dash.is_dashing() else normal_SPEED # Dash speed handler
	
	if Input.is_action_just_pressed("fire") and can_fire: # SHOOTING
		$ShootSound.play()
		var bullet_instance = bullet.instantiate()
		bullet_instance.global_position = $Marker2D.global_position
		
		bullet_instance.face_direction = face_direction
		
		get_parent().add_child(bullet_instance)
		can_fire = false
		await get_tree().create_timer(0.4).timeout
		can_fire = true

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

	var direction = Input.get_axis("ui_left", "ui_right") # Handle movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if Input.is_action_just_pressed('ui_left'):
		sprite_2d.flip_h = true
		$Marker2D.position = Vector2(-31, 5)
	if Input.is_action_just_pressed('ui_right'):
		sprite_2d.flip_h = false
		$Marker2D.position = Vector2(31, 5)
		
	
func _on_area_2d_area_entered(area): # TAKING DAMAGE
	if area.is_in_group("Wrog") and can_take_damage == true:
		damage_takenp = 20
		$DamageSound.play()
		$Camera2D/zoom_animation.play("cam_shake")
		if Global.INPUT_SCHEME == Global.INPUT_SCHEMES.GAMEPAD:
			Input.start_joy_vibration(0,0.5,0.2,0.2)
		damagee()
		healthbar.health = healthp
		if healthp <= 0:
			healthbar.hide()
		print("wrog dotkniety")
		$damage.play("damage")
		#emit_signal("knockback")
	else:
		return
		
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
