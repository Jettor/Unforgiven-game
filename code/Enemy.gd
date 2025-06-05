extends CharacterBody2D

class_name Enemy
var particle_handler = load("uid://c44pwmfk4ihob")
@onready var target = $"../CharacterBody2D"
@onready var nav : NavigationAgent2D = $NavigationAgent2D
@onready var timer = $Timer
@onready var enemy = $Enemy
var alive = true
var motion = Vector2()
var health = 10
var k_force = Global.knockback_force
var can_take_damage = true
var direction
signal enemy_scream
var knockback_duration: float = 0.3  # seconds
var knockback_timer: float = 0.0
var knockback_force:Vector2 = Vector2.ZERO

func _ready():
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
	translate(direction * Global.speed_plus * delta)

	# Flip sprite based on direction
	if direction.x < 0:
		enemy.scale.x = 1
	elif direction.x > 0:
		enemy.scale.x = -1
		
func death():
	print("enemy has died")
	Global.time += 0.5
	print("+0.5 second")
	Global.gained_time += 0.5
	Global.score += Global.score_reward
	enemy.visible = false
	var instance = particle_handler.instantiate()
	instance.play_death_enemy()
	instance.play_damage_enemy()
	get_tree().get_root().add_child(instance)
	instance.position = enemy.global_position
	
func Melee_damage_handler():
	if can_take_damage:
		if health > 0:
			health = health - Global.melee_damage 
			if health <= 0:
				alive = false
				if not alive: 
					emit_signal("enemy_scream")
					death()  
					queue_free()
			elif health > 0:
				await apply_knockback(global_position - target.global_position, k_force)
				print(health)
	
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
				await apply_knockback(global_position - target.global_position, k_force)
				print(health)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		Global.bullet_name = "normal"
		print(Global.bullet_name, "bullet has hit enemy")
		Bullet_damage_handler()
	elif area.is_in_group("melee"):
		print("fist has hit enemy")
		Melee_damage_handler()
	if area.name == "punch_r":
		$in_radius.play("radius_entered")
	else:
		return
		
func apply_knockback(direction: Vector2, force: float):
	await get_tree().create_timer(0.1).timeout
	knockback_force = direction.normalized() * force
	knockback_timer = knockback_duration

func _on_knockback_speed_return_timeout():
	Global.speed_plus += 1

func _on_timer_timeout()-> void:
	nav.target_position = target.position
