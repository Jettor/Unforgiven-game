# EXAMPLE ENEMY ENTITY CONTROLLED BY FINITE-STATE MACHINE
#	WRITTEN BY VOLODYMYR "PRAVETZ" DIDUR 
# 			  FOR UNFORGIVEN

extends FSMEnemy_base

func _init():
	# set behavior properties for state machine
	super(
		# health
		50,
		# move speed
		100,
		# is clingy? 
		false,
		# has super awareness?
		false,
		# can shoot?
		true,
		# can melee?
		true,
		# can dash?
		true,
		# is static?
		false
	)

func _ready():
	# always finalize NPC state machine initialization in _ready function
	# do not set timers and sprite parts references in _init, God forbid
	self.attack_timer = $Timers/attack
	self.shoot_timer = $Timers/shooting
	self.navigation_agent = $NavigationAgent2D
	self.actor_sprite_parts = [$Sprite_top, $Sprite_bottom]
	self.actor_height = Global._calc_actor_height(self.actor_sprite_parts)
	self.actor_width = Global._calc_actor_width(self.actor_sprite_parts)
	self.enemies = ["Inquisition"]
	self.view_radius = $view_radius/CollisionShape2D
	self.melee_radius = $melee_zone/CollisionShape2D
	self.walk_sound = $WalkSound
	self.damage_sound = $DamageSound
	self.death_sound = $DeathSound
	self.sfx_walk_timer = $Timers/walk_timer
	
	# animation precedence
	# ascending order, first has biggest precedence
	self.animation_precedence = {
		self.actor_sprite_parts[0]: {"shoot":-1, "melee":-1, "walking":0, "default":0},
		self.actor_sprite_parts[1]: {"jumping":-1, "walking":-1, "default":-1}
	}
	
	for i in range(len(self.actor_sprite_parts)):
		self.current_animation[self.actor_sprite_parts[i]] = ""
	
	self.attack_damage_vector = {
		"melee": {
			"parent": self,
			"collision_box_size": Vector2(actor_width, actor_height),
			"damage": 5,
			"knock_back_power": 5,
			"speed": 0.0,  # melee is static
			"lifetime": 1000, # ms
			"texture": null
		},
		"shoot": {
			"parent": self,
			"collision_box_size": Vector2(4,5),
			"damage": 15,
			"knock_back_power": 1,
			"speed": 2000,
			"lifetime": 2000,
			"texture": load("res://images/bullet.png")
		}
	}

func _on_hearing_radius_body_entered(body: Node2D) -> void:
	# example implementation of NPC hearing
	# should be sufficient for any other non-example NPC
	if Global.node_is_in_groups(body, self.enemies):
		self.heard_enemy = true
		self.heard_object = body

func _on_view_radius_body_entered(body: Node2D) -> void:
	# example implementation of NPC seeing
	# should be sufficient for any other non-example NPC
	if Global.node_is_in_groups(body, self.enemies):
		self.seen_enemy = true
		self.seen_object = body


func _on_melee_zone_body_entered(body: Node2D) -> void:
	# example implementation of NPC melee possibility evaluation
	# should be sufficient for any other non-example NPC
	if Global.node_is_in_groups(body, self.enemies):
		self.melee_if_possible = true
