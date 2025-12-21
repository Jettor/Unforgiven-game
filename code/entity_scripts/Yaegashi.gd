extends CharacterBody2D

@export var npc_id: String
@export var npc_name: String
@onready var dialogue_manager = $DialogueManager
@onready var sprite = $AnimatedSprite2D

@export var dialogue_res: Dialogue
var curr_state = "start"
var curr_branch_index = 0

@export var quests: Array[Quest] = []
var quest_manager: Node = null

var knows_name: bool = false
var talked_before: bool = false
var talked_low_trust: bool = false
var talked_mid_trust: bool = false

func _ready(): #dialogue_test_data.json      test_npc1.json
	sprite.play("default")
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
	
	print("Searching state ", curr_state, " in branch ", curr_branch_index, " with branch id: ", npc_dialogues[curr_branch_index]["branch_id"])
	
	if npc_dialogues.is_empty():
		return
	dialogue_manager.show_dialogue(self)
	
func get_curr_dialogue():
	var npc_dialogues = dialogue_res.get_npc_dialogue(npc_id)
	if curr_branch_index >= npc_dialogues.size(): #array.size() is int
		return null
	for dialogue in npc_dialogues[curr_branch_index]["dialogues"]:
		if dialogue["state"] == curr_state:
			return dialogue
	print("Dialogue state ", curr_state, " is missing")
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
			print("Quest in progress")
			
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
			
