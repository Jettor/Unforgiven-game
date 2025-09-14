extends Control

@onready var quest_panel = $CanvasLayer/Panel
@onready var quest_list = $CanvasLayer/Panel/content/Details/QuestList
@onready var quest_title = $CanvasLayer/Panel/content/Details/QuestDetails/Quest_title
@onready var quest_description = $CanvasLayer/Panel/content/Details/QuestDetails/Quest_desc
@onready var quest_objective = $CanvasLayer/Panel/content/Details/QuestDetails/Quest_objective
@onready var quest_reward = $CanvasLayer/Panel/content/Details/QuestDetails/Quest_reward

func _ready():
	quest_panel.visible = false

func toggle_log_visibility():
	quest_panel.visible = !quest_panel.visible
