@tool
extends Area2D
@onready var sprite = $Sprite2D

@export var item_id: String = ""
@export var item_quantt: int = 1
@export var item_icon = Texture2D

func _ready():
	if not Engine.is_editor_hint():
		sprite.texture = item_icon
		
func _process(delta):
	if Engine.is_editor_hint():
		sprite.texture = item_icon
		
func start_interraction():
	print("This is item")
