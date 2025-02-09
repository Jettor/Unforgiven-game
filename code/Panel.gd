extends Panel
  # 3 minutes in seconds
var minutes: int = 0
var seconds: int = 0
var milliseconds: int = 0
var time_reached_zero = false
var win_screen

func _ready():
	pass
		
func _process(delta) -> void:
	Global.time -= delta
	if Global.time < 0:
		Global.time = 0
	
	minutes = int(Global.time) / 60
	seconds = int(Global.time) % 60
	milliseconds = int(Global.time * 1000) % 1000

	$minutes.text = str(minutes).pad_zeros(2) + ":"
	$seconds.text = str(seconds).pad_zeros(2) + "."
	$milliseconds.text = str(milliseconds).pad_zeros(3)
	
	if Global.time == 0 and not time_reached_zero:
		time_reached_zero = true
		on_time_reached_zero()
		
func on_time_reached_zero() -> void:
	var left_gate = get_tree().get_nodes_in_group("left_gate")
	var right_gate = get_tree().get_nodes_in_group("right_gate")
	var gates = $"../../gates" if has_node("../../gates") else null
	for gate in left_gate:
		if Global.lvl1_playing:
			gate.play("left_gate")
		elif Global.lvl2_playing:
			gate.play("left_gate2")
	for gate in right_gate:
		if Global.lvl1_playing:
			gate.play("right_gate")
		elif Global.lvl2_playing:
			gate.play("right_gate2")
	if gates:
		gates.play()
	$punkty.add_theme_color_override("font_color", "#00FF00")
	$"../x2".show()
	Global.x2 = true
	Global.score_reward *= 2

func format_time() -> String:
	return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)
