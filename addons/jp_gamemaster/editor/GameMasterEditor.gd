@tool
extends Control


func _ready() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	jpGMT.set_preset(self)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_EDITOR_PRE_SAVE:
			jpGMT.set_preset(self, jpGMT.PRESETS.DEFAULT)
