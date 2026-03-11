extends Node

var curr_staircase_side = "null"
var curr_floor_number = 0

var floor_1_pool = {
	"hs_floor_2a":"res://scenes/Locations/Highschool/floors/floor1/Highschool_floor1_a.tscn",
	
}
var floor_2_pool = {
	"hs_floor_2a":"res://scenes/Locations/Highschool/floors/floor2/Highschool_floor2_a.tscn",
	"hs_floor_2b":"res://scenes/Locations/Highschool/floors/floor2/Highschool_floor2_b.tscn",
	"hs_floor_2c":"res://scenes/Locations/Highschool/floors/floor2/Highschool_floor2_c.tscn"
}
var floor_3_pool = {
	"hs_floor_2a":"res://scenes/Locations/Highschool/floors/floor3/Highschool_floor3_a.tscn",
}
var staircase_pool = {
	"hs_staircase_a":"res://scenes/Locations/Highschool/staircases/Highschool_Staircase_a.tscn",
	"hs_staircase_b":"res://scenes/Locations/Highschool/staircases/Highschool_Staircase_b.tscn",
	"hs_staircase_c":"res://scenes/Locations/Highschool/staircases/Highschool_Staircase_c.tscn"
}

var selected_floors = {}
var selected_stairs = {}
var roof = {}

func generate_run():
	selected_floors = {
		1: floor_1_pool.values().pick_random(),
		2: floor_2_pool.values().pick_random(),
		3: floor_3_pool.values().pick_random()
	}
	selected_stairs = {               #ADD DIFFERENT STAIRCASES FOR EACH SIDE
		1: staircase_pool.values().pick_random()
	}
	roof = {
		1: "res://scenes/Locations/Highschool/floors/rooftop/Highschool_rooftop.tscn"
	}

func go_to_floor(n: int):
	get_tree().change_scene_to_file(selected_floors[n])
	print("teleported to: ", selected_floors[n])
func go_to_stairs(id: int):
	get_tree().change_scene_to_file(selected_stairs[id]) #IF GODOT SHOWS ERROR HERE, CHECK IF generate_run() was called
