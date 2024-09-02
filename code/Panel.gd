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
	$"../../L/move_left".play("left_gate")
	$"../../R/move_right".play("right_gate")
	$"../../gates".play()

func format_time() -> String:
	return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)
