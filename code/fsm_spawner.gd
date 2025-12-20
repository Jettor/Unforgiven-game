#	FINITE-STATE MACHINE-CONTROLLED ENTITY SPAWNER
#	WRITTEN BY VOLODYMYR "PRAVETZ" DIDUR 
# 			  FOR UNFORGIVEN

extends Node2D
class_name EntitySpawner

func spawn(entity, gfx, gfx_anim_nod: String, gfx_anim_name: String):
	var spawn_effect = gfx.instantiate()
	var e = entity.instantiate()
	e.global_position = self.global_position
	add_child(spawn_effect)
	spawn_effect.get_node(gfx_anim_nod).play(gfx_anim_name)
	await get_tree().create_timer(0.8).timeout
	print("<spawner> spawn entity at: ", self.global_position)
	await get_tree().create_timer(0.5).timeout
	spawn_effect.queue_free()
	Global.speed_plus += Global.normal_addition
	return e
