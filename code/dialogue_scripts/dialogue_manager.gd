extends Node2D

@onready var dialogue_ui = $DialogueUI
var npc: Node = null

func show_dialogue(curr_npc, text="", options = {}):
	if text != "":
		print("text alright")
		dialogue_ui.show_dialogue(curr_npc.npc_name, text, options)   #SHOW BOX
	else:
		#quest related dialogues
		var quest_dialogue = curr_npc.get_quest_dialogue()
		if quest_dialogue["text"] != "":
			dialogue_ui.show_dialogue(curr_npc.npc_name, quest_dialogue["text"], quest_dialogue["options"])
		#non quest related dialogues
		else:
			var dialogue = curr_npc.get_curr_dialogue()  
			if dialogue == null:
				return
			dialogue_ui.show_dialogue(curr_npc.npc_name, dialogue["text"], dialogue["options"])

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
	elif next_state == "give_quests" or "give_quest_2" or "give_quest_3" or "give_quest_4" or "give_quest_5":
		if npc.dialogue_res.get_npc_dialogue(npc.npc_id)[npc.curr_branch_index]["branch_id"] == "npc_default":
			offer_remaining_quests()
		else:
			offer_quests(npc.dialogue_res.get_npc_dialogue(npc.npc_id)[npc.curr_branch_index]["branch_id"])
		show_dialogue(npc)
	else:
		show_dialogue(npc)
		
func offer_quests(branch_id: String):   #OFFER ALL CURRENTLY AVAILABLE QUESTS AT BRANCH
	for i in npc.quests:
		if i.unlock_id == branch_id and i.state == "not_started":
			npc.offer_quest(i.quest_id)
			
func offer_remaining_quests(): #OFFER PREVIOUSLY UNACCEPTED QUESTS
	for i in npc.quests:
		if i.state == "not_started":
			npc.offer_quest(i.quest_id)
			
func can_access(dialogue_state: Dictionary, trust_lvl: int) -> bool:
	return trust_lvl >= (dialogue_state.get("trust_required",0))
	
func get_start_state(curr_npc: Node) -> String:
	var trust_level = Global.npc_trust_lvl.get(curr_npc.npc_id, 0)
	if curr_npc.talked_before:
				match(trust_level):
					0:
						return "start_zero_trust_1"
					2:
						npc.curr_branch_index += 1
						return "start_low_trust_1"
					4:
						npc.curr_branch_index += 1
						return "start_mid_trust"
					6:
						npc.curr_branch_index += 1
						return "start_high_trust"
					8:
						npc.curr_branch_index += 1
						return "start_full_trust"
					_: return "start"
	else:
		return "start"
		
