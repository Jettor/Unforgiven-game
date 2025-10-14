extends Control

@onready var quest_panel = $CanvasLayer/Panel
@onready var quest_list = $CanvasLayer/Panel/content/Details/QuestList
@onready var quest_title = $CanvasLayer/Panel/content/Details/QuestDetails/Quest_title
@onready var quest_description = $CanvasLayer/Panel/content/Details/QuestDetails/Quest_desc
@onready var quest_objective = $CanvasLayer/Panel/content/Details/QuestDetails/Quest_objective
@onready var quest_reward = $CanvasLayer/Panel/content/Details/QuestDetails/Quest_reward
var selected_quest: Quest = null
var quest_manager

func _ready():
	quest_panel.visible = false
	clear_quest_details()
	quest_manager = get_parent()
	quest_manager.quest_updated.connect(_on_quest_updated)
	quest_manager.objective_updated.connect(_on_objectives_updated)

func toggle_log_visibility():
	quest_panel.visible = !quest_panel.visible
	update_quest_list()
	if selected_quest:
		_on_quest_selected(selected_quest)

func update_quest_list():
	for child in quest_list.get_children(): #ERASE ALL QUESTS
		quest_list.remove_child(child)
	var active_quests = get_parent().get_active_quests()
	print("active quests: ",active_quests.size())
	if active_quests.size() == 0:
		clear_quest_details()
		Global.player.selected_quest = null
	else:
		for i in active_quests:
			var button = Button.new()
			button.add_theme_font_size_override("font_size", 20)
			button.text = i.quest_name
			button.pressed.connect(_on_quest_selected.bind(i))
			quest_list.add_child(button)
			
func _on_quest_selected(quest: Quest):
	selected_quest = quest
	Global.player.selected_quest = quest
	quest_title.text = quest.quest_name
	quest_description.text = quest.quest_description
	print("quest_selected: ",quest.quest_name, " ", quest.quest_id)
	
	for child in quest_objective.get_children(): 
		child.queue_free()
	for objective in quest.objectives:
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 20)
		if objective.target_type == "collection":
			label.text = objective.description + "(" + str(objective.collected_quantity) + "/" +  str(objective.required_quantity) + ")"
		else: 
			label.text = objective.description
		
		if objective.is_completed:
			label.add_theme_color_override("font_color", Color(0,1,0))
		else:
			label.add_theme_color_override("font_color", Color(1,0,0))
		quest_objective.add_child(label)
		
	for child in quest_reward.get_children():
		quest_reward.remove_child(child)
		
	for reward in quest.rewards: 
		var label = Label.new()
		quest_reward.add_child(label)
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0,0.85,0))
		label.text = "Rewards:\n"+ reward.reward_type.capitalize() + ":" + str(reward.reward_amount)
		quest_reward.add_child(label)
		
func clear_quest_details():   #CLEAR QUEST DETAILS
	quest_title.text = ""
	quest_description.text = ""
	for child in quest_objective.get_children(): 
		quest_objective.remove_child(child)
	for child in quest_reward.get_children():
		quest_reward.remove_child(child)

func _on_quest_updated(quest_id: String):   #TRIGGER TO UPDATE QUEST LIST
	if selected_quest and selected_quest.quest_id == quest_id:
		_on_quest_selected(selected_quest)
	else:
		update_quest_list()
	selected_quest = null
	
func _on_objectives_updated(quest_id: String, objectives_id: String):   #TRIGGER TO UPDATE OBJECTIVES
	if selected_quest and selected_quest.quest_id == quest_id:
		_on_quest_selected(selected_quest)
	else:
		clear_quest_details()
	selected_quest = null

func _on_close_dialogue_pressed() -> void:
	toggle_log_visibility()
