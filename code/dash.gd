extends Node2D

@onready var timer = $dashtimer
@onready var cooldown = $cooldown
var can_dash = true

func start_dash(duration):
	if can_dash:
		timer.wait_time = duration
		timer.start()
		$sound.play()
		cooldown.start()
		can_dash = false
	else:
		pass # ADD MESSAGE, THAT PLAYER CAN'T DASH RN
	
func is_dashing():
	return !timer.is_stopped()

func _on_cooldown_timeout():
	can_dash = true
