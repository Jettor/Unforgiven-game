#	FINITE STATE MACHINE AI CONTROLLER
#	WRITTEN BY VOLODYMYR "PRAVETZ" DIDUR 
# 			  FOR UNFORGIVEN

extends Enemy_class
class_name FSMEnemy_base # Curiously enough, can also be used to create friendly NPCs in relation to the MC

enum FSM_ENEMY_STATE {
	IDLE,
	ALERT,
	ATTACK,
	HIT,
	DEAD
}

# shoot damage, if can shoot
var move_speed: int
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# will cling on to player the moment it sees him and enters ALERT state
var clingy: bool
# super aware AI always knows where player is and will follow him
var super_aware: bool
# if can melee, will try to punch/cut it's enemy when it's close enough and melee_timer is up
var can_melee: bool
# if can shoot, will produce projectiles after shoot_timer is up
var can_shoot: bool
# can dash
var can_dash: bool
# if static, NPC won't move on map when spawned
var is_static: bool 
var current_state: FSM_ENEMY_STATE

# special flags
var melee_if_possible: bool
# used with clingy to make AI cling on and follow MC's position on the map
# once it saw him
var seen_enemy_once: bool
var seen_enemy: bool
var heard_enemy: bool
var heard_object: Node2D
var seen_object: Node2D
var jump_count: int = 2

var actor_sprite_parts: Array[AnimatedSprite2D]
var actor_height: int
var actor_width: int
var navigation_agent: NavigationAgent2D
var shoot_timer: Timer
var attack_timer: Timer
var view_radius: CollisionShape2D
var melee_radius: CollisionShape2D
var enemies: Array[StringName]        # list of groups this state machine reacts to as enemies
var prev_pos: Vector2
var effective_move_speed: float
var attack_damage_vector: Dictionary  # dictionary of dictionaries, contains meta for melee/shoot attacks' damage boxes

# animation handling
var animation_precedence: Dictionary
var current_animation: Dictionary

# sfx
var sfx_walk_timer: Timer
var walk_sound: AudioStreamPlayer
var melee_sound: AudioStreamPlayer
var shoot_sound: AudioStreamPlayer
var damage_sound: AudioStreamPlayer
var death_sound: AudioStreamPlayer

func _init(
	_health:int = 100,
	_move_speed: int = 50,
	_clingy: bool = false,
	_super_aware: bool = false,
	_can_shoot: bool = false,
	_can_melee: bool = false,
	_can_dash: bool = false,
	_is_static: bool = false
	) -> void:
	self.current_state = FSM_ENEMY_STATE.IDLE
	self.health = _health
	self.move_speed = _move_speed
	self.clingy = _clingy
	self.super_aware = _super_aware
	self.can_shoot = _can_shoot
	self.can_melee = _can_melee
	self.can_dash = _can_dash
	self.effective_move_speed = gravity / 3 * move_speed
	self.is_static = _is_static

func _compare_animation_precedence(part: AnimatedSprite2D, left: StringName, right: StringName) -> int:
	if self.animation_precedence[part].get(left) == null or self.animation_precedence[part].get(right) == null:
		return -1
	var left_pos = self.animation_precedence[part].get(left)
	var right_pos = self.animation_precedence[part].get(right)
	return left_pos - right_pos

func state_play_animation(part: AnimatedSprite2D, state: FSM_ENEMY_STATE) -> bool:
	match state:
		_:
			return true
		FSM_ENEMY_STATE.HIT:
			if self.current_animation[part] != "hit":
				self.current_animation[part] = "hit"
				part.play("hit")
			if part.is_playing():
				return false
			self.current_animation[part] = ""
			return true
		FSM_ENEMY_STATE.DEAD:
			if self.current_animation[part] != "death":
				self.current_animation[part] = "death"
				part.play("death")
			if part.is_playing():
				return false
			self.current_animation[part] = ""
			return true

func play_animation(part: AnimatedSprite2D, anim_name: StringName) -> void:
	var _current: StringName = ""
	var comp: int = _compare_animation_precedence(part, anim_name, current_animation[part])
	if comp <= 0 or not part.is_playing():
		_current = anim_name
	else:
		_current = current_animation[part]
	part.play(_current)
	current_animation[part] = _current

func _manage_animation(delta):
	var walked_distance: float = abs(self.global_position.x - prev_pos.x)
	if walked_distance > 0.0 and velocity.y == 0:
		for part in actor_sprite_parts:
			play_animation(part, "walking")
		if sfx_walk_timer != null and sfx_walk_timer.time_left <= 0 and self.walk_sound != null:
			walk_sound.pitch_scale = randf_range(0.8, 1.2)
			walk_sound.play()
			sfx_walk_timer.start()
	elif velocity.y != 0:
		for part in actor_sprite_parts:
			play_animation(part, "jumping")
	else:
		for part in actor_sprite_parts:
			play_animation(part, "default")

func perform_attack(type: StringName, direction: Vector2):
	if type not in self.attack_damage_vector:
		print("can't perform ", type, " attack, it was NOT defined for entity ", self)
		return
	for part in actor_sprite_parts:
		play_animation(part, type)
	
	var parent_node_to_parent = self.attack_damage_vector[type]["parent"].get_parent()
	
	var dbox: DamageBox = DamageBox.new(
		self.attack_damage_vector[type]["parent"],
		self.enemies,
		self.global_position + self.actor_width * direction,
		direction,
		self.attack_damage_vector[type]["lifetime"],
		self.attack_damage_vector[type]["collision_box_size"],
		type,
		self.attack_damage_vector[type]["texture"],
		self.attack_damage_vector[type]["damage"],
		self.attack_damage_vector[type]["knock_back_power"],
		self.attack_damage_vector[type]["speed"]
	)
	
	parent_node_to_parent.add_child(dbox)

