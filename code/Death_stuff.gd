extends Node2D

func _ready():
	pass
	
func play_death():
	if Global.INPUT_SCHEME == Global.INPUT_SCHEMES.GAMEPAD: #Controller vibration support doesn't work
		Input.start_joy_vibration(1,0.5,0.2,0.2)
	$mc_dead.emitting = true
func play_death_enemy():
	$enemy_dead.emitting = true
func play_damage_enemy():
	$enemy_damage.emitting = true
func play_stun():
	$stun.emitting = true
func play_drop_gun():
	$gun.emitting = true
func play_blood_spill():
	$mc_blood_spill.emitting = true
func play_impact_particles():
	$hit_particles.emitting = true

func _process(delta):
	pass
