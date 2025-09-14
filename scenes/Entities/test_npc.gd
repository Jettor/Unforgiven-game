extends CharacterBody2D

@export var npc_id: String
@export var npc_name: String
@onready var dialogue_manager = $DialogueManager

@export var dialogue_res: Dialogue
var curr_state = "start"
var curr_branch_index = 0

@export var quests: Array[Quest] = []
var quest_manager: Node = null

func _ready():
	dialogue_res.load_from_json("res://resources/dialogue/dialogue_test_data.json")
	dialogue_manager.npc = self
	quest_manager = Global.player.quest_manager
	print("Npc quests loaded: ",quests.size())
	
func start_dialogue():
	print("dialogue started")
	var npc_dialogues = dialogue_res.get_npc_dialogue(npc_id)
	if npc_dialogues.is_empty():
		return
	dialogue_manager.show_dialogue(self)
	#dialogue_manager.show_dialogue(self)
	
func get_curr_dialogue():
	var npc_dialogues = dialogue_res.get_npc_dialogue(npc_id)
	if curr_branch_index < npc_dialogues.size(): #array.size() is int
		for i in npc_dialogues[curr_branch_index]["dialogues"]: #Here dialogue is i 
			if i["state"] == curr_state:
				return i
	return null
	
func set_dialogue_tree(branch_index):   #UPDATE BRANCH
	curr_branch_index = branch_index
	curr_state = "start"
	
func set_dialogue_state(state):
	curr_state = state
