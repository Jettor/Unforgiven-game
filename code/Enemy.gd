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
var can_take_damage = true
var bullet_name = ""
var bullet_damage = 10
var direction
signal enemy_scream
#var knockback_dir
#var knockback

func _ready():
	$Timer.timeout.connect(self._on_timer_timeout)
	connect("enemy_scream", Callable(Global, "_on_enemy_died"))
	
func _on_timer_timeout() -> void:
	nav.target_position = target.position

func _physics_process(delta):
	direction = (nav.get_next_path_position() - global_position).normalized()
	translate(direction * Global.speed_plus * delta)
	
	#if knockback == true:
	#	motion.x = 700 * direction
	#	motion.y = 20 
	#	knockback = false
	if direction.x < 0:
		enemy.scale.x = 1  # Noz/? flip (default)
	elif direction.x > 0:
		enemy.scale.x = -1  # Flip horizontally
		
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
	
func damage():
	if can_take_damage:
		if health > 0:
			health = health - bullet_damage
			if health <= 0:
				alive = false
				if not alive: 
					emit_signal("enemy_scream")
					death()  
					queue_free()
			elif health > 0:
				print(health)

func _on_area_2d_area_entered(area):
	if area.is_in_group("bullet"):
		bullet_name = "normal"
		print(bullet_name, "bullet has hit enemy")
		bullet_damage = 10
		damage()
	else:
		return
	

#func _on_character_body_2d_knockback():
#	print("knocked")
#	# vvvv DOESN'T WORK! vvvv
#	var player_dir = get_parent().get_node("CharacterBody2D").direction
#	knockback_dir = player_dir
#	direction = knockback_dir * -1
#	knockback = true
