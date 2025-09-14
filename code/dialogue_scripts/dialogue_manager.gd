extends Node2D

@onready var dialogue_ui = $DialogueUI
var npc: Node = null

func show_dialogue(npc, text="", options = {}):
	if text != "":
		dialogue_ui.show_dialogue(npc.npc_name, text, options)   #SHOW BOX
	else:
		var dialogue = npc.get_curr_dialogue()   #SHOW POPULATED DATA
		if dialogue == null:
			return
		dialogue_ui.show_dialogue(npc.npc_name, dialogue["text"], dialogue["options"])

func hide_dialogue():
	dialogue_ui.hide_dialogue()
	
func handle_dialogue_choice(option):
	var curr_dialogue = npc.get_curr_dialogue() #GET CURRENT DIALOGUE BRANCH
	if curr_dialogue == null:
		return
	var next_state = curr_dialogue["options"].get(option, "start") #UPDATE STATE
	npc.set_dialogue_state(next_state)
	if next_state == "end":
		if npc.curr_branch_index < npc.dialogue_res.get_npc_dialogue(npc.npc_id).size() - 1:
			npc.set_dialogue_tree(npc.curr_branch_index + 1)
		hide_dialogue()
	elif next_state == "exit":
		npc.set_dialogue_state("start")
		hide_dialogue()
	elif next_state == "give_quests":
		pass # TO DO
	else:
		show_dialogue(npc)
