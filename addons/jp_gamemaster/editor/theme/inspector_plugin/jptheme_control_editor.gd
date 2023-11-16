@tool
extends Control

@onready var content: Control = %content

func _ready() -> void:
	custom_minimum_size = content.get_minimum_size()

