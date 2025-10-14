extends CharacterBody2D

@export var npc_id: String
@export var npc_name: String
@onready var dialogue_manager = $DialogueManager

@export var dialogue_res: Dialogue
var curr_state = "start"
var curr_branch_index = 0

@export var quests: Array[Quest] = []
var quest_manager: Node = null
var talked_before: bool = false

func _ready(): #dialogue_test_data.json      test_npc1.json
	dialogue_res.load_from_json("res://resources/dialogue/yaegashi_dialogues.json")
	dialogue_manager.npc = self
	quest_manager = Global.player.quest_manager
	#print("Npc quests loaded: ",quests.size())
	
func start_dialogue(npc):
	var start_state = dialogue_manager.get_start_state(npc)
	set_dialogue_state(start_state)
	talked_before = true
	print("dialogue started")
	var npc_dialogues = dialogue_res.get_npc_dialogue(npc_id)
	if npc_dialogues.is_empty():
		return
	dialogue_manager.show_dialogue(self)
	
func get_curr_dialogue():
	var npc_dialogues = dialogue_res.get_npc_dialogue(npc_id)
	if curr_branch_index < npc_dialogues.size(): #array.size() is int
		for i in npc_dialogues[curr_branch_index]["dialogues"]: #Here dialogue is i 
			if i["state"] == curr_state:
				return i
	return null
	
func set_dialogue_tree(branch_index):   #UPDATE BRANCH
	curr_branch_index = branch_index
	curr_state = "start_first"
	
func set_dialogue_state(state):
	curr_state = state
	
func offer_quest(quest_id: String):
	print("offering quest: ", str(quest_id))
	for i in quests:
		if i.quest_id == quest_id and i.state  == "not_started":
			i.state = "in_progress"
			quest_manager.add_quest(i)
			return
	print("ERROR! quest not found or already started")   #sus

func get_quest_dialogue() -> Dictionary:   #For talk_to quests
	var active_quests = quest_manager.get_active_quests()
	for quest in active_quests:
		for objective in quest.objectives:
			if objective.target_id == npc_id and objective.target_type == "talk_to" and objective.is_completed:
				if curr_state == "start":
					return {"text": objective.objective_dialogue, "options":{}}
	return {"text": "", "options":{}}
			
