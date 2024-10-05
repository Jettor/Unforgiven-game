extends CharacterBody2D

signal knockback

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
@onready var sprite_2d = $Sprite2D
@onready var marker_2d = $Marker2D
@onready var death_stuff = $Death_stuff
@onready var healthbar = $Healthbar
var knockback_dir = Vector2()
var knockback_wait = 10

var face_direction = Vector2.RIGHT
var can_fire = true
var bullet = load("res://scenes/bullet.tscn")
var jump_max = 2
var enemy_instance
var direction = 1
var jump_count = 0
var healthp = Global.healthp
var damage_takenp = 20;
var can_take_damagep = true
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func damagee():
	if can_take_damagep:
		if healthp > 0:
			healthp = healthp - damage_takenp
			if healthp <= 0:
				Global.player_alive = false
				if not Global.player_alive:
					death()
			elif healthp > 0:
				print(healthp)
	
func _ready():
	top_level = true
	healthbar.init_health(healthp)
	
func death():
	$DeathSound.play()
	$Sprite2D.visible = false
	var death_scene = load("res://scenes/death_stuff.tscn")
	var instance = death_scene.instantiate()
	instance.play_death()
	$LightOccluder2D.hide()
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
		
	if Input.is_action_just_pressed("instant_death"): 
		death()
		
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY /4
		

	if Input.is_action_just_pressed("ui_accept") and jump_count < jump_max: # Handle jump
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
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
	if area.is_in_group("Wrog"):
		damage_takenp = 20
		damagee()
		healthbar.health = healthp
		if healthp <= 0:
			healthbar.hide()
		$DamageSound.play()
		print("wrog dotkniety")
		#emit_signal("knockback")
	else:
		return
		
func _on_wait_for_lose_screen_timeout():
	get_tree().change_scene_to_file("res://scenes/loser.tscn")
