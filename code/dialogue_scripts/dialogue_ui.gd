extends Control

@onready var d_speaker = $CanvasLayer/Panel/dialogue_box/D_speaker
@onready var d_speech = $CanvasLayer/Panel/dialogue_box/D_text
@onready var d_options = $CanvasLayer/Panel/dialogue_box/D_options
@onready var panel = $CanvasLayer/Panel

func _ready():
	hide_dialogue()

func show_dialogue(speaker, text, options):
	panel.visible = true
	print("dialogue shown")
	d_speaker.text = speaker
	d_speech.text = text
	
	for option in d_options.get_children():     #REMOVING OPTIONS
		d_options.remove_child(option)
		
	for option in options.keys():
		var button = Button.new()
		button.text = option
		button.add_theme_font_size_override("font_size", 20)
		button.pressed.connect(_on_option_selected.bind(option))  
		d_options.add_child(button)
		
func _on_option_selected(option):  #HANDLE RESPONSE SELECT
	get_parent().handle_dialogue_choice(option) 
	
func hide_dialogue():
	Global.can_move = true
	panel.visible = false

func _on_close_dialogue_pressed() -> void:
	hide_dialogue()
