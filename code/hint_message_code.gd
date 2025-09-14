extends CanvasLayer
@onready var label = $paper/hint_text
var show = preload("res://music/SFX/hint_show.wav")
var hide = preload("res://music/SFX/hint_hide.wav")

func ready():
	pass

func give_hint(message):
	label.text = message
	$hint_animator.play("hint_show")
	$sound.stream = show
	$sound.play()
	self.visible = true
	$time_on_screen.start()
func _on_time_on_screen_timeout():
	$sound.stream = hide
	$sound.play()
	$hint_animator.play("hint_hide")
	await $hint_animator.animation_finished
	self.visible = false

func hint_manager(area_name: String) -> void:
	match area_name:
		"hint_jump":
			give_hint("Press ↑ to jump")
