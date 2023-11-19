@tool
extends Control


func _ready() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	jpGMT.set_preset(self)


func _notification(what: int) -> void:
	jpGMT.on_notification(self, what)
