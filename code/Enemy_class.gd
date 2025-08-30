extends CharacterBody2D
class_name Enemy_class

var health: int 
var damage: int
var alive = true
@onready var target = $"../CharacterBody2D"
var current_speed = Global.speed_plus
var k_force = Global.knockback_force
var can_take_damage = true
var direction
@onready var enemy
var particle_handler = load("uid://c44pwmfk4ihob") #death_stuff
var particle_spawner = particle_handler.instantiate()
var knockback_duration: float = 0.3  # seconds
var knockback_timer: float = 0.0
var knockback_force:Vector2 = Vector2.ZERO

func death():
	particle_spawner.position = enemy.global_position
	print("enemy has died")
	Global.time -= 0.5
	print("-0.5 second")
	Global.gained_time += 0.5
	Global.score += Global.score_reward
	enemy.visible = false
	
	play_death_particles()
	get_tree().get_root().add_child(particle_spawner)
	
func Melee_damage_handler():
	if can_take_damage:
		if health > 0:
			health = health - Global.melee_damage 
			if health <= 0:
				alive = false
				emit_signal("enemy_scream")
				death()  
				queue_free()
			elif health > 0:
				await apply_knockback(global_position - target.global_position, k_force-80, 0.1)
				#current_speed = lerp(0.0, 180, 20*delta)
				if Global.combo_counter >= 3:
					await apply_knockback(global_position - target.global_position, k_force, 0.1)
					particle_spawner.position = enemy.global_position
					particle_spawner.play_stun()
					get_tree().get_root().add_child(particle_spawner)
					play_stun_effect()
					$stun_timer.start()
				print(health)

func play_death_particles():
	particle_spawner.play_death_enemy() 
	particle_spawner.play_damage_enemy() 
	
func give_damage() -> int:
	if $stun_timer.time_left > 0:
		return 0
	return damage
	
func apply_knockback(direction: Vector2, force: float, duration: float):
	await get_tree().create_timer(0.1).timeout
	direction = direction.normalized()
	direction.y *= 0.3
	knockback_force = direction.normalized() * force
	knockback_timer = knockback_duration

func play_stun_effect(): #gets overwritten
	pass
