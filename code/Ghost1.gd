extends Enemy_class
class_name Ghost1
@onready var nav : NavigationAgent2D = $NavigationAgent2D
@onready var timer = $Timer
signal enemy_scream

func _ready():
	var player = get_node("res://scenes/Entities/mc.tscn")
	health = 10
	damage = 20
	enemy = $Enemy
	$Timer.timeout.connect(self._on_timer_timeout)
	connect("enemy_scream", Callable(Global, "_on_enemy_died"))
	
func _physics_process(delta):
	if knockback_timer > 0.0:
		velocity = knockback_force
		knockback_timer -= delta
		move_and_slide()
		return  # Skip normal movement during knockback
	# Regular movement
	direction = (nav.get_next_path_position() - global_position).normalized()
	translate(direction * current_speed * delta)

	# Flip sprite based on direction
	if direction.x < 0:
		enemy.scale.x = 1
	elif direction.x > 0:
		enemy.scale.x = -1
	
func Bullet_damage_handler():
	if can_take_damage:
		if health > 0:
			health = health - Global.bullet_damage
			if health <= 0:
				alive = false
				if not alive: 
					emit_signal("enemy_scream")
					death()  
					queue_free()
			elif health > 0:
				await apply_knockback(global_position - target.global_position, k_force, 0.1)
				print(health)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		Global.bullet_name = "normal"
		print(Global.bullet_name, "bullet has hit enemy")
		Bullet_damage_handler()
	elif area.is_in_group("melee"):
		emit_signal("enemy_punched")
		$Enemy_hit_scream.pitch_scale = randf_range(0.8, 1.2)
		$Enemy_hit_scream.play()
		print("fist has hit enemy")
		Melee_damage_handler()
	if area.name == "punch_r":
		$in_radius.play("radius_entered")
		
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.name == "punch_r":
		$in_radius.stop()

func _on_timer_timeout()-> void:
	nav.target_position = target.position
	
func play_stun_effect():
	$Enemy/stun_animation.show()
	$Enemy/stun_animation.play("stun_stars")

func play_death_particles(): #OVERRIDE
	particle_spawner.play_death_enemy() 
	particle_spawner.play_damage_enemy() 

func _on_stun_timer_timeout():
	damage = 20
	$Enemy/stun_animation.hide()
	current_speed = Global.speed_plus
