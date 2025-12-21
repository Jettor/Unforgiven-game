extends Node2D

@onready var dialogue_ui = $DialogueUI
var npc: Node = null

func show_dialogue(curr_npc, text="", options = {}):
	var current_dialogue = curr_npc.get_curr_dialogue()
	if current_dialogue == null:
		return
	var speaker_name = current_dialogue.get("speaker", curr_npc.npc_name) 
	#For some reason it works correctly, showing default npc name at all times except when other speaker is mentioned
	if text != "":
		dialogue_ui.show_dialogue(speaker_name, text, options)   #SHOW BOX
	else:
		#quest related dialogues
		var quest_dialogue = curr_npc.get_quest_dialogue()
		if quest_dialogue["text"] != "":
			dialogue_ui.show_dialogue(speaker_name, quest_dialogue["text"], quest_dialogue["options"])
		#non quest related dialogues
		else:
			var dialogue = curr_npc.get_curr_dialogue()  
			if dialogue == null:
				return
			dialogue_ui.show_dialogue(speaker_name, dialogue["text"], dialogue["options"])

func hide_dialogue():
	dialogue_ui.hide_dialogue()
	
	
func handle_dialogue_choice(option):
	var curr_dialogue = npc.get_curr_dialogue() #GET CURRENT DIALOGUE BRANCH
	if curr_dialogue == null:
		return
	var next_state = curr_dialogue["options"].get(option, "start") #UPDATE STATE
	npc.set_dialogue_state(next_state)
	match next_state:
		"end":
			if npc.curr_branch_index < npc.dialogue_res.get_npc_dialogue(npc.npc_id).size() - 1:
				npc.set_dialogue_tree(npc.curr_branch_index + 1)
			hide_dialogue()
		"exit":
			npc.set_dialogue_state("start")
			hide_dialogue()
		"exit_quest_accept": 
			if npc.dialogue_res.get_npc_dialogue(npc.npc_id)[npc.curr_branch_index]["branch_id"] == "npc_default":
				offer_remaining_quests()
				npc.quest_in_progress = true
			else:
				offer_quests(npc.dialogue_res.get_npc_dialogue(npc.npc_id)[npc.curr_branch_index]["branch_id"])
			show_dialogue(npc)
		_:
			show_dialogue(npc)
		
	if next_state == "about_myself_1" or next_state == "leaving_tell_name":
		npc.knows_name = true
		
	if next_state == "penalty_option_name" or next_state == "penalty_option_past":
		Global.change_trust(npc.npc_id, -1)
		
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
						if npc.talked_low_trust:
							return "start_low_trust_return_1"
						else:
							npc.curr_branch_index += 1
							npc.talked_low_trust = true
							return "start_low_trust_1"
					3:
						npc.curr_branch_index = 5
						if npc.knows_name:
							return "mid_trust_penalty"
						else:
							return "mid_trust_penalty_nameless"
					4:
						if npc.talked_mid_trust:
							if npc.knows_name:
								return "start_mid_trust_return_1_name"
							else:
								return "start_mid_trust_return_1_nameless"
						else:
							npc.curr_branch_index += 1
							npc.talked_mid_trust = true
							return "start_mid_trust_1"
					6:
						npc.curr_branch_index += 1
						return "start_high_trust"
					8:
						npc.curr_branch_index += 1
						return "start_full_trust"
					_: return "in_progress"
	else:
		return "start"
		
