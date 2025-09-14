extends Resource
class_name Quest

@export var quest_id: String
@export var quest_name: String
@export var state: String = "not_started"
@export var unlock_id: String
@export var objectives: Array[Objectives] = []
@export var rewards: Array[Rewards] = []

func is_completed() -> bool:   #OBJECTIVE STATE CHECK
	for i in objectives:
		if !i.is_completed:
			return false
	return true

func complete_objective(objective_id: String, quantity: int = 1):
	for i in objectives:   # i IS OBJECTIVE
		if i.id == objective_id:
			if i.target_type == "collection":
				i.collected_quantity += quantity
				if i.collected_quantity >= i.required_quantity:
					i.is_completed = true
			elif i.target_type == "talk_to":
				i.is_completed = true
			break   # THIS CODE CAN BE EXPANDED FOR OTHER OBJECTIVES LIKE KILLING ENEMY OR USING ITEM
	if is_completed():
		state = "completed"
