extends CharacterBody2D 

var normal_SPEED = 300.0
const dash_SPEED = 700.0
const dash_length =  0.3
const JUMP_VELOCITY = -500.0
var death_scene = load("res://scenes/death_stuff.tscn")

@onready var punch_sound = $PunchSound
@onready var shoot_sound = $ShootSound
@onready var dash = $Dash
@onready var walk_sound = $WalkSound
@onready var sprite_bottom = $Sprite_bottom
@onready var sprite_top = $Sprite_top
@onready var marker_2d = $Marker2D
@onready var punch_hurtbox = $punch/punch_hurtbox
@onready var death_stuff = $Death_stuff
@onready var healthbar = $Healthbar
@onready var camera = $"../Camera2D"

@onready var input_handler = PlayerInput.new()
@onready var visual_handler = VisualEffects.new()

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

@onready var punch_push_velocity := 0.0
@onready var punch_push_force:= 60.0
@onready var punch_push_timer = 0.1

var shake = false
var anim_name: String
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
@onready var is_attacking = false
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
	input_handler.player = self
	visual_handler.player = self
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
	input_handler.process_input()
	visual_handler.visual_manager(delta)
	visual_handler.attack_animation_handler(anim_name)
	
	if Global.has_gun == false:
		can_fire = false
		#can_punch = true
				
	var dir = Input.get_axis("ui_left", "ui_right")
	if dash.is_dashing():
		SPEED = dash_SPEED
	else:
		SPEED = normal_SPEED
	if punch_push_timer > 0.0:
		punch_push_timer -= delta
		velocity.x = punch_push_velocity
	# Handle horizontal movement
	elif dir != 0:
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
	elif is_attacking and punch_push_velocity != 0:
		velocity.x = punch_push_velocity
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if is_on_floor(): # Reset jump
		jump_count = 0
		
	if is_on_floor() and is_moving(): # walk sound
		if $walk_timer.time_left <= 0:
			walk_sound.pitch_scale = randf_range(0.8, 1.2)
			walk_sound.play()
			$walk_timer.start()
		
func _on_wait_for_lose_screen_timeout():
	get_tree().change_scene_to_file("res://scenes/UI_scenes/loser.tscn")

func _on_immortality_timeout():
	can_take_damage = true
	
func _on_sprite_top_animation_finished(anim_name: String):
	visual_handler.attack_animation_handler(anim_name)

func is_moving() -> bool:
	return velocity.length() > 0

func set_jump(value):	#Change max jumps if needed
	jump_max = value
func set_normalSpeed(value): #Change player walk speed
	normal_SPEED = value

		
func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction.normalized() * force
	knockback_timer = knockback_duration
	print("knocked")

func _on_death_slowmo_timeout():
	Engine.time_scale = 1.0
