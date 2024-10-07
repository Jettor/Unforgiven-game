extends Area2D

@export var speed = 2000
var face_direction


func _ready():
	top_level = true
	
func _process(delta):
	position += (face_direction*speed).rotated(rotation) * delta


func _physics_process(delta):
	await get_tree().create_timer(0.2).timeout
	set_physics_process(false)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func _on_body_entered(body):
	queue_free()
