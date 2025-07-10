extends AnimatableBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$mover.play("move_platform")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
