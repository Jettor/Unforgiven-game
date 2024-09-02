extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func play_death():
	$mc_dead.emitting = true
func play_death_enemy():
	$enemy_dead.emitting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
