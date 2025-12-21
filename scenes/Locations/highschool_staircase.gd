extends Node2D
@onready var mc = $CharacterBody2D

func _ready():
	mc.zoom_animator.play("zoom_staircase")
	mc.healthbar.hide()
