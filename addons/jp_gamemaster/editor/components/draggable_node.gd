@tool
class_name GridControl
extends Control

@export var grid_input: Control


func _gui_input(event: InputEvent) -> void:
	grid_input.on_node_gui_input(self, event)