func switch_state():
	if self.current_state == FSM_ENEMY_STATE.DEAD:
		return
	print("seen_enemy = ", seen_enemy)
	print("heard_enemy = ", heard_enemy)
	if heard_enemy and not seen_enemy:
		self.current_state = FSM_ENEMY_STATE.ALERT
		self.heard_enemy = false
		self.target = heard_object
	if seen_enemy or (self.clingy and self.seen_enemy_once):
		if self.seen_enemy:
			self.current_state = FSM_ENEMY_STATE.ATTACK
		else:
			self.current_state = FSM_ENEMY_STATE.ALERT
		self.seen_enemy_once = true
		self.seen_enemy = false
		self.target = seen_object
	else:
		self.current_state = FSM_ENEMY_STATE.IDLE
	
	print("current state = ", self.current_state)

func switch_target_pos(walked_distance: float) -> bool:
	return walked_distance <= 1 or self.navigation_agent.is_navigation_finished() or self.navigation_agent.is_target_reached()

func need_to_jump(dir: Vector2) -> bool:
	var next_angle: float = Global.abs_angle(get_angle_to(self.navigation_agent.get_next_path_position()))
	var horizontal_collisions: bool = false
	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		var col_angle: float = collision.get_angle(up_direction)
		if col_angle >= PI / 2 and col_angle <= PI / 2 + 0.001:
			horizontal_collisions = true
			break
	
	return (Global.give_up_trigger_angle(next_angle) or (horizontal_collisions and dir.y < 0)) and jump_count >= 1

func should_give_up_pursuit() -> bool:
	var next_angle: float = Global.abs_angle(get_angle_to(self.navigation_agent.get_next_path_position()))
	return Global.give_up_trigger_angle(next_angle) or (self.navigation_agent.get_next_path_position().y < self.global_position.y - self.actor_height or self.navigation_agent.get_next_path_position().y > self.global_position.y + self.actor_height)

func set_patrol_target() -> void:
	self.navigation_agent.target_position = self.global_position
	self.navigation_agent.target_position.x = self.global_position.x + self.actor_width * 2
	direction = self.navigation_agent.get_next_path_position() - global_position
	direction = Global.normalize_movement_direction(direction)
	var walked_distance: float = abs(self.global_position.x - prev_pos.x)
	if (not self.navigation_agent.is_target_reachable()) and walked_distance <= 0.001:
		self.navigation_agent.target_position.x = self.global_position.x - self.actor_width * 2

func determine_target() -> void:
	var walked_distance: float = abs(self.global_position.x - self.prev_pos.x)
	
	if switch_target_pos(walked_distance):
		match self.current_state:
			FSM_ENEMY_STATE.ATTACK:
				self.navigation_agent.target_position = self.target.global_position
			FSM_ENEMY_STATE.ALERT:
				self.navigation_agent.target_position = self.target.global_position
			FSM_ENEMY_STATE.IDLE:
				set_patrol_target()
	
	if should_give_up_pursuit():
		set_patrol_target()

func move(delta):
	var direction: Vector2
	if not is_static:
		determine_target()
		direction = self.navigation_agent.get_next_path_position() - global_position
		direction = Global.normalize_movement_direction(direction)
		var is_facing_left = direction.x < 0
		if is_facing_left:
			for part in self.actor_sprite_parts:
				part.flip_h = true
				part.flip_h = true
			self.view_radius.position.x *= -1
			self.melee_radius.position.x *= -1
		else:
			for part in self.actor_sprite_parts:
				part.flip_h = false
				part.flip_h = false
			self.view_radius.position.x *= -1
			self.melee_radius.position.x *= -1
	
	if melee_if_possible and can_melee and attack_timer.time_left <= 0:
		melee_if_possible = false
		perform_attack("melee", Vector2(direction.x, 0))
		attack_timer.start()
	
	if self.current_state == FSM_ENEMY_STATE.ATTACK and can_shoot and shoot_timer.time_left <= 0:
		perform_attack("shoot", Vector2(direction.x, 0))
		shoot_timer.start()
	
	prev_pos = self.global_position
	velocity.x = direction.x * move_speed
	if not is_on_floor():
		velocity.y += delta * gravity
	else:
		self.jump_count = 2
		if need_to_jump(direction) and self.jump_count:
			self.jump_count -= 1
			velocity.y -= delta * self.effective_move_speed
	move_and_slide()
	_manage_animation(delta)

func damage_box_clb(_type: StringName, _damage: int, _direction: Vector2, _knock_back_power: int):
	if can_take_damage:
		can_take_damage = false
		self.health -= _damage
		print("enemy health ", self.health)
		damage_sound.play()
		if self.health <= 0:
			die()
		else:
			self.current_state = FSM_ENEMY_STATE.HIT
			for part in self.actor_sprite_parts:
				state_play_animation(part, FSM_ENEMY_STATE.HIT)
			can_take_damage = true

func die() -> void:
	var finish_flag = false
	for part in self.actor_sprite_parts:
		finish_flag = state_play_animation(part, FSM_ENEMY_STATE.DEAD)
	if finish_flag == true:
		death_sound.play()
		queue_free()

func _physics_process(delta):
	switch_state()
	match(current_state):
		FSM_ENEMY_STATE.IDLE:
			move(delta)
		FSM_ENEMY_STATE.ALERT:
			move(delta)
		FSM_ENEMY_STATE.ATTACK:
			move(delta)
		FSM_ENEMY_STATE.HIT:
			move(delta)
		FSM_ENEMY_STATE.DEAD:
			die()
