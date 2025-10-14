extends Node2D

@onready var quest_ui = $QuestUI

signal quest_updated(quest_id: String)
signal objective_updated(quest_id: String, objective_id: String)
signal quest_list_updated()
var quests = {}

func add_quest(quest: Quest):
	print("quest_added")
	quests[quest.quest_id] = quest
	quest_updated.emit(quest.quest_id)
	
func remove_quest(quest_id: String):
	quests.erase(quest_id)
	quest_list_updated.emit()
	
func get_quest(quest_id: String) -> Quest:
	return quests.get(quest_id, null)
	
func update_quest(quest_id: String, state: String):
	var quest = get_quest(quest_id)
	if quest:
		quest.state = state
		quest_updated.emit(quest_id)
		if state == "completed":
			remove_quest(quest_id)

func get_active_quests() -> Array:
	var active_quests = []
	for i in quests.values():
		if i.state == "in_progress":
			active_quests.append(i)
	return active_quests
	
func complete_objective(quest_id: String, objective_id: String): 
	var quest = get_quest(quest_id)
	if quest:
		quest.complete_objective(quest, objective_id)
		objective_updated.emit(quest_id, objective_id)
	
func toggle_log_visibility():
	quest_ui.toggle_log_visibility()
	
