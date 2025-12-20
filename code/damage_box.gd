#		POLYMORPHIC DAMAGE BOX CLASS
#	WRITTEN BY VOLODYMYR "PRAVETZ" DIDUR 
# 			  FOR UNFORGIVEN
extends Area2D
class_name DamageBox

#name of attack
@export var type: StringName
# impact_targets are Global groups, which will be impacted by the damage box
@export var impact_targets: Array[StringName]
# speed for projectiles
# 0.0 if damage box is not a projectile
@export var speed: float
# damage done to impact_targets
@export var damage: int
# knock back power for impact_target
# impact targets need to implement the logic for this themselves
@export var knock_back_power: int
# origion coordinates of a box
@export var origin: Vector2
# direction from origin of the damage box
@export var direction: Vector2
# parent node to damage box
@export var parent: Node2D
# lifetime (in ms) of a damage box
@export var lifetime_ms: float
# size of collision box
@export var collision_box_size: Vector2

# lifetime of a damage box
# for melee attacks this timer should be as small as possible
var lifetime_timer: Timer
var sprite: Sprite2D
var collision: CollisionShape2D

func _set_sprite_texture(_texture: Texture2D):
	sprite.texture = _texture
	if direction.x < 0:
		sprite.flip_h = true
	if direction.y < 0:
		sprite.flip_v = true

func _process(delta):
	position += (direction * speed).rotated(rotation) * delta

func create(_parent: Node2D, _impact_targets: Array[StringName], _origin: Vector2, _direction: Vector2, _lifetime_ms: float, _collision_box_size: Vector2, _type: StringName, _texture: Texture2D = null, _damage: int = 0, _knock_back_power: int = 0, _speed: float = 0.0):
	self.type = _type
	self.parent = _parent
	self.damage = _damage
	self.speed = _speed
	self.knock_back_power = _knock_back_power
	self.impact_targets = _impact_targets
	self.direction = _direction
	self.lifetime_ms = _lifetime_ms
	self.collision_box_size = _collision_box_size
	self.origin = _origin
	if _texture != null:
		var sprite_new = Sprite2D.new()
		add_child(sprite_new)
		self.sprite = sprite_new
		_set_sprite_texture(_texture)

func _init(_parent: Node2D, _impact_targets: Array[StringName], _origin: Vector2, _direction: Vector2, _lifetime_ms: float, _collision_box_size: Vector2, _type: StringName, _texture: Texture2D = null, _damage: int = 0, _knock_back_power: int = 0, _speed: float = 0.0):
	# init children
	self.collision_mask = 0xffffffff
	self.collision_layer = 0xffffffff
	var timer_new: Timer = Timer.new()
	timer_new.one_shot = true
	timer_new.autostart = false
	timer_new.connect("timeout", _on_lifetime_timer_timeout)
	self.lifetime_timer = timer_new
	add_child(timer_new)
	var collision_new: CollisionShape2D = CollisionShape2D.new()
	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = _collision_box_size
	collision_new.shape = rect_shape
	self.connect("body_entered", _on_body_entered)
	self.collision = collision_new
	add_child(collision_new)
	
	# init fields
	create(_parent, _impact_targets, _origin, _direction, _lifetime_ms, _collision_box_size, _type, _texture, _damage, _knock_back_power, _speed)

func _ready() -> void:
	self.global_position = self.origin
	self.collision.shape.size = self.collision_box_size
	self.lifetime_timer.wait_time = lifetime_ms / 1000
	self.lifetime_timer.start()

func _on_body_entered(body: Node2D) -> void:
	print(self.type, " enters body ", body)
	if body == parent:
		return
	# do "damage" if impacts target(-s) and they have damage_box_clb callback function
	# the actual implementation of damage_box_clb behavior is on the body's creator
	if Global.node_is_in_groups(body, impact_targets) and body.has_method("damage_box_clb"):
		body.damage_box_clb(self.type, self.damage, self.direction, self.knock_back_power)
	# disappear
	queue_free()


func _on_lifetime_timer_timeout() -> void:
	# object exceeded it's lifetime and didn't damage anyone
	# disappears
	queue_free()
